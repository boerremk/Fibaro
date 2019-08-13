local debug = true;
local url = "gpsgadget.buienradar.nl";
local beforeRain = 15; -- in minutes, time to send message before rain
local afterRain = 15; -- in mintues, time to set Buienradar to 0
local zonnescherm = {true,{807}};
local username = json.decode(fibaro:getGlobalValue("Remko"))
local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))
local prio = "0"; -- priority of pushmessage, only used for Pushover
local startTime = "07:00" -- time to start messages
local stopTime = "23:00"; -- time to stop messages
local runTime = 5; -- in minutes

local version = "1.0.1"
local selfId = fibaro:getSelfId();
local currentTime = os.date("%H:%M");
local currentDate = os.date("*t");
local label = "";
local msg = "";
local raintime = "";

local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function latlon()
  if HC2 == nil then
    HC2 = Net.FHttp("127.0.0.1",11111);
  end
  local response ,status, err = HC2:GET("/api/settings/location");
  if (tonumber(status) == 200 and tonumber(err)==0) then
    if response and response ~= "" and response ~= nil then
      jsonTable = json.decode(response)
      latitude = round(jsonTable.latitude,2)
      longitude = round(jsonTable.longitude,2)
    end
  end
end

function globalVar(var)
  if fibaro:getGlobalValue(var) ~= nil and fibaro:getGlobalValue(var) ~= "" then
    return fibaro:getGlobalValue(var)
  else
    if HC2 == nil then
      HC2 = Net.FHttp("127.0.0.1",11111);
    end
    local response ,status, err = HC2:POST('/api/globalVariables','{"name":"'..var..'","value":"0"}');
    if (tonumber(err)==0) and response and response ~= "" and response ~= nil then
      log("Global variable "..var.." created");
    end
    return "0"
  end
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

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

function checkRain()
  rain = false;
  raintime = "";
  if BR == nil then
    BR = Net.FHttp(url,80);
  end
  
  log("http://"..url.."/data/raintext?lat="..latitude.."&lon="..longitude)

  local response, status, err = BR:GET("/data/raintext?lat="..latitude.."&lon="..longitude);
  if (tonumber(status) == 200 and tonumber(err)==0) then
    if response and response ~= "" and response ~= nil then
      log("Gegevens opgehaald");
      fibaro:log("Getting data...")
      response = trim(response)
      --log(response)
      responseTable = split(response, "\n")
      local values = 0;
      for i=1, (#responseTable) do
        rainT = responseTable[i]:sub(1,3)
        timeT = responseTable[i]:sub(5,9)
        log("timeT: "..timeT..", rainT:"..rainT)
        if tonumber(timeT:sub(1,2)) <= 2 then
          timeTN = tostring(tonumber(timeT:sub(1,2)) + 24) .. timeT:sub(3)
        else
          timeTN = timeT
        end
        if (currentTime <= timeT or currentTime <= timeTN) and values < 13 then
          log(timeT..":"..rainT)
          values = values + 1
          rainfall = round(10^((tonumber(rainT)-109)/32),3)
          if rainfall > 0 and tonumber(rainT) > 77 then
            if rainfall >= 1 or tonumber(responseTable[i+1]:sub(1, 3)) > 77 then
              rain = true
              if raintime == "" then
                raintime = timeT;
                log(raintime)
              end
            end
          end
          fibaro:call(selfId, "setProperty", "ui.lblBuienradar"..values..".value", timeT .. ": " .. string.format("%.3f", rainfall))
          label = label .. timeT .. ": " .. rainfall .. "%0A"
        end
      end
      fibaro:call(selfId, "setProperty", "ui.lblError.value", "");
      fibaro:call(selfId, "setProperty", "ui.lbllastUpdate.value", os.date("%c"));
      return true
    else
      fibaro:call(selfId, "setProperty", "ui.lblError.value", "Error getting data");
      errorlog("Result is nil or empty")
      return false
    end
  else
    fibaro:call(selfId, "setProperty", "ui.lblError.value", "Error getting data");
    errorlog("error: "..err)
    errorlog("status: "..status)
    return false
  end
end

latlon()
buienradar = globalVar("Buienradar")
log("buienradar: "..buienradar)

if checkRain() then
  log(rain)
  if rain and buienradar == "0" then
    log("rain and 0")
    counter = 1
    while counter <= math.floor(beforeRain/runTime) and rain do
      log("rain and counter: "..counter)
      fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Expected at "..raintime);
      counter = counter + 1
      fibaro:sleep(runTime*60*1000)
      tmp = checkRain()
      log(rain)
    end
    if rain then
      log("rain")
      fibaro:setGlobal("Buienradar", raintime)
      if currentTime >= startTime and currentTime <= stopTime then
        msg = "Regen om "..raintime
        fibaro:startScene(sendMessageID,{{true, {username["phoneid"]}},{false},{false},{true, "100"},{false},"Buienradar",msg})
        log(msg)
        if zonnescherm[1] == true then
          for i=1, #zonnescherm[2] do
            if tonumber(fibaro:getValue(zonnescherm[2][i], "value")) > 0 then
              fibaro:call(zonnescherm[2][i], "setValue", "0")
              log("Zonnescherm ("..zonnescherm[2][i]..") gesloten")
            end
          end
        end
      end
      fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Expected at "..raintime);
    end
  elseif not rain and buienradar == "0" then
    log("not rain and 0")
    fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Not expected");
  elseif rain and buienradar ~= "0" then
    log("rain and 1")
    fibaro:setGlobal("Buienradar", raintime)
    fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Expected at "..raintime);
  elseif not rain and buienradar ~= "0" then
    log("no rain and 1")
    counter = 1
    while counter < math.floor(afterRain/runTime) and not rain do
      log("no rain and counter: "..counter)
      fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Not expected");
      counter = counter + 1
      fibaro:sleep(runTime*60*1000)
      tmp = checkRain()
      log(rain)
    end
    if not rain then
      log("not rain")
      fibaro:setGlobal("Buienradar", "0")     
      fibaro:call(selfId, "setProperty", "ui.lblOverview.value", "Not expected");
      msg = "Geen regen verwacht"
      fibaro:startScene(sendMessageID,{{true, {username["phoneid"]}},{false},{false},{true, "100"},{false},"Buienradar",msg})
      log(msg)
    end
  end
  fibaro:log("transfer ok")
end

fibaro:sleep(runTime*60*1000)
