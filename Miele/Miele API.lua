--[[
%% properties
%% events
%% globals
--]]

local debug = true;
local client_id = "CLIENT ID";
local client_secret = "CLIENT SECRRET";
local username	= "Miele EMAIL"
local password	= "Miele PASSWORD"
local vg = "nl-NL" -- The vg the users Miele account belongs to, choose from de-DE or en-EN
local language = "nl" -- choose fron de or en

--[[

Miele API
Created by Remko de Boer ©2018-2019

Description:
  API to interact with Miele household appliances
  https://www.miele.com/developer/index.html

Remarks:
  Only the washing machine is supported (it is the only thing I own), if you want
  other appliances supported, please provide me the debug output.

Prerequisite:
  clientID and clientSecret: https://www.miele.com/developer/getinvolved.html
  Globalvalue MieleToken

Arguments:
  None

Release notes:
  0.0.1 (20180928) Initial version
  0.0.2 (20181013) Login, Auth and GetToken functions added
  0.0.3 (20190725) Changed grant_type to password in getToken (Miele added this type)
                   Removed functions Login and Auth
  0.0.4 (20190726) Added Virtual Device
  1.0.0 (20190726) First release
  1.0.1 (20190726) Bug fix: when finoshed targetTemperature is a function
  1.1.0 (20190804) Receiving errors after a while so added refresh token, not ducmented,standarda in oAuth
  1.2.0 (20190816) Corrected some errormessage with correct function name

To do:
  Testing
	
--]]
local version = "1.1.0"

local base_url = "https://api.mcs3.miele.com/"
local unit = {["Celcius"] = "C",["Fahrenheit"] = "F"}

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function sendMessage(msg)
  local subject = "Miele API"
  fibaro:startScene(sendMessageID,{{false, {Remko["phoneid"]}},{true,{Remko["userid"]}},{false},{false, "100"},{false},subject,msg})
end

function addGlobal(vName, vValue)
  data = json.encode({ name = vName, value = vValue })
  http:request("http://127.0.0.1:11111/api/globalVariables", { 
    options = {
      method = 'POST', 
      headers = { 
        ['Content-Type'] = 'application/json'
      },
      data = data,
      timeout =  5000
    }, 
    success = function(response)
      if response.status == 200 or response.status == 201 then
        log("Added variable: "..vName..", value: "..vValue)
      else
        errorlog("Error HTTP status (addGlobal): "..response.status);
          log(response.data)
      end
    end,
    error = function(err) 
      errorlog("Error getting data (addGlobal): "..err)
    end
  })
end

function matchDevices(Identifier)
  devices = {}
  http:request('http://127.0.0.1:11111/api/virtualDevices', {
    options = {
      method = 'GET'
    },
    success = function(response)
      if response.status == 200 or response.status == 201 then
        local devices = json.decode(response.data)
        for i, v in pairs(devices) do
          if (v.properties.ip == Identifier) then       
            local vName = Identifier
            local vValue = tostring(v.id)
            
            if (fibaro:getGlobalValue(vName) == nil) then
              addGlobal(vName, vValue)
              fibaro:setGlobal(vName, vValue)
            end
          end
        end
      else
        errorlog("Error HTTP status (matchDevices): "..response.status);
      end
    end,
    error = function(err)
      errorlog("Error matching devices (matchDevices): ".. err)
    end
  })
end

function getToken(client_id, client_secret, username, password)
  log("Getting token...")
  url = base_url.."thirdparty/token/"
  data = "client_id="..client_id.."&client_secret="..client_secret.."&username="..username.."&password="..password.."&grant_type=password&vg="..vg
  http:request(url, {
    options = {
      method = 'POST',
      data = data,
      checkCertificate = false,
      headers = {
        ['Accept']='application/json; charset=utf-8',
        ['Content-Type']='application/x-www-form-urlencoded '        
      },        
    }, 
    success = function(response)	
      if response.status == 200 or response.status == 201 then
        log(response.data)
        --log(json.decode(response.data)['access_token'])
        fibaro:setGlobal("MieleToken", response.data)
        --getDevices(json.decode(response.data)['access_token'])
        getDevices(json.decode(response.data))
      else
        errorlog("Error HTTP status (getToken): "..response.status);
        log(response.data)
        sendMessage("Error HTTP status (getToken): "..response.status)

        --fibaro:setGlobal("MieleToken", "")
      end
    end,
    error = function(err)
      errorlog("Error getting data (getToken): "..err)
      sendMessage("Error getting data (getToken): "..err)
      --fibaro:setGlobal("MieleToken", "")
    end
  })
end

