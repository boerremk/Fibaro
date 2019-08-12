# FSBPi

A scene and VD for the Homecenter 2 to integrate the Do-it FSBPi webserver into the Homecenter.

## Requirements
- Homecenter 2
- FSBPi webserver
- Depends on scene sendMessage for sending notifications

## Installation

##### Scene
In HC2
1. to Scenes
2. Add scene, remember the ID of the scene, you need it for the VD
3. Add scene in lua
4. Paste FSBPi.lua
5. Change the lines:
```
local password = "FSB PASSWORD" -- Password used for the FSBPi
local username = json.decode(fibaro:getGlobalValue("Remko")) -- User for sending messages
```
6. Asign room
7. Save
8. Change icon to "fsbpiapi.png"

##### Virtual Device
1. Go to Devices
2. Add or remove device
3. Import vitual device
4. Assign room
5. Use scene ID for TCP Port
6. Use IP of FSBPi webserver for IP Address
7. Save
8. Change icon for every button to "fsbpi.png"

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
