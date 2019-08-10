--[[
%% properties
%% events
%% globals
--]]

local debug = true; -- Enable debug yes/no
local username = "EMAIL" -- Evohome username
local password = "PASSWORD" -- Evohome password
local main_id = {1376}; -- ID of Evohome VD's, one for every location, starting with the ID of location 0 
local zones_name = {"Room1","Room2","Room2","Bathroom","Hallway","Master","Kidsroom","Kitchen"}; -- Name of all zones (in all locations)
local zones_id = {1403,1377,1409,1404,1405,1406,1407,1408}; -- ID of all zones (in all locations)

--
-- Evohome API
-- Created by Remko de Boer
-- Inspired by https://github.com/watchforstock/evohome-client and http://www.automatedhome.co.uk/vbulletin/showthread.php?3863-Decoded-EvoHome-API-access-to-control-remotely
--
-- Release notes:
-- 3.0.0 (20160805) Initial version
-- 3.0.1 (20160805) Some error checking added
-- 3.0.2 (20160806) Fixed a typing mistake in DHW function
-- 3.0.3 (20160806) Better error messages HTTP status (non functional)
-- 3.0.4 (20160806) Fixed some DHW stuff
-- 3.0.5 (20160821) Added some DHW information
-- 3.0.6 (20160821) Fixed DHW error
-- 3.0.6a (20160821) DHW: case sensitive, names not according documentation
-- 3.0.7 (20160821) DHW: fixed procedure
-- 3.0.7a (20160821) DHW: fixed procedure
-- 3.0.8 (20160821) DHW: reverted fixes 3.0.7,clean up code
-- 3.0.9 (20170302) Fixed bug with duration in set mode
-- 3.1.0 (20170306) Line 280 and beyond: Added Faultstatus -- BETA
-- 3.1.1 (20170429) Automaticcaly create Global Variable EvohomeAPI
-- 3.1.2 (20170922) Changed way to fill ApplicationID 
-- 3.2.1 (20171215) Removed application_id and a new way to authenticate
-- 3.2.2 (20171215) Changed some parameters corresponding the new authentication
-- 3.2.3 (20171215) Fixed a bug with TargetTemperature (new name)
-- 3.2.4 (20171215) Cleaned up some code
-- 3.2.5 (20171215) Fixed bug another with TargetTemperature
--
-- To do:
--   test Locations
--
local version = "3.2.5"
local evohome_url = "https://tccna.honeywell.com/WebAPI/emea/api/v1/"

-- Functions ---
function log(str) if debug then fibaro:debug(tostring(str)); end; end

function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

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

function tomorrow()
	local datetime = os.time();
	tomorrow = os.date("%Y-%m-%d", datetime+24*60*60)
	return tomorrow    
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
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

-- create global var
function globalVar(var, value)
	local http = net.HTTPClient() 
	http:request("http://127.0.0.1:11111/api/globalVariables", { 
		options = { 
			method = 'POST', 
			headers = {}, 
			data = '{"name":"'..var..'","value":"'..value..'"}', 
			timeout = 2000
		}, 
		success = function(status)
			fibaro:debug(status.status)
			if status.status ~= 200 and status.status ~= 201 then
				errorlog("Creating variable "..var.." failed: "..status.status);
			end
			log("Creating variabale "..var.." succeeded: "..status.data);
		end,
		error = function(err) 
			errorlog("Creating variable "..var.." failed: " .. err) 
		end 
	}) 
end

-- Reset global value --
function resetEvohomeAPI()
	fibaro:setGlobal("EvohomeAPI", "0")
end

-- OAToken
function GetOAuth(actiontype,action,location,zone,temperature,duration)
	url = 'https://tccna.honeywell.com/Auth/OAuth/Token'
	headers = {
		  ['Authorization']='Basic NGEyMzEwODktZDJiNi00MWJkLWE1ZWItMTZhMGE0MjJiOTk5OjFhMTVjZGI4LTQyZGUtNDA3Yi1hZGQwLTA1OWY5MmM1MzBjYg==',
		  ['Accept']='application/json, application/xml, text/json, text/x-json, text/javascript, text/xml'
	}
	data = {
		['Content-Type']='application/x-www-form-urlencoded; charset=utf-8',
		['Host']='tccna.honeywell.com/',
		['Cache-Control']='no-store no-cache',
		['Pragma']='no-cache',
		['grant_type']='password',
		['scope']='EMEA-V1-Basic EMEA-V1-Anonymous EMEA-V1-Get-Current-User-Account',
		['Username']=username,
		['Password']=password,
		['Connection']='Keep-Alive'
	}

	selfhttp:request(url, {
		options={
			headers = headers,
			data = keyValToBody(data),
			method = 'POST',
			timeout = 5000
		},
		success = function(status)
			 if status.status == 200 or status.status == 201 then
				 status.data = trim(status.data)
				 userData = json.decode(status.data)
				
	       for k,v in pairs(userData) do
		      log(k .."="..v)
	       end
				
				 access_token = userData['access_token']
				 headers = {
					   ['Authorization']='bearer ' .. access_token,
				     ['Accept']='application/json, application/xml, text/json, text/x-json, text/javascript, text/xml'
				 }
				 GetUserData(headers, actiontype, action, location, zone, temperature, duration)
			 else
				 errorlog("Error HTTP status (GetOAuth): "..status.status)
				 resetEvohomeAPI()
			 end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (GetOAuth): "..error)
				resetEvohomeAPI()
		end
	})
