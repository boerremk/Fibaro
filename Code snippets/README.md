# Code snippets
Here you find some code snippets that can be used in scenes and virtual devices in Homecenter2

- Check script instance count in memory 
```
if (tonumber(fibaro:countScenes()) > 1) then 
  fibaro:debug("Script already running.");
  fibaro:abort(); 
end
```
- Turn key/value pairs into key1=value1&key2&value2&...
```
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
```
- Round a value
```
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
```
- Base64
```
--- base64 start
-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function enc(data)
  return ((data:gsub('.', function(x) 
    local r,b='',x:byte()
    for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
    return r;
  end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
    if (#x < 6) then return '' end
    local c=0
    for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
    return b:sub(c+1,c+1)
  end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function dec(data)
  data = string.gsub(data, '[^'..b..'=]', '')
  return (data:gsub('.', function(x)
    if (x == '=') then return '' end
    local r,f='',(b:find(x)-1)
    for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
    return r;
  end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
    if (#x ~= 8) then return '' end
    local c=0
    for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
    return string.char(c)
  end))
end
--- einde base64
```
- Bool to INT
```
intvar=(boolvar and 1 or 0)
```
- First character to uppercase
```
Function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end
```
- Split
```
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
```
- Add a Global Variable in a scene
```
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
        fibaro:debug("Status: "..tostring(resp.status)..", variable: "..vName.." added, value: "..vValue)
      end
    end,
    error = function(err) 
      fibaro:debug("Error: "..tostring(err)..", variable: "..vName.." adding FAILED")
    end
  })
end
```
- Add a Global Variable in a VD
```
function addGlobal(vName, vValue)
  if fibaro:getGlobalValue(vName) == nil then
    local HC2 = Net.FHttp("127.0.0.1",11111);
    requestData = json.encode({ name = vName, value = vValue })
    local response ,status, err = HC2:POST('/api/globalVariables',requestData);
    if (tonumber(status) == 200 and tonumber(err)==0) then
      fibaro:debug("Status: "..tostring(status)..", variable: "..vName.." added, value: "..vValue);
    else
       fibaro:debug("Error: "..tostring(err)..", variable: "..vName.." adding FAILED")
    end
  end
end
```
- Date and Time
```
local currentTime = os.date("%H:%M");
local currentDate = os.date("%d-%m-%Y");
local currentDateTable = os.date("*t"); --{year, month, day, yday, wday, hour, min, sec, isdst}
local day = os.date("%A");
```
- Passing values to a scene
```
Suppose you want to pass an  ID and a Value to another scene.

Sending scene:
fibaro:startScene(207,{1437,99})
 
Receiving scene (this has ID 207):
local id,value=fibaro:args()[1],fibaro:args()[2]
fibaro:debug(("args: %d %d."):format(id, value))
```
