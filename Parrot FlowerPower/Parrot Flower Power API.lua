--[[
%% properties
%% events
%% globals
--]]

local firstrun = false;
local debug = true; -- Enable debug yes/no

local username = 'USERNAME'
local password = 'PASSWORD'
local client_id = "API USERNAME" -- Parrot API username
local client_secret = "CLIENT SECRET" -- Parrot API password
local main_id = {407}; -- ID of Parrot VD's
local location_id = {'LOCATIONID'}
--
-- Parrot Flower Power API
-- Created by Remko de Boer
--
-- Release notes:
-- 0.0.1 (20160710) Initial version
-- 0.0.2 (20170503) New URL, secret and values
--
local version = "0.0.2"
local api_url = "https://api-flower-power-pot.parrot.com"

-- Functions ---
function log(str) if debug then fibaro:debug(str); end; end

function errorlog(str) fibaro:debug("<font color='red'>"..str.."</font>"); end

function split(s, pattern, maxsplit)
  local pattern = pattern or ' '
  local maxsplit = maxsplit or -1
  local s = s
  local t = {}
  local patsz = #pattern
  while maxsplit ~= 0 do
    local curpos = 1
    local found = string.find(s, pattern)
    if found ~= nil then
      table.insert(t, string.sub(s, curpos, found - 1))
      curpos = found + patsz
      s = string.sub(s, curpos)
    else
      table.insert(t, string.sub(s, curpos))
      break
    end
    maxsplit = maxsplit - 1
    if maxsplit == 0 then
      table.insert(t, string.sub(s, curpos - patsz - 1))
    end
  end
  return t
end

function round(val, decimal)
  if (decimal) then
    if (val > 0) then
      return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
    else
      return math.ceil( (val * 10^decimal) - 0.5) / (10^decimal)
    end
  else
    if (val > 0) then
      return math.floor(val+0.5)
    else
      return math.ceil(val-0.5)
    end
  end
end

function tomorrow()
  local datetime = os.time();
  tomorrow = os.date("%Y-%m-%d", datetime+24*60*60)
  return tomorrow    
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function urlencode(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w ])",
      function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

-- Turn key/value pairs into key1=value1&key2&value2&...
-- And encode euch key and value to remove spaces, & etcetera.
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

-- Authentication --
function Authentication()
  url = api_url..'/user/v1/authenticate'

  postdata = {['grant_type']='password',['username']=username,['password']=password,['client_id']=client_id,['client_secret']=client_secret}
  
  selfhttp:request(url, {
    options={
      headers= {
		    ['content-type'] = 'application/x-www-form-urlencoded',
	  },
      data = keyValToBody(postdata),
      method = 'GET',
      timeout = 5000
    },
    success = function(status)
       if status.status == 200 then
         local isOk, userData = pcall(json.decode,status.data)
         --status.data = trim(status.data)
         --log(status.data)
         --userData = json.decode(status.data)
         if (isOk == false) then
            errorlog("Error invalid JSON (Authentication)")
		 else
            getSensorData(userData['access_token'])
         end
       else
         errorlog("Error status (Authentication): "..status.status)
       end
    end,
    error = function(error)
        fibaro:call(main_id[1], "setProperty", "ui.lblError.value", "Error getting data")
        errorlog("Error getting data (Authentication): "..error)
    end
  })
end

-- getSensorData --
function getSensorData(access_token)
  --url = api_url..'/sensor_data/v4/garden_locations_status'
  url = api_url..'/garden/v1/status'
  
  selfhttp:request(url, {
    options={
      headers= {
		    ['Authorization'] = 'Bearer '..access_token,
	  },
      method = 'GET',
      timeout = 5000
    },
    success = function(status)
--        log(status.data)
         local isOk, fullData = pcall(json.decode,status.data)
         --status.data = trim(status.data)
         --log(status.data)
         --userData = json.decode(status.data)
         if (isOk == false) then
            errorlog("Error invalid JSON (getSensorData)")
		 else
           if firstrun then
            locations = fullData['locations']
            location_row = "{"
            for location=1, #locations do
              if location > 1 then
                location_row = location_row .. ","
              end
              location_row = location_row .. "'" .. locations[location]['location_identifier'] .. "'"
            end
            location_row = location_row .. "}"
            log(location_row)
          else
            log("Updating...")
            _update_vd(fullData)
          end
        end
    end,
    error = function(error)
        fibaro:call(main_id[1], "setProperty", "ui.lblError.value", "Error getting data")
        errorlog("Error getting data (getSensorData): "..error);
    end
  })
end

-- Update labels of Parrot Flower Power VDs --
function _update_vd(fullData)
  local overview = "";
  locations = fullData['locations']
  for location=1, #locations do
    for j=1, #location_id do
      if locations[location]['location_identifier'] == location_id[j] then
        log(location_id[j])
        log(locations[location]['air_temperature']['gauge_values']['current_value'])
        fibaro:call(main_id[j], "setProperty", "ui.lblTemperature.value", tostring(round(locations[location]['air_temperature']['gauge_values']['current_value'],2)).." ")
        
        log(locations[location]['fertilizer']['gauge_values']['current_value'])
        if locations[location]['fertilizer']["instruction_key"] ~= "fertilizer_unavailable" then
          fibaro:call(main_id[j], "setProperty", "ui.lblFertilizer.value", tostring(round(locations[location]['fertilizer']['gauge_values']['current_value'],2)).." ")
        else
          fibaro:call(main_id[j], "setProperty", "ui.lblFertilizer.value", "Not available")
        end 
        
        log(locations[location]['light']['gauge_values']['current_value'])
        fibaro:call(main_id[j], "setProperty", "ui.lblSunlight.value", tostring(round(locations[location]['light']['gauge_values']['current_value'],2)).." ")
           
        log(locations[location]['watering']['soil_moisture']['gauge_values']['current_value'])
 
        fibaro:call(main_id[j], "setProperty", "ui.lblMoisture.value", tostring(round(locations[location]['watering']['soil_moisture']['gauge_values']['current_value'],2)).." ")
        fibaro:call(main_id[j], "setProperty", "ui.lbllastUpdate.value", os.date("%c"))
        fibaro:call(main_id[j], "setProperty", "ui.lblError.value", "");
      end
    end
  end
  log("Success: New data loaded")
end

-- Main --
local trigger = fibaro:getSourceTrigger();
if (trigger['type'] == 'other') then
  selfhttp = net.HTTPClient({timeout=5000})
  Authentication();
else
  log("Only run by start scene")
end


