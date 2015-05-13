
-- PlayerState.lua

-- Implements the player state storage and management





--- All the player states, a map of PlayerName -> PlayerState
-- A special item with empty name is used for the console state
local g_PlayerStates = {}

--[[
PlayerState contents:
{
	Aliases =
	{
		{ From = "From1", To = "To1", CreationDate = 1234 },
		{ From = "From2", To = "To2", CreationDate = 5678 },
		...
	}
}
--]]





--- Class that is used for representing each PlayerState. Defines useful functions operating on the PlayerState
local g_PlayerStateTemplate = {}
g_PlayerStateTemplate.__index = g_PlayerStateTemplate





--- Searches the aliases in the PlayerState to find a match for the specified command
-- If a match is found, the corresponding Aliases[] entry is returned
-- If a match is not found, nil is returned
function g_PlayerStateTemplate:FindAlias(a_EntireCommand)
	-- Check params:
	assert(self)
	assert(type(a_EntireCommand) == "string")
	
	-- Search for the alias matching the current command
	for _, alias in ipairs(self.Aliases) do
		if (a_EntireCommand:sub(1, alias.From:len()) == alias.From) then
			return alias
		end
	end
	
	return nil
end





--- Removes an alias, based on the "From" in the a_CommandParams string
-- Returns true or false indicating success, and a message
function g_PlayerStateTemplate:RemoveAlias(a_CommandParams)
	-- Check params:
	assert(type(a_CommandParams) == "string")
	
	-- Parse the command parameters:
	local Split = StringSplitWithQuotes(a_CommandParams, " ")
	if (#Split ~= 1) then
		return false, "You need to provide exactly one parameters, enclosed in doublequotes."
	end
	local From = Split[1]
	
	-- Search for the alias, remove it if found:
	for idx, alias in ipairs(self.Aliases) do
		if (alias.From == From) then
			table.remove(self.Aliases, idx)
			g_DB:RemoveAlias(alias)
			return true, "Alias removed"
		end
	end
	
	return false, "Alias not found"
end





--- Sets an alias, based on the command parameters in the a_CommandParams string
-- Returns true if successful, false and message on failure
function g_PlayerStateTemplate:SetAlias(a_CommandParams)
	-- Check params:
	assert(type(a_CommandParams) == "string")
	
	-- Parse the command parameters:
	local Split = StringSplitWithQuotes(a_CommandParams, " ")
	if (#Split ~= 2) then
		return false, "You need to provide exactly two parameters, enclosed in doublequotes."
	end
	local From = Split[1]
	local To = Split[2]
	local FromLen = string.len(From)
	
	-- Check if the alias conflicts with an already defined alias:
	for _, alias in ipairs(self.Aliases) do
		if (
			(alias.From:sub(1, FromLen) == From) or  -- The From is a prefix of an existing alias
			(From:sub(1, alias.From:len()) == alias.From)  -- The alias is a prefix of the From
		) then
			return false, "There is already a conflicting alias: \"" .. alias.From .. "\""
		end
	end
	
	-- Add the alias to the DB and state:
	local NewAlias =
	{
		From = From,
		To = To,
		CreationDate = os.time(),
		PlayerName = self.PlayerName,
	}
	table.insert(self.Aliases, NewAlias)
	g_DB:InsertAlias(NewAlias)
	
	return true, "Alias has been set"
end





--- Loads the player state from the DB
-- Returns a complete loaded state
-- If a_Player is nil, the console state is returned
local function LoadPlayerState(a_Player)
	-- Check params:
	assert((a_Player == nil) or (tolua.type(a_Player) == "cPlayer"))
	
	-- Create and load the state:
	local res = {}
	setmetatable(res, g_PlayerStateTemplate)  -- Add the prototype functions to the returned state
	local PlayerName = a_Player and a_Player:GetName() or ""
	res.PlayerName = PlayerName
	res.Aliases = g_DB:LoadAliasesForPlayer(PlayerName)
	
	return res
end





--- Returns the state for the specified player
-- Uses the g_PlayerStates for cache, loads a new state if not found
-- If a_Player is nil, the console state is returned
function GetPlayerState(a_Player)
	-- Check params:
	assert((a_Player == nil) or (tolua.type(a_Player) == "cPlayer"))
	
	local PlayerName = a_Player and a_Player:GetName() or ""
	local res = g_PlayerStates[PlayerName]
	if not(res) then
		res = LoadPlayerState(a_Player)
		g_PlayerStates[PlayerName] = res
	end
	
	return res
end





--- Removes the state for the specified player from the cache
function RemovePlayerState(a_Player)
	-- Check params:
	assert(tolua.type(a_Player) == "cPlayer")
	
	g_PlayerStates[a_Player:GetName()] = nil
end




