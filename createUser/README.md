# createUser

createUser is a Homcenter 2 scene that creates users with information needed by other scenes or vds.

## Installation
In HC2:
1. Scenes
2. Add scenes
3. Add scene in lua
4. Paste lua code
5. Change lines:
```
local username = {
  ["username"] = "NAME OF USER",
  ["present"] = 1,
  ["mac"] = "MAC ADDRESS",
  ["userid"] = FIBARO USERID,
  ["phoneid"] = FIBARO PHONEID
 }
```
Go to http://<IP OF HC2>/api/users to find the FIBARO USERID\
Go to http://<IP OF HC2>/api/iosDevices to find the FIBARO PHONEID

6. Name the scene 'createUser'
7. Assign to room
8. Set "Run scene" to manual
8. Save
9. Add icon to scene
10. Run the scene

**For every user you want to add you have to follow step 5-10 (you can skip step 9)**

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
