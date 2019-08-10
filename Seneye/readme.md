# Seneye
Seneye is a virtual device and scene that display Seneye data in Homecenter 2

## Remarks
- You need a Seneye account
- Depends on sendMessage to send alerts

## Installation

##### Scene
- Go the scens
- Add scene
- Add scene in lua
- Set name "Seneye API"
- Assign room
- Paste the lua code
- Change the lines:
```lua
local id = {"30988","5204"}; -- Seneye ID, separated bij comma
local user = "SENEYE EMAIL";
local pwd = "SENEYE PASSWORD";
local virtId = {409,411}; -- ID of Virtual device (needs next step!
```
- Save
- Change icon

##### Virtual Device
- Go to Devices
- Add or remove device
- Import virtual device
- Change icon
- Assign to room
- Put the ID of the scene in as TCP Port


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
