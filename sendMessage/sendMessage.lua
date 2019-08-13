--[[
%% properties
%% events
%% globals
--]]
local debug = true;
local Pushover_tkn = "Pushover Token"
local Pushover_usr = "Pushover user"
local PushoverGlances_tkn = "Pushover Glances Token"
local PushoverGlances_usr = "Pushover Glances user"
local Telegram_token = "Telegram Token"
local Telegram_chat_id = "Telegram Chat ID"

-[[
sendMessage
Created by Remko de Boer

Description:
  Scene to send messages.
  Can use Fibaro push, Pushover, Pushover glances (smartwatch), Telegram or email.
  See Arguments how to use this scene

Remarks:

Prerequisite: 

Arguments:
  push: true or false, {ids of phone, used by Fibaro}: eq {true, {4}}
  email: true or false, {ids of account}: eq {true, {8,3}}
  pushover: true or false, priority: eq {true, "0"}
  pushover_gla: true or false, percentage: eq {true, "100"}
  telegram: true or false: eq {true}
  title: title of message: eg "Test Title"
  msg: Message: eg "This is a message"

Usage:
  local user = tonumber(fibaro:getGlobalValue("user"))
  local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))
  fibaro:startScene(sendMessageID,{{true, {user["id"]}},{false},{false},{true, "100"},{false},"Titel","Message"})

Release notes:
  0.0.1 (2018xxxx) Initial version
  1.0.0 (20180812) Bugfixes and production version
  1.0.1 (20190120) Added Usage
  2.0.0 (20190810) Combined Pushover, Pushover Glances, Telegram and sendMessage
  2.1.0 (20190813) Removed Pushover Glances tkn and usr, same as Pushover

To do:

--]]
local version = "2.0.1"

-- Do not change --
local function log(str) if debug then fibaro:debug(tostring(str)); end; end
local function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function url_encode(str) 
if (str) then 
     str = string.gsub (str, "\n", "\r\n") 
     str = string.gsub (str, "([^%w %-%_%.%~])", 
       function (c) return string.format ("%%%02X", string.byte(c)) end) 
   str = string.gsub (str, " ", "+") 
end 
	return str    
end 

function urldecode(s)
  return string.gsub(s, '%%(%x%x)', 
    function (hex) return string.char(tonumber(hex,16)) end)
end

function urldecodeTable(tab)
  for k,v in pairs(tab) do 
    if type(v) == "string" then
      tab[k] = urldecode(v)
    elseif type(v) == "table" then
      urldecodeTable(v)
    end
  end
end

function Pushover(msg)
  local selfhttp = net.HTTPClient({timeout=2000})
  local tkn = Pushover_tkn
  local usr = Pushover_usr

  local requestBody = 'token=' ..tkn ..'&user=' ..usr ..msg
  log("requestBody: "..requestBody);

  selfhttp:request('https://api.pushover.net/1/messages.json', {
    options={
      headers = selfhttp.controlHeaders,
      data = requestBody,
      method = 'POST',
      timeout = 5000
    },
    success = function(status)
      local result = json.decode(status.data);
      log(result.status);
      if result.status == 1 then
        log("successful");
        log("Request: " ..result.request);
      else
        errorlog("failed: "..stastus.datas);
      end
    end,
    error = function(error)
      errorlog("ERROR: " .. error)
    end
  })
end

function PushoverGlances(msg)
  local selfhttp = net.HTTPClient({timeout=2000})
  local tkn = Pushover_tkn
  local usr = Pushover_usr
  local requestBody = 'token=' ..tkn ..'&user=' ..usr ..msg
  log(requestBody);

  selfhttp:request('https://api.pushover.net/1/glances.json', {
    options = {
      headers = {['Content-Type'] = 'application/x-www-form-urlencoded'},
      data = requestBody,
      method = 'POST',
      timeout = 5000
    },
    success = function(status)
      local result = json.decode(status.data);
      log(status.data);
      if result.status == 1 then
        log("Successful");
      else
        errorlog("Failed: " .. status.data);
      end
    end,
    error = function(error)      
      errorlog("Error: " .. error);
    end
  })
end

function Telegram(msg)
  local selfhttp = net.HTTPClient({timeout=2000})
  local token = Telegram_token
  local chat_id = Telegram_chat_id
  local url = "https://api.telegram.org/bot"..token.."/sendMessage?chat_id="..chat_id.."&text="
  url = url .. url_encode(msg);
  log(url);

  selfhttp:request(url, {
    options={
      headers = selfhttp.controlHeaders,
      data = requestBody,
      method = 'GET',
      timeout = 5000
    },
    success = function(status)
      local result = json.decode(status.data);
      if result.ok == true then
        log("successful");
      else
        errorlog("failed: " .. status.data);
      end
    end,
    error = function(error)
      errorlog("ERROR: " .. error)
    end
  })
end

function message(push, email, pushover, pushover_gla, telegram, title, msg)
  if push[1] then
    log("push");
    for i=1, #push[2] do
      fibaro:call(push[2][i], "sendPush", msg);
    end
  end
  if email[1] then
    log("email")
    for i=1, #email[2] do
      fibaro:call(email[2][i], "sendEmail", title, msg);
    end
  end
  if pushover[1] then
    log("pushover")
    if pushover[2] == nil then pushover[2] = "0" end -- prio
    local requestBody = '&priority=' ..pushover[2] ..'&title='..title..'&message=' ..msg;
    Pushover(requestBody) 
  end
  if pushover_gla[1] then
    log("pushover_gla")
    local requestBody = '&title=' ..title ..'&text=' ..msg ..'&percent=' ..pushover_gla[2]
    PushoverGlances(requestBody) 
  end
  if telegram[1] then
    log("telegram")
    Telegram(msg)
  end
end

--- Main
log("sendMessage started")
if fibaro:args() == nil then
  fibaro:debug("no args");
  return
else
  local push,email,pushover,pushover_gla,telegram,title,msg = fibaro:args()[1],fibaro:args()[2],fibaro:args()[3],fibaro:args()[4],fibaro:args()[5],fibaro:args()[6],fibaro:args()[7]
  message(push,email,pushover,pushover_gla,telegram,title,msg)
end

--- End