end

-- Populate userdata --
function GetUserData(headers,actiontype,action,location,zone,temperature,duration)
	url = evohome_url..'userAccount'

	for k,v in pairs(headers) do
		 log(k .."="..v)
	end
	
	selfhttp:request(url, {
		options={
			headers = headers,
			method = 'GET',
			timeout = 5000
		},
		success = function(status)
			 if status.status == 200 or status.status == 201 then
				 status.data = trim(status.data)
				 account_info = json.decode(status.data)
				 GetInstallationData(headers,account_info, actiontype, action, location, zone, temperature, duration)
			 else
				 errorlog("Error HTTP status (GetUserData): "..status.status)
				 resetEvohomeAPI()
			 end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (GetUserData): "..error)
				resetEvohomeAPI()
		end
	})
end

-- Populate fulldata --
function GetInstallationData(headers, account_info, actiontype, action, location, zone, temperature, duration)
	url = evohome_url..'location/installationInfo?userId='..account_info['userId']..'&includeTemperatureControlSystems=True'

	if not location then location = "0" end
 
	selfhttp:request(url, {
		options={
			headers = headers,
			method = 'GET',
			timeout = 5000
		},
		success = function(status)
			 if status.status == 200 or status.status == 201 then
				 installation_info = json.decode(status.data)
				 GetFullData(headers, installation_info, account_info, actiontype, action, location, zone, temperature, duration)
			 else
				 errorlog("Error HTTP status (GetInstallationData): "..status.status)
				 resetEvohomeAPI()
			 end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (GetInstallationData): "..error);
				resetEvohomeAPI()
		end
	})
end

-- Populate fulldata --
function GetFullData(headers, installation_info, account_info, actiontype, action, location, zone, temperature, duration)
	if not location then location = "0" end

	system_id = installation_info[tonumber(location)+1]['gateways'][1]['temperatureControlSystems'][1]['systemId']
	print(system_id)
 
	url = evohome_url..'temperatureControlSystem/'..system_id..'/status'
 
	selfhttp:request(url, {
		options={
			headers = headers,
			method = 'GET',
			timeout = 5000
		},
		success = function(status)
				fullData = json.decode(status.data)

				zones = {}
				named_zones = {}
				for i = 1, #fullData['zones'] do
					zones[fullData['zones'][i]['zoneId']] = fullData['zones'][i]
					named_zones[fullData['zones'][i]['name']] = fullData['zones'][i]
				end
				
				--print(json.encode(zones))
				
				if fullData['dhw'] ~= nil then
					dhw = fullData['dhw']
					print(json.encode(dhw))
				else
					log("No DHW in system")
				end
							 
				log(actiontype)
				
				if actiontype == "_update_vd" then
					_update_vd(headers,installation_info, fullData, location)
				elseif actiontype == "_set_status" then
					_set_status(headers,installation_info, fullData, action, location, duration)
				elseif actiontype == "_set_temperature" then
					_set_temperature(headers,installation_info, fullData, location, zone, named_zones[zone]['zoneId'], temperature, duration)
				elseif actiontype == "_cancel_temp_override" then
					_cancel_temp_override(headers,installation_info, fullData, location, zone, named_zones[zone]['zoneId'])
				elseif actiontype == "_set_dhw" then
					_set_dhw(headers,installation_info, fullData, action, location, dhw['dhwId'], duration)          
				else
					errorlog("Invalid actiontype given: "..actiontype);
					resetEvohomeAPI()
				end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (GetFullData): "..error);
				resetEvohomeAPI()
		end
	})
end

