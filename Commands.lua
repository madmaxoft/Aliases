
-- Commands.lua

-- Implements the command handlers for in-game and console commands





function HandleCmdAliasList(a_Split, a_Player, a_EntireCommand)
	local aliases = GetPlayerState(a_Player).Aliases
	if not(aliases) then
		a_Player:SendMessage("You have no active aliases.")
		return true
	end
	
	-- Sort the aliases alphabetically by the "From" part:
	table.sort(aliases,
		function (a_Item1, a_Item2)
			return (a_Item1.From < a_Item2.From)
		end
	)

	-- Send all the aliases to the player:
	for _, alias in ipairs(aliases) do
		a_Player:SendMessage("\"" .. alias.From .. "\" -> \"" .. alias.To .. "\"")
	end
	return true
end





function HandleCmdAliasRemove(a_Split, a_Player, a_EntireCommand)
	-- Remove the "/alias remove " prefix from the entire command:
	local CommandParams = a_EntireCommand:sub(15)

	-- Try to remove the alias:
	local _, Msg = GetPlayerState(a_Player):RemoveAlias(CommandParams)
	a_Player:SendMessage(Msg)
	return true
end





function HandleCmdAliasSet(a_Split, a_Player, a_EntireCommand)
	-- Remove the "/alias set " prefix from the entire command:
	local CommandParams = a_EntireCommand:sub(12)
	
	-- Try set the alias:
	local _, Msg = GetPlayerState(a_Player):SetAlias(CommandParams)
	a_Player:SendMessage(Msg)
	return true
end





function HandleConsoleCmdAliasList(a_Split, a_EntireCommand)
	local aliases = GetPlayerState(nil).Aliases
	if (not(aliases) or not(aliases[1])) then
		return true, "You have no active aliases."
	end

	-- Sort the aliases alphabetically by the "From" part:
	table.sort(aliases,
		function (a_Item1, a_Item2)
			return (a_Item1.From < a_Item2.From)
		end
	)

	-- Send all the aliases to the player:
	local resp = {}
	for _, alias in ipairs(aliases) do
		table.insert(resp, "\"" .. alias.From .. "\" -> \"" .. alias.To .. "\"")
	end
	return true, table.concat(resp, "\n")
end





function HandleConsoleCmdAliasRemove(a_Split, _, a_EntireCommand)
	-- Remove the "alias remove " prefix from the entire command:
	local CommandParams = a_EntireCommand:sub(14)

	-- Try to remove the alias:
	local _, Msg = GetPlayerState(nil):RemoveAlias(CommandParams)
	return true, Msg
end





function HandleConsoleCmdAliasSet(a_Split, _, a_EntireCommand)
	-- Remove the "alias set " prefix from the entire command:
	local CommandParams = a_EntireCommand:sub(11)
	
	-- Try set the alias:
	local _, Msg = GetPlayerState(nil):SetAlias(CommandParams)
	return true, Msg
end




