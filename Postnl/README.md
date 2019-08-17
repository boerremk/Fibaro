# PostNL
*version 1.0.0*

This is a Fibaro Virtual Device (VD) that checks the status of the PostNL (Dutch Postal Service)track and trace API.

## Requirements
- PostNL account

## Installation:

###### Step 1. PostNL account
  - Create an account on PostNL: https://jouw.postnl.nl/#!/registreren

###### Step 2. Postnl API Scene
  - Go to  Scenes
  - Add scene
  - Add scene in lua
  - Paste the LUA code of the file "Postnl API.lua"
  - Replace the username and password with the Postnl email and password
  - Set the debug on true 
  - Call the scene "PostNL API"
  - Set the scene to Manual
  - Assign a room
  - Save
  - Use the PostNL API.png icon as scene icon

###### Step 3. Postnl virtual device
  - Devives
  - Add or remove device
  - Import virtual device "PostNL.vfib"
  - Select the id of the scene as TCP port
  - Assign a room
  - Save
 -  Change the ICON to the PostNL.png

###### Step 4. Check if everything is working
  - Go to Postnl virtual vevice
  - Click Update button
  - Go to scene and check debug window for any errors
  - If no errors shown, set debug to false in the scene

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
