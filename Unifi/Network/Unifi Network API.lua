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
port = "8443"
evohomeID = {true,170}; -- If Evohome is used set to true and enter the number of the Virt ID

--> Do not change -->

--[[

Unifi Network API - to check presence of family memmbers 
Created by Remko de Boer

Description:
	API to check presence of family members

Remarks:
  Looks like the sitename is always default

Prerequisite:
  Global variable PresentState, to set home or away status
  Global variables eith the name of the users, eq Remko 
	
Arguments:
 siteid: name of site, eq "default" -- only lowe =r case??
 users: name of users
 virtid: ID of Virtual Device
 eq startScene(114,{"Default",{"Person1","Peron2"},121}) 

Release notes:
  0.0.1.0 (20190723) Initial version
  0.0.2.0 (20190723) Added Login, GetfullData functions
  0.0.3.0 (20290723) Added function presentState to check which family member is at home
  1.0.0.0 (20190724) First release
  1.0.0.1 (20190724) Bug in call to Login, for all fields argument 1 was used
  1.2.0.0 (20190724) If any error occurs users will be set to present
  1.2.2.0 (20190725) Bug missing space between users at home
                     Bug in loop, didn't stop/break when mac was found

To do:
  Check if site name is always lower case, see also Remarks
	
--]]
local version = "1.2.2.0"

PresentState = fibaro:getGlobal("PresentState")
state = {"away", "present"};

baseUrl = "https://"..host..":"..port.."/";

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Login
function Login(siteid, users, virtid)
  cookie = ""
  is_error = false
  url = baseUrl .. "api/login"
  creds = '{"username":"'..username..'","password":"'..password..'"}'
  
  http:request(url, {
    options={
      headers = {
        ["Accept"] = "application/json",
        ["Content-Type"] = "application/json; charset=utf-8"
      },
      data = creds,
      checkCertificate = false,
      method = 'POST',
      timeout = 5000
    },
    success = function(result)
	  if result.status == 200 or result.status == 201 then
	    result.data = trim(result.data)
        --log(result.data)
        userData = json.decode(result.data)
        if userData["meta"]["rc"] ~= nil and userData["meta"]["rc"] == "ok" then
          cookie = result.headers["Set-Cookie"]
          --log(cookie)
          GetFullData(cookie, siteid, users, virtid)
        else
          is_error = true
          errorlog("Error getting userData (Login)")
          if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end 
        end
 	  else
        is_error = true
        errorlog("Error HTTP status (Login): "..result.status)
        if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end
      end
    end,
    error = function(error)
      is_error = true
      fibaro:debug("Error getting data (Login): "..error)
      if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end
    end
  })
  if is_error then
    GetFullData(cookie, siteid, users, virtid)
  end
end

function GetFullData(cookie, siteid, users, virtid)
  macs = {}
  is_error = false
  if cookie ~= "" then
    url = baseUrl .. "api/s/" .. siteid .. "/stat/sta"
    http:request(url, {
      options={
        headers = {
          ['Content-Type'] = 'application/json; charset=utf-8',
          ['Accept'] = 'application/json, text/plain, */*',
          ['Cookie'] = cookie
        },
        checkCertificate = false,
        method = 'GET',
        timeout = 5000
      },
      success = function(result)
        if result.status == 200 or result.status == 201 then
	       result.data = trim(result.data)
          --log(result.data)
          fullData = json.decode(result.data)
          if fullData["meta"]["rc"] ~= nil and fullData["meta"]["rc"] == "ok" then
            for k, v in pairs(fullData["data"]) do
              --log(json.encode(v))
              if v["last_seen"] > os.time(t) - 300 and v["is_wired"] == false then
                --log(v["mac"])
                table.insert(macs, v["mac"])
              end
            end
            presentState(macs, users, virtid)
          else
            is_error = true
            errorlog("Error getting fullData (GetFullData)")
            if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end
          end
        else
          is_error = true
          errorlog("Error HTTP status (GetFullData): "..result.status)
          if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end 
        end
      end,
      error = function(error)
        is_error = true
        fibaro:debug("Error getting data (GetFullData): "..error)
        if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", "Error getting data"); end 
      end
    })
  end
  if is_error then
    presentState(macs, users, virtid)
  end
end

function presentState(macs, users, virtid)
  --log(json.encode(macs))
  usersState = {}
  present = {}
  for i=1,#users do
    --log(users[i])
    usersState[users[i]] = json.decode(fibaro:getGlobalValue(users[i]))
    if #macs == 0 then
      usersState[users[i]]["present"] = 1
      table.insert(present, users[i])
    else
      for j=1,#macs do
        if string.lower(usersState[users[i]]["mac"]) == string.lower(macs[j]) then
          usersState[users[i]]["present"] = 1
          table.insert(present, users[i])
          break
        else
          usersState[users[i]]["present"] = 0
        end
      end
    end
    local ui_state = state[tonumber(usersState[users[i]]["present"])+1];
    if not test then fibaro:call(virtid, 'setProperty', 'ui.lbl'..users[i]..'.value',ui_state); end
    log(users[i]..": "..usersState[users[i]]["present"]);
    if not test then fibaro:setGlobal(users[i], json.encode(usersState[users[i]])); end
  end
  if #present == 0 then
    uiActive = "Nobody"
    if PresentState == "Home" then
      fibaro:setGlobal("PresentState", "Away");
      if evohomeID[1] == true then fibaro:call(evohomeID[2], "pressButton", "4"); end
      fibaro:startScene(113,{"Default",{"Vijver","Garage"},"on","both"})
      log("Away")
    end
  elseif #present > 1 then
    if PresentState == "Away" then
      fibaro:setGlobal("PresentState", "Home");
      if evohomeID[1] == true then fibaro:call(evohomeID[2], "pressButton", "2"); end
      fibaro:startScene(113,{"Default","","off",""})
      log("Home")
    end
    if #present == #users then
      uiActive = "Everybody"
    else
      for i=1,#present do
        --if uiActive == "" or uiActive == nil then
        if i == 1 then
          uiActive = present[i]
        elseif i > 1 and i < #present then
          uiActive = uiActive .. ", " .. present[i]
        elseif i == #present then
          uiActive = uiActive .. " and " .. present[i]
        end
      end
    end
  end
  log(uiActive)
  if not test then fibaro:call(virtid, 'setProperty', 'ui.lblMain.value',uiActive); end
  if not test then fibaro:call(virtid, "setProperty", "ui.lbllastUpdate.value", os.date("%c")); end
  if not test then fibaro:call(virtid, "setProperty", "ui.lblError.value", ""); end
end

-- Main
http = net.HTTPClient()

if test then
  Login("default",{"Remko","Renata","Jord","Kris"}, 420)
else
  if fibaro:args() ~= nil and #fibaro:args() == 3 then
    Login(fibaro:args()[1],fibaro:args()[2],fibaro:args()[3]) -- name of site, users to check (name), virt id
  else
    errorlog("Arguments missing")
  end
end

--end script
