--[[
%% autostart
%% properties
%% weather
%% events
%% globals
--]]
local debug = true
local username = "RING EMAIL"
local password = "RING PASSWORD"
--[[

Title Ring API
Created by Remko de Boer

Inspired by:
  https://forum.fibaro.com/topic/42523-ring-doorbell-by-ringcom
  https://github.com/tchellomello/python-ring-doorbell

Description: 

Remarks:

Prerequisite:

Arguments:

Release notes:
  2.0.1 (20190801) Initial version
  2.1.0 (20190802) Changed to new oAuth method
  2.2.0 (20190802) Added function refreshToken. Used when token is expired.
  2.3.0 (20190818) Set headers["Authorization"] to nil in getToken and refreshToken.

To do:  
  Activate or inactive motion
  Errorhandling

--]]
local version = "2.3.0"

local OAUTH_ENDPOINT = 'https://oauth.ring.com/oauth/token'
local API_URI = 'https://api.ring.com'
local API_VERSION = '9'
local deviceId = "d1054710-1e04-4b83-a70d-111111111111"

local headers = {
  ["Content-Type"] = "application/x-www-form-urlencoded; charset: UTF-8",
  ["User-Agent"] = "Dalvik/1.6.0 (Linux; Android 4.4.4; Build/KTU84Q)",
  ["Hardware_ID"] = deviceId
}

---local headers2 = {
---  ["User-Agent"] = "android:com.ringapp:2.0.67(423)",
---  ["Hardware_ID"] = deviceId
---}

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function infolog(str) fibaro:debug("<font color='green'>"..tostring(str).."</font>"); end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function keyValToBody(tbl)
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


