--[[
%% properties
%% events
%% globals
--]]
local debug = true
local exclude = __fibaroSceneId --47 -- own scene id
local Remko = json.decode(fibaro:getGlobalValue("Remko"))
local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))

--> Do not change -->

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

log("Scene started at " .. os.date("%d-%m-%Y"));

log("Checking Scenes")
local found = false
local scenes = api.get('/scenes',{["enabled"]=true, ["runConfig"]="TRIGGER_AND_MANUAL", ["runConfig"]="MANUAL_ONLY"})
for s = 1, #scenes do
  if tonumber(scenes[s]['id']) ~= exclude and fibaro:getRoomNameByDeviceID(scenes[s]['id']) ~= "unassigned" then    
    debugMessages = api.get('/scenes/'..scenes[s]['id']..'/debugMessages')
    if #debugMessages > 0 then
      for d = 1, #debugMessages do
        if (debugMessages[d]['type'] == "ERROR" or string.find(string.lower(debugMessages[d]['txt']), "error") ~= nil) and debugMessages[d]['txt'] ~= "Cannot query interpreter state" then
          log(scenes[s]['name'].." ("..scenes[s]['id']..")")
          msg = "Error in scene: "..scenes[s]['name'].." ("..scenes[s]['id']..")"
          fibaro:startScene(sendMessageID,{{false, {Remko["phoneid"]}},{true,{Remko["userid"]}},{false},{false, "100"},{false},"Watchdog",msg})
          log(debugMessages[d]['txt'].." ("..os.date("%c", debugMessages[d]['timestamp'])..")")
          found = true
          break
        end
      end
    end
  end
end
log("Scene errors found: "..tostring(found))

log("Checking VDs")
local found = false
local vds = api.get('/virtualDevices',{["enabled"]=true})
for v = 1, #vds do
  debugMessages = api.get('/virtualDevices/'..vds[v]['id']..'/debugMessages')
  if #debugMessages > 0 then
    for d = 1, #debugMessages do
      if (debugMessages[d]['type'] == "ERROR" or string.find(string.lower(debugMessages[d]['txt']), "error") ~= nil) and debugMessages[d]['txt'] ~= "Cannot query interpreter state" then
        log(vds[v]['name'].." ("..vds[v]['id']..")")
        msg = "Error in VD: "..vds[v]['name'].." ("..vds[v]['id']..")"
        fibaro:startScene(sendMessageID,{{false, {Remko["phoneid"]}},{true,{Remko["userid"]}},{false},{false, "100"},{false},"Watchdog",msg})
        log(debugMessages[d]['txt'].." ("..os.date("%c", debugMessages[d]['timestamp'])..")")
        found = true
        break
      end
    end
  end
end
log("VD errors found: "..tostring(found))

log("Scene finished")
