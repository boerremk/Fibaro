--[[
%% properties
%% events
%% globals
--]]
debug = true;
test = false;
username = "USERNAME"
password = "PASSWORD"
host = "HOSTNAME or IP"
port = "7443"


--> Do not change -->

--[[

Unifi Protect API - enable/disable motion alerting
Created by Remko de Boer

Description:
	API to enable/disable motion detection Unifi Protect

Remarks:

Prerequisite:
	
Arguments:
 alertRuleName: name of rule to change
 cameras: name of cameras to set
 status: on or off
 event: email, push or both
 eq status=on, event=both: fibaro:startScene(108,{"Default", {"Garden", "Kitchen}, "on", "both"}) or
    status=on, event=email: fibaro:startScene(108,{"Default", {"Garden", "Kitchen}, "on", "email"}) or
    status=off: fibaro:startScene(108,{"Default", "", "off", ""})
 
 !!Remark: If status is set to on for some cameras the other will be off!

Release notes:
  0.0.1.0 (20190322) Initial version
  0.0.2.0 (20190322) Added status argument
  0.0.3.0 (20190323) Added event argument
  0.0.4.0 (20190324) Bugfix email/push in wrong section
  0.0.5.0 (20190327) Added variables: userid, cameraid, host and port
  1.0.0.0 (20190327) First release
  1.1.0.0 (20190422) Added extra camera, changed variable cameraid to table (not using for now)
  1.1.0.1 (20190722) Added function Auth to get userid and alertrule id
  1.1.0.2 (20190722) Added function Bootstrap to get camera ids, cameras can be set separately  
  1.1.0.3 (20190723) Added Bearer from response header
  2.0.0.0 (20190723) New release
  2.1.0.0 (20190723) Added function Acceskey to renew accessKey, not used yet
  2.1.1.0 (20190726) Bug fix: argument 3 insted od 4 was used for event, row 239

To do:
  
	
--]]
local version = "1.0.1.3"

baseUrl = "https://"..host..":"..port.."/";

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function Auth(alertRuleName, cameras, status, event)
  creds = '{"username":"'..username..'","password":"'..password..'"}'
  url = baseUrl .. "api/auth"
  http:request(url, { 
    options = { 
      method = 'POST', 
      checkCertificate = false,
      headers = {
        ["Accept"] = "application/json",
        ["Content-Type"] = "application/json; charset=utf-8"
      },
      data = creds,
      timeout = 5000
    }, 
    success = function(result)
      if result.status == 200 or result.status == 201 then
        bearer = result.headers.Authorization
        --log(bearer)
        headers = {
          ['Authorization']='bearer ' .. bearer,
          ['Content-Type']='application/json; charset=utf-8',
          ['Accept']='application/json'			
        } 
        result.data = trim(result.data)
        --log(result.data)
        userData = json.decode(result.data)
        if userData ~= nil then
          Bootstrap(userData, headers, alertRuleName, cameras, status, event)
        else
          errorlog("Error getting userData (Auth)")
        end
 	  else
        errorlog("Error HTTP status (Auth): "..result.status)
      end
    end,
	error = function(error)
	  errorlog("Error getting data (Auth): "..error)
    end
  })
end

function Accesskey(headers) 
  url = baseUrl.."/api/auth/access-key"
  http:request(url, { 
    options = { 
      method = 'POST', 
      checkCertificate = false,
      headers = headers,
      timeout = 5000
    }, 
    success = function(result)
      if result.status == 200 or result.status == 201 then
		result.data = trim(result.data)
		--log(result.data)
        arrayData = json.decode(result.data)
        accessKey = arrayData["accessKey"]
          
        return accessKey
	  else
		errorlog("Error HTTP status (Bootstrap): "..result.status)
	  end
	end,
	error = function(error)
	  errorlog("Error getting data (Bootstrap): "..error)
	end
  })  
end

function Bootstrap(userData, headers, alertRuleName, cameras, status, event)
  url = baseUrl.."api/bootstrap"
  http:request(url, { 
    options = { 
      method = 'GET', 
      checkCertificate = false,
      headers = headers,
      timeout = 5000
    }, 
    success = function(result)
      if result.status == 200 or result.status == 201 then
		result.data = trim(result.data)
		--log(result.data)
        fullData = json.decode(result.data)
        cameraid = {}
        for k, v in pairs(fullData["cameras"]) do
          for i=1,#cameras do
            if string.lower(v["name"]) == string.lower(cameras[i]) then
              table.insert(cameraid, v["id"])
            end
          end
        end
        if cameraid ~= {} then
          API(userData, headers, alertRuleName, cameraid, status, event)
        else
          errorlog("Error getting cameraid (Bootstrap)")
        end
	  else
		errorlog("Error HTTP status (Bootstrap): "..result.status)
	  end
	end,
	error = function(error)
	  errorlog("Error getting data (Bootstrap): "..error)
	end
  })  
end

function API(userData, headers, alertRuleName, cameraid, status, event)
  userid = userData["id"]
  for k, v in pairs(userData["alertRules"]) do
   if string.lower(v["name"]) == string.lower(alertRuleName) then
      alertRuleId = v["id"] 
    end
  end
  url = baseUrl.."api/users/"..userid.."/alert-rule/"..alertRuleId;
  
  if status == "on" then
    log("event: "..event)
	if event == "email" then
      data = '{"id":"'..alertRuleId..'","name":"'..alertRuleName..'","geofencing":"off","schedule":{"items":[]},"system":{"connectDisconnect":["push","email"],"update":["email"]},"cameras":[{"connectDisconnect":["email","push"],"motion":[],"camera":null}'
      for i=1,#cameraid do
        data = data .. ',{"connectDisconnect":[],"motion":["email"],"camera":"'..cameraid[i]..'"}'
      end
      data = data .. '],"users":[]}'
	elseif event == "push" then
      data = '{"id":"'..alertRuleId..'","name":"'..alertRuleName..'","geofencing":"off","schedule":{"items":[]},"system":{"connectDisconnect":["push","email"],"update":["email"]},"cameras":[{"connectDisconnect":["email","push"],"motion":[],"camera":null}'
      for i=1,#cameraid do
        data = data .. ',{"connectDisconnect":[],"motion":["push"],"camera":"'..cameraid[i]..'"}'
      end
      data = data .. '],"users":[]}'
	elseif event == "both" then
      data = '{"id":"'..alertRuleId..'","name":"'..alertRuleName..'","geofencing":"off","schedule":{"items":[]},"system":{"connectDisconnect":["push","email"],"update":["email"]},"cameras":[{"connectDisconnect":["email","push"],"motion":[],"camera":null}'
      for i=1,#cameraid do
        data = data .. ',{"connectDisconnect":[],"motion":["email","push"],"camera":"'..cameraid[i]..'"}'
      end
      data = data .. '],"users":[]}'
    else
      errorlog("Error event not correct, use 'email', 'push' or 'both' (API)")
      return
	end
  elseif status == "off" then
    data = '{"id":"'..alertRuleId..'","name":"'..alertRuleName..'","geofencing":"off","schedule":{"items":[]},"system":{"connectDisconnect":["push","email"],"update":["email"]},"cameras":[{"connectDisconnect":["email","push"],"motion":[],"camera":null}],"users":[]}'
  end
  http:request(url, { 
    options = { 
      method = 'PATCH', 
      checkCertificate = false,
      headers = headers,
      data = data,
      timeout = 5000
    }, 
    success = function(result)
      if result.status == 200 or result.status == 201 then
		result.data = trim(result.data)
		log(result.data)
	  else
		errorlog("Error HTTP status (API): "..result.status)
	  end
	end,
	error = function(error)
	  errorlog("Error getting data (API): "..error)
	end
  })      
end

http = net.HTTPClient()

if test then
  Auth("Default", {"Vijver", "Garage"}, "on", "both")
  --Auth("Default", "", "off", "")
else
  if fibaro:args() ~= nil and #fibaro:args() == 4 then
    Auth(fibaro:args()[1],fibaro:args()[2], fibaro:args()[3], fibaro:args()[4])
  else
    errorlog("Arguments missing")
  end
end

--end script
