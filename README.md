This is a plugin for [MCServer](http://mc-server.org) that allows players to define aliases for in-game commands and even chat messages. Server admins can define their aliases for console commands.

This makes it easier to use long commands - you can define a shorter version of the command, and even include the initial parameters. For example: 
 
 - "/td" -> "/time set day": By using the simple "/td" command you can set the time to day in the world 
 - "/ts" -> "/time set": Now you can use commands such as "/ts night" to set night in the world 
 - (console) "kx" -> "kick xoft I hate you because": Now you can kick me really fast using the console command "kx no reason" 
 	

# Commands

### General
| Command | Permission | Description |
| ------- | ---------- | ----------- |
|/alias list | aliases.alias.list | Lists all your aliases|
|/alias remove | aliases.alias.remove | Removes an existing alias|
|/alias set | aliases.alias.set | Sets an alias from one command to another|



# Permissions
| Permissions | Description | Commands | Recommended groups |
| ----------- | ----------- | -------- | ------------------ |
| aliases.alias.list | Allows players to show a list of all their currently defined aliases | `/alias list` | everyone |
| aliases.alias.remove | Allows players to remove an alias they have defined earlier | `/alias remove` | everyone |
| aliases.alias.set | Allows players to define their aliases | `/alias set` | everyone |
