--[[
%% properties
%% events
%% globals
--]]
debug = true;
username = "POSTNL EMAIL";
password = "POSTNL PASSWORD";
limit = 10;

--> Do not change -->

--[[

PostNL Trak and Trace API
Created by Remko de Boer

Description:
  API to return shipping status of PostNL

Remarks:

Prerequisite:
  PostNL account: https://jouw.postnl.nl/#!/registreren

Arguments:
 virtID
 inbox or profile
 eq: (123, inbox) or (123, profile)

Release notes:
  0.0.1 (20180907) Initial version
  0.0.2 (20180908) Added bezorgd and onderweg to VD
  0.0.3 (20180923) Changed order of delivery
  0.0.4 (20181023) If this scene is started a correct error message is given
  0.0.5 (20181130) Changed way to set headers in API function
  0.0.6 (20181228) Some issues with special packages solved, sender information was not present
  0.0.7 (20181228) Added variable limit, to limit the results presented.
  1.0.0 (20190813) Fixed bug if limit is higher then the amount of parcels returned by Postnl
  1.1.0 (20190915) Changed way to define data in getToken

To do:
  updateVD: expected date?
  updateVD: delivered time?
  scene: bezorgd: amount of days (current version only today)

  
--]]
local version = "1.1.0"

baseUrl = "https://jouw.postnl.nl/web/";
apiUrl = baseUrl.."api/default/";
tokenUrl = baseUrl.."token";
clientId = "pwWebApp";

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function makeTimeStamp(dateString)
    local pattern = "(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)([%+%-])(%d+)%:(%d+)"
    local xyear, xmonth, xday, xhour, xminute, 
        xseconds, xoffset, xoffsethour, xoffsetmin = dateString:match(pattern)
    local convertedTimestamp = os.time({year = xyear, month = xmonth, 
        day = xday, hour = xhour, min = xminute, sec = xseconds})
    local offset = xoffsethour * 60 + xoffsetmin
    if xoffset == "-" then offset = offset * -1 end
    return convertedTimestamp + offset
end

function keyValToBody(tbl)
  -- Turn key/value pairs into key1=value1&key2&value2&...
  -- And encode each key and value to remove spaces, & etcetera.
  local tmp
  for k,v in pairs(tbl) do
    if tmp then
      tmp=tmp.."&"..urlencode(k).."="..urlencode(v)
    else
      tmp=urlencode(k).."="..urlencode(v)
    end
  end
  return tmp
end

function getToken(username, password, clientId, main_id, path)
  local data = {
		["username"] = username,
		["password"] = password,
		["client_id"] = clientId,
		["grant_type"] = "password"
  }
--  data = "username="..username.."&password="..password.."&client_id="..clientId.."&grant_type=password"
  http:request(tokenUrl, { 
    options = { 
      method = 'POST', 
      headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["Accept"] = "application/json, text/plain, */*"
	  },
      data = keyValToBody(data), 
      timeout = 5000
    }, 
    success = function(status)
	  if status.status == 200 or status.status == 201 then
		status.data = trim(status.data)
		userData = json.decode(status.data)
		access_token = userData['access_token']
        checkCertificate = false,
         
        API(access_token,main_id,path)
	  else
		errorlog("Error HTTP status (getToken): "..status.status)
	  end
	end,
	error = function(error)
	  fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
	  errorlog("Error getting data (getToken): "..error)
	end
  })
end

function API(access_token,main_id,path)
  url = apiUrl .. path
  log(url)
  http:request(url, { 
    options = { 
      method = 'GET', 
      checkCertificate = false,
	  headers = {
	    ['Authorization']='bearer ' .. access_token,
	  },
      timeout = 5000
    }, 
    success = function(status)
	  if status.status == 200 or status.status == 201 then
		status.data = trim(status.data)
        log(status.data)
		local userData = json.decode(status.data)
        fibaro:call(main_id, "setProperty", "ui.lblError.value", "")
        updateVD(main_id, userData['receiver'])
	  else
		errorlog("Error HTTP status (API): "..status.status)
	  end
    end,
	error = function(error)
	  fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
	  errorlog("Error getting data (API): "..error)
	end
  })      
end

function updateVD(main_id, userData)
  local bezorgd = "";
  local onderweg = "";
  local currentDate = os.date("%d-%m-%Y");
  if main_id ~= "" then
--    for p=1, #userData do
    if #userData < limit then
      limit = #userData
    end
    for p=1, limit do
      naam = ""
      if userData[p]['delivery']['status'] == "Delivered" and os.date("%d-%m-%Y", makeTimeStamp(userData[p]['delivery']['deliveryDate'])) == currentDate then
        if type(userData[p]['sender']) ~= "function" then
          if type(userData[p]['sender']['companyName']) ~= "function" then 
            naam = userData[p]['sender']['companyName']
          elseif type(userData[p]['sender']['lastName']) ~= "function" then
            naam = userData[p]['sender']['lastName']
          end
        else
          naam = userData[p]['trackedShipment']['barcode']
        end
        bezorgd = bezorgd .. naam .. "<br />"
      elseif userData[p]['delivery']['status'] ~= "Delivered" then
        if userData[p]['shipmentType'] == "Pending" then
          naam = userData[p]['trackedShipment']['barcode']
        elseif type(userData[p]['sender']) ~= "function" then
          if type(userData[p]['sender']['companyName']) ~= "function" then 
            naam = userData[p]['sender']['companyName']
          elseif type(userData[p]['sender']['lastName']) ~= "function" then
            naam = userData[p]['sender']['lastName']
          end
        else
          naam = userData[p]['trackedShipment']['barcode']
        end
        if userData[p]["delivery"]["phase"]["index"] == 0 then
          onderweg = onderweg .. naam .. "<br />"
        else
          onderweg = naam .. "<br />" .. onderweg
        end
      end
    end
    fibaro:call(main_id, "setProperty", "ui.lblBezorgd.value", bezorgd)
    fibaro:call(main_id, "setProperty", "ui.lblOnderweg.value", onderweg)
  else
    log("This is a test, all OK");
  end
end

local main_id = ""
local path = "inbox"

if fibaro:args() then
  main_id = fibaro:args()[1]
  path = fibaro:args()[2]
  http = net.HTTPClient()
  getToken(username, password, clientId, main_id, path)
else
  errorlog("No arguments given, use VD to update!")
end

--end script
