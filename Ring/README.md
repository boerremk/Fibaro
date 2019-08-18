# Ring API
Ring API is scene that checks motion and ding events.

## Requirements
- Ring account
- At least one Ring Doorbell device

## Installation
##### In HC2:
- Go the Scenes
- Add secene
- Add scene in lua
- Paste the lua code "Ring API.lua"
- Change the lines:
```lua
local username = "RING EMAIL"
local password = "RING PASSWORD"
```
- Name the scene "Ring API"
- Assign it to a room
- Set "Run scene" to manual
- Select "Do not allow alarm to stop scene while alarm is running" 
- Save
- Add icon "ring_api.png" to scene

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
