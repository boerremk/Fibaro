# Evohome
_version 3.3.3_

With Evohome you can use your Fibaro Homecenter 2 to control your Honeywell Evohome system

Original posting:
http://forum.fibaro.com/index.php?/topic/15232-honeywell-evohome/?p=83442

If you need help with the installation go the Fibaro forum and send me a PM (@boerremk).

## Requirements
- Fibaro Homecenter 2
- Evohome with color screen and Internet gateway (RFG100) or Evohome with wifi
- Evohome account


## Installing


##### Step 1. Create Evohome API scene
- Go to Scenes
- Add scene
- Add scene in lua
- Paste the code from "Evohome_2.0_scene.lua"
- Change the following in the scene:
```
local username = "EMAIL" -- Use your Evohome username
local password = "PASSWORD" -- Use your Evohome password
local locationID = 0; -- ID of Evohome location, starting with 0 (default)
local zones_name = {"Room1","Room2","Room3"}; -- Name of zones of all locations, DHW should be named "" (defined in Evohome, case-sensitive!)
```
- Save

**REMEMBER THE ID OF THE SCENE**

##### Step 2a. Adding zones (virtual devices)
- Go to Devices
- Add or remove devices
- Import virtual deivce "Evohome_2.0_-_Zone.vfib"
- Edit:\
  The name of the VD should match the name of the zone (case-sensitive!)\
  IP Address of the virtual device with the location ID of your Evohome system (default = 0) (See Evohome 2.0.png)\
  TCP port of the virtual device with the ID of the scene (See Evohome 2.0.png)
- Save
- **REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE BELOW**

_Repeat this step for every zones_

Go to step 2b if you own a Domestic Hot Water, otherwise go to step 3.

##### Step 2b. Adding Domestic Hot Water (virtual)  
- Go to Devices
- Add or remove devices
- Import "Evohome_2.0_-_DHW.vfib"
- Edit:\
  IP Address of the virtual device with the location ID of your Evohome system (default = 0)\
  TCP port of the virtual device with the ID of the scene\
- Save
- **REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE BELOW**

_Repeat this step for every Domestic Hot Water_

##### Step 3. Adding Main virtual device
- Go to Devies
- Add or remove devices
- Import "Evohome_2.0.vfib" (only once!)
- Edit:\
  IP Address of the virtual device with the location ID of your Evohome system (default = 0)\
  TCP port of the virtual device with the ID of the scene\
  The values will be update every 30 minutes (you can change this in the main loop)\
- Save
- **REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE BELOW**
  
##### Step 4. Edit Evohome API scene
- Go to Evohome API scene
- Edit scene
- Change the following in the scene:
```
local main_id = {170}; -- ID of Evohome VD's, one for every location, starting with the ID of location 0 
local zones_id = {171,172,173}; -- ID of all zones (in all locations)
```
- Save

##### Step 5. Check if everything is OK
- Go to devices
- Go to Main Evohome virtual device
- Click Update button
- Go to Scenes
- Go to Evohome API scene
- Check debug window for any errors

## Common errors
- Error HTTP status (GetOAuth): Login is failing, check username and password
 
## IMPORTANT
Honeywell changed there security to there API some tome ago so you will receive the following error:
```
LuaEnvironment: /home/server/bamboo-agent-home/xml-data/build-dir/HC-LE153-JOB1/LuaEngine/vendor/avhttp/avhttp/cookie.hpp:636: bool avhttp::cookies::parse_cookie_string(const string&, std::vector&): Assertion `0' failed.
```

I have created two workarounds, you only have to use 1:
```
1. Change the line "url= 'https://tccna.honeywell.com/Auth/OAuth/Token'" in the function "GetOAuth" of the scene "Evohome API" to:
  url = ' ' http://boerremk.nl/cgi-bin/access_token2.py'
2. In the repository there is a file called access_token2.py, install this on a local webserver and cange the line "url= 'https://tccna.honeywell.com/Auth/OAuth/Token'" in the function "GetOAuth" of the scene "Evohome API" to:
url = '<webserver-ip>/access_token2.py'
```

## Authors and acknowledgment
- https://github.com/watchforstock/evohome-client
- http://www.automatedhome.co.uk/vbulletin/showthread.php?3863-Decoded-EvoHome-API-access-to-control-remotely

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