-- Update labels of Evohome VDs --
function _update_vd(headers, installation_info, fullData, location)
	local overview = "";
	zones = fullData['zones']
	if fullData['dhw'] ~= nil then dhw = fullData['dhw'] end
	for j=1, #zones_name do
		if zones_name[j] ~= "" then
			for i=1, #zones do
				if zones[i]['name'] == zones_name[j] then
					fibaro:call(zones_id[j], "setProperty", "ui.lblTempSet.value", tostring(zones[i]['setpointStatus']['targetHeatTemperature']).." ")
					fibaro:call(zones_id[j], "setProperty", "ui.lblStatus.value", tostring(zones[i]['temperatureStatus']['isAvailable']))
					overview = overview .. zones_name[j] .. ": " .. tostring(zones[i]['temperatureStatus']['temperature']).." ("..tostring(zones[i]['setpointStatus']['targetHeatTemperature'])..") °C <br />"
					fibaro:call(zones_id[j], "setProperty", "ui.lblTempCurrent.value", tostring(zones[i]['temperatureStatus']['temperature']).." ")
					fibaro:call(zones_id[j], "setProperty", "ui.lblMode.value", tostring(zones[i]['setpointStatus']['setpointMode']))
					fibaro:call(zones_id[j], "setProperty", "ui.lblError.value", "")
				end
			end
		else
			-- Hot water:
			fibaro:call(zones_id[j], "setProperty", "ui.lblStatus.value", tostring(dhw['stateStatus']['state']))
			fibaro:call(zones_id[j], "setProperty", "ui.lblMode.value", tostring(dhw['stateStatus']['mode']))
			fibaro:call(zones_id[j], "setProperty", "ui.lblTempCurrent.value", tostring(dhw['temperatureStatus']['temperature']))
			overview = overview .. "DHW: " .. tostring(dhw['temperatureStatus']['temperature']).." °C <br />"
			fibaro:call(zones_id[j], "setProperty", "ui.lblError.value", "")
		end
	end
	fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblOverview.value", overview)
 
	action = tostring(fullData['systemModeStatus']['mode'])
	if action == "AutoWithEco" then action = "Eco" end
	fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblQuickActions.value", action)
	fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lbllastUpdate.value", os.date("%c"))
	fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "");
-- Added something new
	if fullData['systemModeStatus']['activeFaults'] ~= nil then
		faultstatus = ""
		for i=1, #fullData['systemModeStatus']['activeFaults'] do
			faultstatus = faultstatus .. " " .. tostring(fullData['systemModeStatus']['activeFaults'][i]['faultType'])
		end
		fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblStatus.value", faultstatus)
	else
		fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblStatus.value", "OK")    
	end
	log("Success: New data loaded")
end

--
-- Get state of action --
function _get_task_status(fullData, task_id, location)
	url = evohome_url..'commTasks?commTaskId='..task_id
	fibaro:sleep(5000)
	-- Update VD labels
	resetEvohomeAPI()
	fibaro:call(main_id[tonumber(location)+1], "pressButton", "9");
end

-- Set status of QuickAction --
function _set_status(headers, installation_info, fullData, action, location, duration)
 
	if not location then location = "0" end
	system_id = installation_info[tonumber(location)+1]['gateways'][1]['temperatureControlSystems'][1]['systemId']
	log(system_id)

	headers['Content-Type'] = 'application/json'
	url = evohome_url..'temperatureControlSystem/'..system_id..'/mode'
 
	if duration == "" or duration == nil then
		data = {['SystemMode']=action,['Permanent']=true,['TimeUntil']=None}
	else
		data = {['SystemMode']=action,['Permanent']=false,['TimeUntil']=duration}
	end
		
	selfhttp:request(url, {
		options={
			headers = headers,
			data = json.encode(data),
			method = 'PUT',
			timeout = 5000
		},
		success = function(status)
				print(status.data)
				if (status.status == 200 or status.status == 201) then
					statusData = json.decode(status.data)
					task_id = statusData['id']
					_get_task_status(statusData, task_id, location)
				else
					errorlog("Error HTTP status (_set_status): "..status.status)
					resetEvohomeAPI()
				end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (_set_status): "..error);
				resetEvohomeAPI()
		end
	})  
end

-- Set heat setpoint --
function _set_heat_setpoint(headers, installation_info, fullData, zone, location, device_id, data)
	log("device_id: "..device_id)
	url = evohome_url..'temperatureZone/'..device_id..'/heatSetpoint'
	headers['Content-Type'] = 'application/json'
	selfhttp:request(url, {
		options={
			headers = headers,
			data = json.encode(data),
			method = 'PUT',
			timeout = 5000
		},
		success = function(status)
				print(status.data)
				if (status.status == 200 or status.status == 201) then
					statusData = json.decode(status.data)        
					task_id = statusData['id']
					_get_task_status(statusData, task_id, location)
				else
					errorlog("Error HTTP status (_set_heat_setpoint): "..status.status)
					resetEvohomeAPI()
				end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (_set_heat_setpoint): "..error);
				resetEvohomeAPI()
		end
	})
end

-- Set temperature --
function _set_temperature(headers, installation_info, fullData, location, zone, device_id, temperature, duration)
	time = tomorrow() .. " 00:15:00"
	if duration == "" or duration == nil then
		data = {['HeatSetpointValue']=temperature,['SetpointMode']='PermanentOverride',['TimeUntil']=None}
	else
		data = {['HeatSetpointValue']=temperature,['SetpointMode']='TemporaryOverride',['TimeUntil']=duration}
	end
	print(json.encode(data))
	_set_heat_setpoint(headers, installation_info, fullData, zone, location, device_id, data)
