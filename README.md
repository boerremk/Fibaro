# Fibaro
Scenes, VD and other for the Fibaro Homecenter

## Requirements
- Almost all scenes and virtual devices depends on the sendMessage scene
- Almost all scenes and virtual devices depends on a global variable for every user in your household with the following information:
```lua
username = {
  ["present"] = 1,
  ["mac"] = "MAC ADDRESS",
  ["userid"] = FIBARO USERID,
  ["phoneid"] = FIBARO PHONEID
 }
 
 FIBARO USERID: http://<IP OF HC2>/api/users
 FIBARO PHONEID: http://<IP OF HC2>/api/iosDevices
```

## TODO
- [ ] Readme for every scene or device
- [ ] Dependencies

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
