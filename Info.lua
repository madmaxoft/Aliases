
-- Info.lua

-- Declares the plugin metadata, commands, permissions etc.





g_PluginInfo =
{
	Name = "Aliases",
	Date = "2015-05-10",
	
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
	}
}




