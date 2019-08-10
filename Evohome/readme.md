# Evohome

With Evohome you can use your Fibaro Homecenter 2 to control your Honeywell Evohome system

Original posting:
http://forum.fibaro.com/index.php?/topic/15232-honeywell-evohome/?p=83442

## You need:
- Evohome with color screen and Internet gateway (RFG100) or Evohome with wifi
- Evohome account
- Fibaro Homecenter 2

## Installing
- Create a Variable (Panels / Variables Panel): EvohomeAPI
- Create a LUA scene "Evohome API"
- Paste the code from evohome-api.txt
- Change the following in the scene:
    local username = "EMAIL" -- Evohome username
    local password = "PASSWORD" -- Evohome password
    local locationID = 0; -- ID of Evohome location, starting with 0 (default)
    local main_id = {1376}; -- ID of Evohome VD of all your locations -- see below "Evohome_2.0.vfib"
    local zones_name = {"Room1","Room2","Room2","Bathroom","Hallway","Master","Kidsroom","Kitchen"}; -- Name of zones of all locations, DHW should be named "" (defined in Evohome, case-sensitive!)
    local zones_id = {1219,1377,1222,1221,1218,1217,1220,1223}; -- ID of zones VD of all locations -- see below 
    "Evohome_2.0_-_Zone.vfib"
    !!REMEMBER THE ID OF THE SCENE!!
- Import "Evohome_2.0_-_Zone.vfib" for every zone you need, you have to set/edit:
  The name off the VD should match the name of the zone (case-sensitive!)
  IP Address of the virtual device with the location ID of youe Evohome system (default = 0) (See Evohome 2.0.png)
  TCP port of the virtual device with the ID of the scene (See Evohome 2.0.png)
  !!REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE ABOVE!!
- Import "Evohome_2.0.vfib" (only once!), you have to set/edit:
  IP Address of the virtual device with the location ID of youe Evohome system (default = 0) (See Evohome 2.0.png)
  TCP port of the virtual device with the ID of the scene (See Evohome 2.0.png)
  The values will be update every 30 minutes (you can change this in the main loop)
  !!REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE ABOVE!!
- Import "Evohome_2.0_-_DHW.vfib" for every DHW you need, you have to set/edit:
  IP Address of the virtual device with the location ID of youe Evohome system (default = 0) (See Evohome 2.0.png)
  TCP port of the virtual device with the ID of the scene (See Evohome 2.0.png)
  !!REMEMBER THE ID OF THE VD, THIS HAS TO BE PUT IN THE SCENE, SEE ABOVE!!
  Warning: Evohome-DHW is not tested, because I don't own this device

 
 
## !!IMPORTANT!!
Honeywell changed there security to there API some tome ago so you will receive the following error:
LuaEnvironment: /home/server/bamboo-agent-home/xml-data/build-dir/HC-LE153-JOB1/LuaEngine/vendor/avhttp/avhttp/cookie.hpp:636: bool avhttp::cookies::parse_cookie_string(const string&, std::vector&): Assertion `0' failed.

I have created two workarounds, you only have to use 1:
- Change the line "url= 'https://tccna.honeywell.com/Auth/OAuth/Token'" in the function "GetOAuth" of the scene "Evohome API" to:
  url = ' ' http://boerremk.nl/cgi-bin/access_token2.py'
- In the repository there is a file called access_token2.py, install this on a local webserver and cange the line "url= 'https://tccna.honeywell.com/Auth/OAuth/Token'" in the function "GetOAuth" of the scene "Evohome API" to:
url = '<webserver-ip>/access_token2.py'

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