function getToken(nextFunction)
  log("Trying to get token...")
  local url = OAUTH_ENDPOINT
  local OAUTH_DATA = {
		["client_id"] = "ring_official_android",
		["grant_type"] = "password",
		["scope"] = "client",
		["username"] = username,
		["password"] = password
  }
  local request_body = keyValToBody(OAUTH_DATA)
  local headers = headers
  if headers["Authorization"] ~= nil then headers["Authorization"] = nil end
  log("HEADER getToken: " .. json.encode(headers))
  local http = net.HTTPClient()
  http:request(url,{
    options = {
      method = "POST",
      headers = headers,
      data = request_body
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log(response.data)
        fibaro:setGlobal("RingToken", response.data)
        createSession(json.decode(response.data), nextFunction)
        ---nextFunction(json.decode(response.data))
      else
        errorlog("Error HTTP status (getToken): "..response.status)
        errorlog(response.data)
        fibaro:setGlobal("RingToken", "")
      end
    end,
    error = function(error)
      errorlog("Error getting data (getToken): "..error)
      fibaro:setGlobal("RingToken", "")
    end
  })
end

function refreshToken(token, nextFunction)
  log("Trying to refresh token...")  
  local url = OAUTH_ENDPOINT
  local OAUTH_DATA = {
    ["client_id"] = "ring_official_android",
    ["grant_type"] = "refresh_token",
    ["refresh_token"] = token["refresh_token"]
  }
  local request_body = keyValToBody(OAUTH_DATA)
  local headers = headers
  if headers["Authorization"] ~= nil then headers["Authorization"] = nil end
  log("HEADER refreshToken: " .. json.encode(headers))
  local http = net.HTTPClient()
  http:request(url,{
    options = {
      method = "POST",
      headers = headers,
      data = request_body
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log(response.data)
        fibaro:setGlobal("RingToken", response.data)
        createSession(json.decode(response.data), nextFunction)
        ---nextFunction(json.decode(response.data))
      else
        errorlog("Error HTTP status (refreshToken): "..response.status)
        errorlog(response.data)
        fibaro:setGlobal("RingToken", "")
      end
    end,
    error = function(error)
      errorlog("Error getting data (refreshToken): "..error)
      fibaro:setGlobal("RingToken", "")
    end
  })
end

function createSession(token, nextFunction)
  log("Trying to create session...")  
  local url = API_URI .. "/clients_api/session"  
  local postData = {
    ["api_version"] = API_VERSION,
    ["device[hardware_id]"] = deviceId,    
    ["device[os]"] = "android",
    ["device[app_brand]"] = "ring",
    ["device[metadata][device_model]"] = "KVM",
    ["device[metadata][device_name]"] = "Python",
    ["device[metadata][resolution]"] = "600x800",
    ["device[metadata][app_version]"] = "1.3.806",
    ["device[metadata][app_instalation_date]"] = "",
    ["device[metadata][manufacturer]"] = "Qemu",
    ["device[metadata][device_type]"] = "desktop",
    ["device[metadata][architecture]"] = "desktop",
    ["device[metadata][language]"] = "en"  }
  local request_body = keyValToBody(postData)  
  local headers = headers
  headers["Authorization"] = "Bearer " .. token["access_token"]    
  local http = net.HTTPClient()
  http:request(url,{
    options = {
      method = "POST",
      headers = headers,
      data = request_body
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log(response.data)
        nextFunction(token)
      else
        errorlog("Error HTTP status (createSession): "..response.status)
        errorlog(response.data)
        fibaro:setGlobal("RingToken", "")
      end
    end,
    error = function(error)
      errorlog("Error getting data (createSession): "..error)
      fibaro:setGlobal("RingToken", "")
    end
  })
end

function checkEvents(token)
  log("Checking...")
  local headers = headers
  headers["Authorization"] = "Bearer " .. token["access_token"]
  local url = API_URI .. "/clients_api/dings/active"  
  local http = net.HTTPClient()
  http:request(url,{
    options = {
      headers = headers,
      method = "GET"
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log(response.data)
        local data = json.decode(response.data)
        local active = 0
        for k, v in pairs(data) do
          local action = v["kind"]
          infolog(os.date() .. ": " .. action)
          if action == "motion" then
            active = 1
          elseif action == "ding" then
            active = 2
          end
        end
        fibaro:setGlobal("Doorbell", active)
      else
        errorlog("Error HTTP status (checkEvents): "..response.status)
        fibaro:setGlobal("RingToken", "")
      end
    end,
    error = function(error)
      errorlog("Error getting data (checkEvents): "..error)
      fibaro:setGlobal("RingToken", "")
    end
  })
end

function getDevices()
  log("Getting devices...") 
  local token = fibaro:getGlobal("RingToken") 
  token = json.decode(token)
  local headers = headers
  headers["Authorization"] = "Bearer " .. token["access_token"]
  local url = API_URI .. "/clients_api/ring_devices" 
  local http = net.HTTPClient()
  http:request(url,{
    options = {
      headers = headers,
      method = "GET"
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log(response.data)
--[[
        ---device_id = (response["doorbots"][0]["id"])

        local data = json.decode(response.data)
        local active = 0
        for k, v in pairs(data) do
          local action = v["kind"]
          infolog(os.date() .. ": " .. action)
          if action == "motion" then
            active = 1
          elseif action == "ding" then
            active = 2
          end
        end
        fibaro:setGlobal("Doorbell", active)
--]]
      else
        errorlog("Error HTTP status (getDevices): "..response.status)
        --fibaro:setGlobal("RingToken", "")
      end
    end,
    error = function(error)
      errorlog("Error getting data (getDevices): "..error)
      --ibaro:setGlobal("RingToken", "")
    end
  })
end

---Main

function main()
  local token, changed = fibaro:getGlobal("RingToken") 
  if token == "" then
    getToken(checkEvents)
  else
    token = json.decode(token)
    log(os.time() - changed .. " (" .. token["expires_in"] .. ")")
    if (os.time() - changed) >= token["expires_in"] then
      refreshToken(token, checkEvents)
    else
      checkEvents(token)
    end
  end
  setTimeout(function()
    xpcall(	function()
      main()
      end,
      function(err)
        errorlog("Fatal error: " .. err)
        fibaro:setGlobal("RingToken", "")
        return err 
      end
    )
    end,
    1000 * 10
  )     
end

-- check script instance count in memory 
if (tonumber(fibaro:countScenes()) > 1) then 
  log("Script already running.");
  fibaro:abort(); 
end

fibaro:debug("<font color='yellow'>".."Fibaro RING doorbell eventchecker started...".."</font>")
---fibaro:setGlobal("RingToken", "")
main()
--getDevices()
