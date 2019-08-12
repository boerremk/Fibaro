# Trello
A scene and vd to get the informartion of a Trello board

## Requierments
- Trello API key: https://trello.com/app-key
- Trello secret: https://trello.com/app-key

## Installation
##### Scene
1. Scenes
2. Add scene
3. Add scene in lua, rememeber the scene ID you need it for the VD
4. Paste code "Trello API.lua"
5. Change lines:
```
local debug = true; -- Enable debug yes/no
local API_KEY = "API KEY" -- Trello API key: https://trello.com/app-key
local TOKEN = "TRELLO SECRET" -- Trello secret:  https://trello.com/app-key
local main_id = 613; -- ID of Trello VD
local board = "BOARDNAME"
local lists = {{'ToDo',''}, {'Doing',''}} -- List name, List ID
```
6. Name it "Trello API"
7. Assign roon
8. Save
9. Change icon "Trello-api.png"

##### Virtual Device
1. Add or remove device
2. Import virtual device "Trelli.vfib"
3. Change TCP Port to the ID of the scene (step 3)
4. Give a name
5. Save
6. Change icon for all buttons in "Trello.png"

That is it!


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.
