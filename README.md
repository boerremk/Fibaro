# Fibaro
Scenes, VD and other for the Fibaro Homecenter

## Remark
- Almost all scenes and virtual devices depends on the sendMessage scene
- Almost all scenes and virtual devices depends on a global variables for every user in your household with the following information:
```lua
username = {
  "present"=1,
  "mac" = "MAC ADDRESS",
  "userid" = FIBARO USERID,
  "phoneid" = FIBARO PHONEID
 }
```

## TODO
- [ ] Readme for every scene or device
- [ ] Dependencies

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
