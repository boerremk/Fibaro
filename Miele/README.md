# Miele

Miele is a Homecenter 2 scene and a virtual deivice that shows information of a Miele washing machine.

## Requirements
- Miele account
- Miele client_id and client_secret
- At least one Miele devices (for now it only support a washing machine)

## Installation
##### Step 1. Scene
In HC2:
- Scenes
- Add scene
- Add scene in lua
- Paste lua code
- Change the lines:
```
local client_id = "CLIENT ID";
local client_secret = "CLIENT SECRRET";
local username	= "Miele EMAIL"
local password	= "Miele PASSWORD"
local vg = "nl-NL" -- The vg the users Miele account belongs to, choose from de-DE or en-EN
local language = "nl" -- choose fron de or en
```
- Name the scene "Miele API"
- assign the scene to a room
- Save
- Add icon

##### Step 2. Virtual device
In HC2:
- Add or remove device
- Import virtual device
- Change the TCP Port with the ID of the scene
- Give the VD a name
- Assign to a room
- Save
- Add icon

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
