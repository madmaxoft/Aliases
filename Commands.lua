
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
		a_Player:SendMessage(resp, "\"" .. alias.From .. "\" -> \"" .. alias.To .. "\"")
	end
	return true
end





function HandleConsoleCmdAliasList(a_Split, a_EntireCommand)
	local aliases = GetPlayerState().Aliases
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
	for _, alias in ipairs(aliases) do
		LOG(resp, "\"" .. alias.From .. "\" -> \"" .. alias.To .. "\"")
	end
	return true
end





function HandleConsoleCmdAliasSet(a_Split, _, a_EntireCommand)
	-- Remove the "alias set" prefix from the entire command:
	local CommandParams = a_EntireCommand:sub(10)
	
	-- Try set the alias:
	local _, Msg = GetPlayerState():SetAlias(CommandParams)
	return true, Msg
end




