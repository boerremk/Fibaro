# PostNL
version 0.0.7

This is a Fibaro Virtual Device (VD) that checks the status of the PostNL (Dutch Postal Service)track and trace API.

Installation:

- Create an account on PostNL: https://jouw.postnl.nl/#!/registreren

- Create a Virtual Device (devices -> add device -> Import VD) using the file: PostNL.vfib
- Change the ICON to the PostNL.png

- Go to  Scenes  and Add scene
- Add scene in LUA and paste the LUA code of the file Postnl API
- Replace the username and password with the postal email and password created in step 1
- Call the scene "PostNL API"
- Set the scene to Manual
- Use the PostNL API.png icon as scene icon
- Set the debug on true 

- Go to the Virtual Device and select the id of the scene as TCP port
- Run the scene once to verify the connection and to make sure the credentials are correct.

If the log is okay set the debug mode to false

You are ready to go!
