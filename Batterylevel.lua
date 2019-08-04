--[[
%% autostart
%% properties
%% events
%% globals
--]]
local debug = true;
local batteryCheckTime = "01:00"; -- Time to check the Battery Level
local batteryCheckDays = {1,2,3,4,5,6,7}; -- Days to chech the Battery Level: 1 = Sunday, 2 = Monday, etc
local minbatteryLevel = 20; -- Set your minimum Battery Level here
local Remko = json.decode(fibaro:getGlobalValue("Remko"))
local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

local function checkBattery()
  log("Check Battery Level: " .. os.date())
  ids = fibaro:getDevicesId({visible = true, interfaces ={"battery"}})
  for i,dID in ipairs(ids) do
    batterylevel = fibaro:getValue(dID, "batteryLevel")
    local name = fibaro:getName(dID);
    local room = fibaro:getRoomNameByDeviceID(dID);
    log("Device "..dID..": "..name.." ("..room.."), battery level="..batterylevel) 
    if (tonumber(batterylevel) < minbatteryLevel) then
      ttl = "Low Battery Level"
      msg = "Low battery on: Device "..dID..": "..name.." ("..room.."), battery level="..batterylevel
      --fibaro:call(2, "sendEmail", ttl, msg);
      fibaro:startScene(sendMessageID,{{false, {Remko["phoneid"]}},{true,{Remko["userid"]}},{false, "0"},{false, "100"},{false},ttl,msg})
     end
  end
end

local sourceTrigger = fibaro:getSourceTrigger();
if (sourceTrigger["type"] == "autostart") then

  -- check script instance count in memory 
  if (tonumber(fibaro:countScenes()) > 1) then 
    log("Script already running."); 
    fibaro:abort(); 
  end

  log("HC2 start script at " .. os.date())

  while true do
    local currentDate = os.date("*t");
    local currentTime = os.date("%H:%M");
    
    local dayCheck = false;
    local dayid;
    for i = 1, #batteryCheckDays do
      dayid = batteryCheckDays[i];
      if ( currentDate.wday == dayid )
      then
        dayCheck = true;
      end
    end      

    if ( (batteryCheckTime == currentTime) and dayCheck )
    then
      checkBattery()
    end
    fibaro:sleep(60*1000); 
  end
else
  checkBattery()
end
