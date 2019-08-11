# sendMessage

sendMessage is a Homecenter 2 scene to send mail, Fibaro push, Pushover*, Pushover Glances* or Telegram* messages.

## Requirements
- Pushover account
- Pushover Token and UserID
- Telegram account
- Telegram Token and ChatID

# Installation
##### In HC2:
- Go to Scnes
- Add scene
- Add scene in lua
- Paste code
- Change the lines:
```lua
local Pushover_tkn = Pushover Token
local Pushover_usr = Pushover user
local PushoverGlances_tkn = Pushover Glances Token
local PushoverGlances_usr = Pushiver Glamnces user
local Telegram_token = Telegram Token
local Telegram_chat_id = Telegram Chat ID
```
- Give the scene a name
- Assign to a room
- Save
- Add icon
- Add Global Variable "sendMessage" with the ID of the scene as value

## Usage:
In a scene or virtual device add:
```lua
local user = tonumber(fibaro:getGlobalValue("user"))
local sendMessageID = tonumber(fibaro:getGlobalValue("sendMessage"))
fibaro:startScene(sendMessageID,{{true, {user["id"]}},{false},{false},{true, "100"},{false},"Titel","Message"})
```


That is it