function refreshToken(token)
  log("Refreshing token...")
  url = base_url.."thirdparty/token/"
  data = "client_id="..client_id.."&client_secret="..client_secret.."&refresh_token="..token["refresh_token"].."&grant_type=refresh_token&vg="..vg
  http:request(url, {
    options = {
      method = 'POST',
      data = data,
      checkCertificate = false,
      headers = {
        ['Accept']='application/json; charset=utf-8',
        ['Content-Type']='application/x-www-form-urlencoded '        
      },        
    }, 
    success = function(response)	
      if response.status == 200 or response.status == 201 then
        log(response.data)
        --log(json.decode(response.data)['access_token'])
        fibaro:setGlobal("MieleToken", response.data)
        getDevices(json.decode(response.data)['access_token'])
      else
        errorlog("Error HTTP status (refreshToken): "..response.status);
        log(response.data)
        sendMessage("Error HTTP status (refreshToken): "..response.status)
        --fibaro:setGlobal("MieleToken", "")
      end
    end,
    error = function(err)
      errorlog("Error getting data (refreshToken): "..err)
      sendMessage("Error getting data (refreshToken): "..err)
      --fibaro:setGlobal("MieleToken", "")
    end
  })
end

function getDevices(token)
  log("Get devices...")
  url = base_url.."v1/devices/?language="..language
  http:request(url, {
    options = {
      method = 'GET',
      headers = {
        ['Accept']='application/json; charset=utf-8',
        ['Authorization']='Bearer '..token["access_token"]
      },
      checkCertificate = false
    },
    success = function(response)	
      if response.status == 200 or response.status == 201 then
        --log(response.data)
        jsonTable = json.decode(response.data)
        for deviceId, v in pairs(jsonTable) do
          virt_deviceId = "miele"..deviceId
          did = matchDevices(virt_deviceId)
          local VirtualDevice = fibaro:getGlobalValue(virt_deviceId)
          if (VirtualDevice ~= nil) then
            log("Corresponding Fibaro virtual device is " ..VirtualDevice)
            -- Washing Machine
            if jsonTable[deviceId].ident.type.value_raw == 1 then
              fibaro:call(VirtualDevice, "setProperty", "ui.lblName.value", jsonTable[deviceId].ident.deviceName)     
              fibaro:call(VirtualDevice, "setProperty", "ui.lbltechType.value", jsonTable[deviceId].ident.deviceIdentLabel.techType)     
              fibaro:call(VirtualDevice, "setProperty", "ui.lblStatus.value", jsonTable[deviceId].state.status.value_localized)
              fibaro:call(VirtualDevice, "setProperty", "ui.lblprogramType.value", jsonTable[deviceId].state.programType.value_localized)
              if jsonTable[deviceId].state.targetTemperature[1].value_raw ~= -32768 then
                fibaro:call(VirtualDevice, "setProperty", "ui.lbltargetTemp.value", jsonTable[deviceId].state.targetTemperature[1].value_localized.." "..jsonTable[deviceId].state.targetTemperature[1].unit);
              else
                fibaro:call(VirtualDevice, "setProperty", "ui.lbltargetTemp.value","")
              end
              fibaro:call(VirtualDevice, "setProperty", "ui.lblspinningSpeed.value", jsonTable[deviceId].state.spinningSpeed)
              fibaro:call(VirtualDevice, "setProperty", "ui.lblprogramPhase.value", jsonTable[deviceId].state.programPhase.value_localized)
              fibaro:call(VirtualDevice, "setProperty", "ui.lblelapsedTime.value", jsonTable[deviceId].state.elapsedTime[1]..":"..string.format("%02d",jsonTable[deviceId].state.elapsedTime[2]))
              fibaro:call(VirtualDevice, "setProperty", "ui.lblremainingTime.value", jsonTable[deviceId].state.remainingTime[1]..":"..string.format("%02d",jsonTable[deviceId].state.remainingTime[2]))
            end  
          else
            msg = "Found the following Miele appliance "..jsonTable[deviceId].ident.type.value_localized .. ": " .. jsonTable[deviceId].ident.deviceName .." ("..deviceId..")"
            log(msg)
          end
          fibaro:call(VirtualDevice, "setProperty", "ui.lblLastUpdate.value", os.date("%c"))
          fibaro:call(VirtualDevice, "setProperty", "ui.lblError.value", "")
        end
      else
        errorlog("Error HTTP status (getDevices): "..response.status);
        sendMessage("Error HTTP status (getDevices): "..response.status)
        --fibaro:setGlobal("MieleToken", "")
      end
    end,
    error = function(err)
      errorlog("Error getting data (getDevices): "..err)
      sendMessage("Error getting data (getDevices): "..err)
      --fibaro:setGlobal("MieleToken", "")
    end
  })      
end

-- Main
http = net.HTTPClient()

local token, changed = fibaro:getGlobal("MieleToken")
if token == "" then
  getToken(client_id, client_secret, username, password)
else
  token = json.decode(token)
  log(os.time() - changed .. " (" .. token["expires_in"] .. ")")
  if (os.time() - changed) >= token["expires_in"] then
    refreshToken(token)
  else
    getDevices(token)
  end
end


-- End script



