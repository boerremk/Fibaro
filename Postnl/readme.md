# PostNL
*version 0.0.7*

This is a Fibaro Virtual Device (VD) that checks the status of the PostNL (Dutch Postal Service)track and trace API.

## Requirements
- PostNL account

## Installation:

###### PostNL account
  - Create an account on PostNL: https://jouw.postnl.nl/#!/registreren

###### Scene
  - Go to  Scenes
  - Add scene
  - Add scene in lua
  - Paste the LUA code of the file Postnl API
  - Replace the username and password with the postal email and password
  - Set the debug on true 
  - Call the scene "PostNL API"
  - Set the scene to Manual
  - Assign a room
  - Save
  - Use the PostNL API.png icon as scene icon

###### Virtual Device
  - Create a Virtual Device (devices -> add device -> Import VD) using the file: PostNL.vfib
  - Select the id of the scene as TCP port
  - Assign a room
  - Save
 -  Change the ICON to the PostNL.png

###### Check if everything is working
  - Go to Virtual Device and click Update button
  - Go to scene and check log for error
  - If no errors shown, set debug to false in the scene

That is ir!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
