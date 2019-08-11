# Seneye
Seneye is a virtual device and scene that display Seneye data in Homecenter 2

## Requierements
- Seneye account
- Depends on sendMessage to send alerts

## Installation

##### Scene
- Go the Scenes
- Add scene
- Add scene in lua
- Set name "Seneye API"
- Assign room
- Paste the lua code
- Change the lines:
```lua
local id = {"ID1","IDX"}; -- Seneye ID, separated bij comma
local user = "SENEYE EMAIL";
local pwd = "SENEYE PASSWORD";
local virtId = {409,411}; -- ID of Virtual device (needs next step!)
```
- Save
- Change icon

##### Virtual Device
Create a virtual device for every Seneye you own.
- Go to Devices
- Add or remove device
- Import virtual device
- Change icon
- Assign to room
- Put the ID of the scene in as TCP Port


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.