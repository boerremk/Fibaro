# Buienradar

Buienradar is a Homecenter 2 virtual device that display Buienradar information. It sends a message when rain is expected and closes sunshades if you own some.

## Requirements
- Living in The Netherlands
- For sending of a message it depends on sendMessage scene

## Installation:
In HC2:
- Devices
- Add or remove device
- Import virtual device
- Assign to a room
- In the mainloop change the lines:
```
local beforeRain = 15; -- in minutes, time to send message before rain
local afterRain = 15; -- in mintues, time to set Buienradar to 0
local zonnescherm = {true,{807}}; -- if you own a sunshade set to true and add the ids of the sunshades, seprated by comma
local startTime = "07:00" -- time to start messages
local stopTime = "23:00"; -- time to stop messages
```
- Save
- Change icon


That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
