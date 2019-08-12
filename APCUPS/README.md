# APCUPC
APC UPC is ea VD that display te status of an APC UPC.

## Requirements
- Homecenter 2
- APC UPC with USB databconnection
- Server running apcupsd
- Webserver running Python
- VD depends on sendMessage scene to send notifications

## Installation
1. Install apcupsd on a server (http://www.apcupsd.org)
2. Configure a webserver that is able to run Python scripts
3. Install upsstats_fibaro.cgi on the webserver, remember the path, you need this in the VD
4. In HC2 go to Devices
5. Add or remove device
6. Import virtual device APC_UPS.vfib
7. Change icon and add all the icons in the following order: apcups.png, apcupserror.png, gettingdata.png.
8. Right click the icon apcups.png and click "save the image", you will see someting as userxxxx, remember the xxxx
9. Right click the icon apcupserror.png and click "save the image", you will see someting as userxxxx, remember the xxxx
10. Assign icon gettingdata.png to the Update button
11. Assign room to VD
12. Change the lines (Update button):
```
local icon = {"1046","1047"} -- Should be the xxxx you found in step 8 and 9 (apcups.png, apcupserror.png)
local url = "/cgi-bin/apcupsd/upsstats_fibaro.cgi" -- Should be the path from step 3
```
13. Save

That is it!

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
