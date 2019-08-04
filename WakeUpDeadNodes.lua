--[[ 
 %% autostart 
 %% globals 
--]] 
local debug = true; 
local repeatTime = 15; -- in minutes
local maxemail = 3;
local Remko = json.decode(fibaro:getGlobalValue("Remko"))
local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))

local function log(str) if debug then fibaro:debug(str); end; end

function checkDead()
  local id, msg;
  local anyDead = false;
  local ids = fibaro:getDevicesId({visible = true, properties = {dead=true}})
  for i,id in ipairs(ids) do
    local msg = "Device (" .. fibaro:getName(id) .. " ID:" .. id .. ", " .. fibaro:getRoomNameByDeviceID(id) ..") is flagged as dead node." 
    log(msg)
    if ( counter <= tonumber(maxemail) ) then
      local ttl = "Dead nodes!"
      local sound = "none"
      --fibaro:call(2, "sendEmail", ttl, msg);
      fibaro:startScene(sendMessageID,{{true, {Remko["phoneid"]}},{true,{Remko["userid"]}},{false, "0"},{false, "100"},{false},ttl,msg})
    end
    anyDead = true; 
  end
  if anyDead then
    counter = counter + 1;
    fibaro:call(1, 'wakeUpAllDevices');
  else
    counter = 0
    log(os.date() .. ": No dead devices found.")
  end
end 

local sourceTrigger = fibaro:getSourceTrigger();
if (sourceTrigger["type"] == "autostart") then

  -- check script instance count in memory 
  if (tonumber(fibaro:countScenes()) > 1) then 
    log("Script already running."); 
    fibaro:abort(); 
  end

  fibaro:debug("HC2 start script at " .. os.date()); 

  counter = 0
  while true do
    checkDead()
    fibaro:sleep(repeatTime*60*1000); 
  end
else
  counter = 0
  checkDead()
end

