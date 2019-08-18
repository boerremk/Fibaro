# Seneye
Seneye is a virtual device and scene that display Seneye data in Homecenter 2

## Requierements
- Seneye account
- Depends on sendMessage to send alerts

## Installation

##### Step 1. Seneye API scene
- Go the Scenes
- Add scene
- Add scene in lua
- Set name "Seneye API"
- Assign room
- Paste the lua code
- Change the lines:
```lua
local id = {"ID1","IDX"}; -- Seneye IDs, separated bij comma if you own more then one
local user = "SENEYE EMAIL";
local pwd = "SENEYE PASSWORD";
```
- Save
- Change icon to "Seneye.png"
- **Remember the ID of the scene, you need it in step 2**

##### Step 2. Senye virtual device
Create a virtual device for every Seneye you own.
- Go to Devices
- Add or remove device
- Import virtual device
- Change icon
- Assign to room
- Use the ID of the scene as TCP Port
- Save
- Change icon to "Seneye.png"
- **Remember the ID of the scene, you need it in step 3**
Repeat this step for every Seneye device you own.

##### Step 3. Edit Seneye API scene
- Go the "Seneye API" scene
- Edit scene
- Change the line:
```
local virtId = {409,411}; -- ID of Virtual devices, separated bij comma if you own more then one
```
- Save

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
