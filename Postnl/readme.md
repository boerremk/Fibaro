# PostNL
version 0.0.7

This is a Fibaro Virtual Device (VD) that checks the status of the PostNL (Dutch Postal Service)track and trace API.

## Installation:

###### PostNL account
  - Create an account on PostNL: https://jouw.postnl.nl/#!/registreren

###### Scene
  - Go to  Scenes  and Add scene
  - Add scene in LUA and paste the LUA code of the file Postnl API
  - Replace the username and password with the postal email and password created in step 1
  - Call the scene "PostNL API"
  - Set the scene to Manual
  - Use the PostNL API.png icon as scene icon
  - Set the debug on true 

###### Virtual Device
  - Create a Virtual Device (devices -> add device -> Import VD) using the file: PostNL.vfib
  - Change the ICON to the PostNL.png
  - Select the id of the scene as TCP port

###### Check if everything is working
  - Go to Virtual Device and click Update button
  - Go to scene and check log for error
  - If no errors shown, set debug to false in the scene

You are ready to go!
