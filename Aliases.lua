
-- Aliases.lua

-- Implements the main entrypoint to the plugin





--- Prefix that is used for all console messages from this plugin
PLUGIN_PREFIX = "Aliases: "





local function OnExecuteCommand(a_Player, a_Split, a_EntireCommand)
	local state = GetPlayerState(a_Player)
	
	-- Check if there is an alias for this command:
	local alias = state:FindAlias(a_EntireCommand)
	if not(alias) then
		-- No alias, continue executing normally:
		return false
	end
	
	-- An alias has been found, apply it and re-execute:
	local NewCommand = alias.To .. string.sub(a_EntireCommand, string.len(alias.From) + 1)
	local Result
	if (a_Player) then
		Result = cPluginManager:Get():ExecuteCommand(a_Player, NewCommand)
	else
		local IsSuccess, Output = cPluginManager:ExecuteConsoleCommand(NewCommand)
		LOG(Output)
		Result = IsSuccess and cPluginManager.crExecuted or cPluginManager.crError
	end
	return true, Result
end





local function OnPlayerDestroyed(a_Player)
	-- Even if there were multiple players of the same name, we can safely remove the state
	-- The state will get re-created when any of the remaining players access it for the first time
	RemovePlayerState(a_Player)
end





function Initialize(a_Plugin)
	a_Plugin:SetName("Aliases")
	
	InitializeStorage()
	
	-- Register the commands:
	dofile(cPluginManager:GetPluginsPath() .. "/InfoReg.lua")
	RegisterPluginInfoCommands()
	RegisterPluginInfoConsoleCommands()
	
	cPluginManager:AddHook(cPluginManager.HOOK_EXECUTE_COMMAND,  OnExecuteCommand)
	cPluginManager:AddHook(cPluginManager.HOOK_PLAYER_DESTROYED, OnPlayerDestroyed)
	return true
end