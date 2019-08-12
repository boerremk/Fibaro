# Code snippets
Here you find some code snippets, that can be used in scenes and virtual devices in Homecenter2

- Check script instance count in memory 
```
if (tonumber(fibaro:countScenes()) > 1) then 
  log("Script already running.");
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
- To round a value
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