end

-- Cancel temperature --
function _cancel_temp_override(headers, installation_info, fullData, location, zone, device_id)
	data = {['HeatSetpointValue']=0.0,['SetpointMode']='FollowSchedule',['TimeUntil']=None}
	_set_heat_setpoint(headers, installation_info, fullData, zone, location, device_id, data)
end

-- Set status of DHW --
function _set_dhw(headers, installation_info, fullData, action, location, device_id, duration)
	headers['Content-Type'] = 'application/json'
	if (action == "None") then
		data = {['State']="",['Mode']='FollowSchedule',['UntilTime']=None}
	elseif (action == "DHWOn") then
		if duration == "" or duration == nil then
			data = {['State']='On',['Mode']='PermanentOverride',['UntilTime']=None}
		else
			data = {['State']='On',['Mode']='TemporaryOverride',['UntilTime']=duration}
		end
	elseif (action == "DHWOff") then
		if duration == "" or duration == nil then
			data = {['State']='Off',['Mode']='PermanentOverride',['UntilTime']=None}
		else
			data = {['State']='Off',['Mode']='TemporaryOverride',['UntilTime']=duration}
		end
	end
	url = evohome_url..'domesticHotWater/'..device_id..'/state'
	selfhttp:request(url, {
		options={
			headers = headers,
			data = json.encode(data),
			method = 'PUT',
			timeout = 5000
		},
		success = function(status)
				print(status.data)
				if (status.status == 200 or status.status == 201) then
					statusData = json.decode(status.data)
					task_id = statusData['id']
					_get_task_status(statusData, task_id, location)
				else
					errorlog("Error HTTP status (_set_dhw): "..status.status)
					resetEvohomeAPI()
				end
		end,
		error = function(error)
				fibaro:call(main_id[tonumber(location)+1], "setProperty", "ui.lblError.value", "Error getting data")
				errorlog("Error getting data (_set_dhw): "..error);
				resetEvohomeAPI()
		end
	})
end

-- Main --
local trigger = fibaro:getSourceTrigger();
if (trigger['type'] == 'other') then
	EvohomeAPI = fibaro:getGlobalValue("EvohomeAPI")
	currentDate = os.date("*t");
	selfhttp = net.HTTPClient({timeout=2000})
	if (EvohomeAPI ~= nil and string.len(EvohomeAPI)>0) then

		--Prevents the scene from running again when the Global EvohomeAPI variable get's reset to 0 the end of this scene
		if (tonumber(EvohomeAPI) == 0) then
			log("EvohomeAPI set to 0, so aborting")
			fibaro:abort();
		end
		log("EvohomeAPI: "..EvohomeAPI)
		
		local result = split(EvohomeAPI, ",");
		if #result == 6 then
			local actiontype = result[1]
			log("actiontype: "..actiontype)
			local action = result[2]
			log("action: "..action)
			local location = result[3]
			log("location: "..location)
			local zone = result[4]
			log("zone: "..zone)
			local temperature = result[5]
			log("temperature: "..temperature)
			local duration = result[6]
			log("duration: "..duration)
			-- update VD
			if actiontype == "update" then
				GetOAuth("_update_vd", action, location, zone, temperature, duration)
			-- Set QuickAction
			elseif actiontype == "mode" then
				if (action == "Auto") or (action == "Custom") or (action == "AutoWithEco") or (action == "Away") or (action == "DayOff") or (action == "HeatingOff") then
					GetOAuth("_set_status", action, location, zone, temperature, duration)
				else
					errorlog("No valid action given: "..action)
				end
			-- Set Temperature
			elseif actiontype == "settemp" then
				GetOAuth("_set_temperature", action, location, zone, temperature, duration)
			-- Cancel Temperature
			elseif actiontype == "cancel" then
				GetOAuth("_cancel_temp_override", action, location, zone, temperature, duration)
			-- Set DHW
			elseif actiontype == "dhw" then
				if (action == "DHWOn") or (action == "DHWOff") or (action == "None") then
					GetOAuth("_set_dhw", action, location, zone, temperature, duration)
				else
					errorlog("No valid action given: "..action)
				end
			else
				errorlog("No valid actiontype given: "..actiontype)
			end
		else
			errorlog("Corrupted variable EvohomeAPI: "..EvohomeAPI)
		end
	else
		errorlog("No variable EvohomeAPI")
		log("Creating variable EvohomeAPI")
		globalVar("EvohomeAPI", "0")
	end
	resetEvohomeAPI()
else
	log("Only run by start scene")
end

