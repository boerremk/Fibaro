--[[
%% properties
%% events
%% globals
--]]

---FIBARO USERID: http://<IP OF HC2>/api/users
---FIBARO PHONEID: http://<IP OF HC2>/api/iosDevices

local username = {
  ["username"] = "Test",
  ["present"] = 1,
  ["mac"] = "MAC ADDRESS",
  ["userid"] = FIBARO USERID,
  ["phoneid"] = FIBARO PHONEID
 }

local debug = true
local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function infolog(str) fibaro:debug("<font color='green'>"..tostring(str).."</font>"); end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function addGlobal(vName, vValue)
  local http = net.HTTPClient({timeout=5000})
  requestData = json.encode({ name = vName, value = vValue })
  http:request("http://127.0.0.1:11111/api/globalVariables", { 
    options = {
      method = 'POST', 
      headers = { 
        ['Content-Type'] = 'application/json'
      },
      data = requestData,
      timeout =  5000
    }, 
    success = function(resp)
      if tonumber(resp.status) == 201 then
        log("status: "..tostring(resp.status)..", variable: "..vName.." added, value: "..vValue)
      end
    end,
    error = function(err) 
      errorlog("red", "error: "..tostring(err)..", variable: "..vName.." adding FAILED")
    end
  })
end

addGlobal(username["username"], json.encode(username))
