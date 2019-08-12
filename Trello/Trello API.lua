--[[
%% properties
%% events
%% globals
--]]

local debug = true; -- Enable debug yes/no
local API_KEY = "API KEY" -- Trello API key: https://trello.com/app-key
local TOKEN = "TRELLO SECRET" -- Trello secret:  https://trello.com/app-key
local main_id = 613; -- ID of Trello VD
local board = "BOARDNAME"
local lists = {{'ToDo',''}, {'Doing',''}} -- List name, List ID

--
-- Trello API
-- Created by Remko de Boer
-- 
--
-- Release notes:
-- 0.0.1 (20171226) Initial version
--
-- To do:
--   ...
--
local version = "0.0.1"
local base_url = "https://api.trello.com/1"
local appName = "Fibaro - Trello Integration";

-- Functions ---
function log(str) if debug then fibaro:debug(tostring(str)); end; end

function errorlog(str) fibaro:debug("<font color='red'>"..tostring(str).."</font>"); end

function split(s, pattern, maxsplit)
	local pattern = pattern or ' '
	local maxsplit = maxsplit or -1
	local s = s
	local t = {}
	local patsz = #pattern
	while maxsplit ~= 0 do
		local curpos = 1
		local found = string.find(s, pattern)
		if found ~= nil then
			table.insert(t, string.sub(s, curpos, found - 1))
			curpos = found + patsz
			s = string.sub(s, curpos)
		else
			table.insert(t, string.sub(s, curpos))
			break
		end
		maxsplit = maxsplit - 1
		if maxsplit == 0 then
			table.insert(t, string.sub(s, curpos - patsz - 1))
		end
	end
	return t
end

function tomorrow()
	local datetime = os.time();
	tomorrow = os.date("%Y-%m-%d", datetime+24*60*60)
	return tomorrow    
end

function trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

-- Turn key/value pairs into key1=value1&key2&value2&...
-- And encode euch key and value to remove spaces, & etcetera.
function keyValToBody(tbl)
	local tmp
	for k,v in pairs(tbl) do
		if tmp then
			tmp=tmp.."&"..urlencode(k).."="..urlencode(v)
		else
			tmp=urlencode(k).."="..urlencode(v)
		end
	end
	return tmp
end

-- create global var
function globalVar(var, value)
	local http = net.HTTPClient() 
	http:request("http://127.0.0.1:11111/api/globalVariables", { 
		options = { 
			method = 'POST',
			headers = {}, 
			data = '{"name":"'..var..'","value":"'..value..'"}', 
			timeout = 2000
		}, 
		success = function(status)
			fibaro:debug(status.status)
			if status.status ~= 200 and status.status ~= 201 then
				errorlog("Creating variable "..var.." failed: "..status.status);
			end
			log("Creating variabale "..var.." succeeded: "..status.data);
		end,
		error = function(err) 
			errorlog("Creating variable "..var.." failed: " .. err) 
		end 
	}) 
end

function getBoards()
  url = base_url.."/members/my/boards?key="..API_KEY.."&token="..TOKEN
  log(url)

  selfhttp:request(url, {
	options={
			headers = headers,
			method = 'GET',
            checkCertificate = false,
            protocol = "tlsv1_2",
			timeout = 5000
	},
	success = function(status)
	  if status.status == 200 or status.status == 201 then
		status.data = trim(status.data)
	    req_boards = json.decode(status.data)
        for req_board=1, #req_boards do
          if req_boards[req_board]['name'] == board then
            board_id = req_boards[req_board]['id']
          end
        end
        getLists(board_id)
	  else
        fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
		errorlog("Error HTTP status (getBoards): "..status.status)
	  end
	end,
	error = function(error)
      fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
	  errorlog("Error getting data (getBoards): "..error)
	end
  })
end

function getLists(board_id)
  url = base_url.."/boards/"..board_id.."/lists?key="..API_KEY.."&token="..TOKEN
  selfhttp:request(url, {
	options={
			headers = headers,
			method = 'GET',
            checkCertificate = false,
            protocol = "tlsv1_2",
			timeout = 5000
	},
	success = function(status)
	  if status.status == 200 or status.status == 201 then
		status.data = trim(status.data)
	    req_lists = json.decode(status.data)
          
        for req_list=1, #req_lists do
          for list=1, #lists do
            if req_lists[req_list]['name'] == lists[list][1] then
              lists[list][2] = req_lists[req_list]['id']
            end
          end
        end
        getCards(lists, cards)
	  else
        fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
		errorlog("Error HTTP status (getCards): "..status.status)
	  end
	end,
	error = function(error)
      fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
	  errorlog("Error getting data (getCards): "..error)
	end
  })
end

-- getCards
function getCards(lists)
  cards = {}
  url = base_url.."/members/my/cards?key="..API_KEY.."&token="..TOKEN
  selfhttp:request(url, {
	options={
			headers = headers,
			method = 'GET',
            checkCertificate = false,
            protocol = "tlsv1_2",
			timeout = 5000
	},
	success = function(status)
	  if status.status == 200 or status.status == 201 then
		status.data = trim(status.data)
	    req_cards = json.decode(status.data)
          
        for req_card=1, #req_cards do
          for list=1, #lists do
            if req_cards[req_card]['idList'] == lists[list][2] then
              table.insert(cards, {req_cards[req_card]['name'], lists[list][1]})
            end
          end
        end
          
		_update_vd(cards)
	  else
        fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
		errorlog("Error HTTP status (getCards): "..status.status)
	  end
	end,
	error = function(error)
      fibaro:call(main_id, "setProperty", "ui.lblError.value", "Error getting data")
	  errorlog("Error getting data (getCards): "..error)
	end
  })
end

-- Update labels of Evohome VDs --
function _update_vd(cards)
  for list=1, #lists do
    overview = ""
    for card=1, #cards do
      if lists[list][1] == cards[card][2] then
        overview =  overview .. "• " .. cards[card][1] .. "<br />"
      end
    end
    --overview = overview .. "123456789012345678901234567890"
	fibaro:call(main_id, "setProperty", "ui.lbl"..lists[list][1]..".value", overview)
  end
  fibaro:call(main_id, "setProperty", "ui.lbllastUpdate.value", os.date("%c"))
  fibaro:call(main_id, "setProperty", "ui.lblError.value", "");
  log("Success: New data loaded")
end

selfhttp = net.HTTPClient({timeout=2000})
getBoards()
