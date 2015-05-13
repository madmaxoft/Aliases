
-- Info.lua

-- Declares the plugin metadata, commands, permissions etc.





g_PluginInfo =
{
	Name = "Aliases",
	Date = "2015-05-13",
	Description =
	[[
		This is a plugin for {%a http://mc-server.org}MCServer{%/a} that allows players to define aliases for
		in-game commands and even chat messages. Server admins can define their aliases for console commands.
		
		This makes it easier to use long commands - you can define a shorter version of the command, and even include the initial parameters. For example:
		{%list}
		{%li}"/td" -> "/time set day": By using the simple "/td" command you can set the time to day in the world{%/li}
		{%li}"/ts" -> "/time set": Now you can use commands such as "/ts night" to set night in the world{%/li}
		{%li}(console) "kx" -> "kick xoft I hate you because": Now you can kick me really fast using the console command "kx no reason"{%/li}
		{%/list}
	]],
	
	Commands =
	{
		["/alias"] =
		{
			Subcommands =
			{
				list =
				{
					HelpString = "Lists all your aliases",
					Permission = "aliases.alias.list",
					Handler = HandleCmdAliasList,
				},  -- list

				remove =
				{
					HelpString = "Removes an existing alias",
					Permission = "aliases.alias.remove",
					Handler = HandleCmdAliasRemove,
					ParameterCombinations =
					{
						{
							Params = [["From"]],
							Help = "Removes the alias previously defined for \"From\"",
						},
					},
				},  -- remove

				set =
				{
					HelpString = "Sets an alias from one command to another",
					Permission = "aliases.alias.set",
					Handler = HandleCmdAliasSet,
					ParameterCombinations =
					{
						{
							Params = [["From" "To"]],
							Help = "Set an alias for command \"From\" as command \"To\"",
						},
					},
				},  -- set
			},  -- Subcommands
		},  -- ["/alias"]
	},  -- Commands
	
	ConsoleCommands =
	{
		alias =
		{
			Subcommands =
			{
				list =
				{
					HelpString = "Lists all your aliases",
					Handler = HandleConsoleCmdAliasList,
				},  -- list

				remove =
				{
					HelpString = "Removes an existing alias",
					Handler = HandleConsoleCmdAliasRemove,
					ParameterCombinations =
					{
						{
							Params = [["From"]],
							Help = "Removes the alias previously defined for \"From\"",
						},
					},
				},  -- remove

				set =
				{
					HelpString = "Sets an alias from one command to another",
					Handler = HandleConsoleCmdAliasSet,
					ParameterCombinations =
					{
						{
							Params = [["From" "To"]],
							Help = "Set an alias for command \"From\" as command \"To\"",
						},
					},
				},  -- set
			},  -- Subcommands
		},  -- alias
	},  -- ConsoleCommands
	
	Permissions =
	{
		["aliases.alias.list"] =
		{
			Description = "Allows players to show a list of all their currently defined aliases",
			RecommendedGroups = "everyone",
		},
		["aliases.alias.remove"] =
		{
			Description = "Allows players to remove an alias they have defined earlier",
			RecommendedGroups = "everyone",
		},
		["aliases.alias.set"] =
		{
			Description = "Allows players to define their aliases",
			RecommendedGroups = "everyone",
		},
	},  -- Permissions
}




