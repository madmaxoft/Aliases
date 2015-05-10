
-- Storage.lua

-- Implements the DB backend for the plugin





g_DB = {}





--- Creates the table of the specified name and columns[]
-- If the table exists, any columns missing are added; existing data is kept
-- a_Columns is an array of {ColumnName, ColumnType}, it will receive a map of LowerCaseColumnName => {ColumnName, ColumnType}
function g_DB:CreateDBTable(a_TableName, a_Columns)
	-- Check params:
	assert(self)
	assert(a_TableName)
	assert(a_Columns)
	assert(a_Columns[1])
	assert(a_Columns[1][1])
	
	-- Try to create the table first
	local ColumnDefs = {}
	for _, col in ipairs(a_Columns) do
		table.insert(ColumnDefs, col[1] .. " " .. (col[2] or ""))
	end
	local sql = "CREATE TABLE IF NOT EXISTS '" .. a_TableName .. "' ("
	sql = sql .. table.concat(ColumnDefs, ", ");
	sql = sql .. ")";
	if (not(self:DBExec(sql))) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot create DB Table " .. a_TableName)
		return false
	end
	-- SQLite doesn't inform us if it created the table or not, so we have to continue anyway
	
	-- Add the map of LowerCaseColumnName => {ColumnName, ColumnType} to a_Columns:
	for _, col in ipairs(a_Columns) do
		a_Columns[string.lower(col[1])] = col
	end
	
	-- Check each column whether it exists
	-- Remove all the existing columns from a_Columns:
	local RemoveExistingColumnFromDef = function(UserData, NumCols, Values, Names)
		-- Remove the received column from a_Columns. Search for column name in the Names[] / Values[] pairs
		for i = 1, NumCols do
			if (Names[i] == "name") then
				local ColumnName = Values[i]:lower()
				-- Search the a_Columns if they have that column:
				for idx, col in ipairs(a_Columns) do
					if (ColumnName == col[1]:lower()) then
						table.remove(a_Columns, idx)
						break
					end
				end  -- for col - a_Columns[]
			end
		end  -- for i - Names[] / Values[]
		return 0
	end
	if (not(self:DBExec("PRAGMA table_info(" .. a_TableName .. ")", RemoveExistingColumnFromDef))) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot query DB table structure")
		return false
	end
	
	-- Create the missing columns
	-- a_Columns now contains only those columns that are missing in the DB
	if (a_Columns[1]) then
		LOGINFO(PLUGIN_PREFIX .. "Database table \"" .. a_TableName .. "\" is missing " .. #a_Columns .. " columns, fixing now.")
		for _, col in ipairs(a_Columns) do
			if (not(self:DBExec("ALTER TABLE '" .. a_TableName .. "' ADD COLUMN " .. col[1] .. " " .. (col[2] or "")))) then
				LOGWARNING(PLUGIN_PREFIX .. "Cannot add DB table \"" .. a_TableName .. "\" column \"" .. col[1] .. "\"")
				return false
			end
		end
		LOGINFO(PLUGIN_PREFIX .. "Database table \"" .. a_TableName .. "\" columns fixed.")
	end
	
	return true
end





--- Executes an SQL query on the SQLite DB
-- Returns true on success, false on failure
function g_DB:DBExec(a_SQL, a_Callback, a_CallbackParam)
	assert(self)
	assert(a_SQL)
	
	local ErrCode = self.DB:exec(a_SQL, a_Callback, a_CallbackParam)
	if (ErrCode ~= sqlite3.OK) then
		LOGWARNING(PLUGIN_PREFIX .. "Error " .. ErrCode .. " (" .. self.DB:errmsg() ..
			") while processing SQL command >>" .. a_SQL .. "<<"
		)
		return false
	end
	return true
end





--- Executes the SQL statement, substituting "?" in the SQL with the specified params
-- Calls a_Callback for each row
-- The callback receives a dictionary table containing the row values (stmt:nrows())
-- Returns false and error message on failure, or true on success
function g_DB:ExecuteStatement(a_SQL, a_Params, a_Callback)
	-- Check params:
	assert(self)
	assert(self.DB)
	assert(type(a_SQL) == "string")
	assert((a_Params == nil) or (type(a_Params) == "table"))
	assert((a_Callback == nil) or (type(a_Callback) == "function"))
	
	local Stmt, ErrCode, ErrMsg = self.DB:prepare(a_SQL)
	if (Stmt == nil) then
		LOGWARNING("Cannot prepare SQL \"" .. a_SQL .. "\": " .. (ErrCode or "<unknown>") .. " (" .. (ErrMsg or "<no message>") .. ")")
		LOGWARNING("  Params = {" .. table.concat(a_Params, ", ") .. "}")
		return nil, (ErrMsg or "<no message")
	end
	if (a_Params ~= nil) then
		Stmt:bind_values(unpack(a_Params))
	end
	if (a_Callback == nil) then
		Stmt:step()
	else
		for v in Stmt:nrows() do
			a_Callback(v)
		end
	end
	Stmt:finalize()
	return true;
end





--- Converts the raw DB data into a PlayerState's Alias definition
function g_DB:FixupAliasAfterLoad(a_DBValues)
	local res = {}
	res.From         = a_DBValues.AliasFrom
	res.To           = a_DBValues.AliasTo
	res.CreationDate = a_DBValues.CreationDate
	res.PlayerName   = a_DBValues.PlayerName
	return res
end





--- Inserts the specified alias into the DB
-- Returns true on success, false and message on failure
function g_DB:InsertAlias(a_Alias)
	-- Check params:
	assert(type(a_Alias) == "table")
	assert(type(a_Alias.From) == "string")
	assert(type(a_Alias.To) == "string")
	assert(type(a_Alias.PlayerName) == "string")
	assert(tonumber(a_Alias.CreationDate))
	
	-- Insert into DB:
	return self:ExecuteStatement(
		"INSERT INTO Aliases (AliasFrom, AliasTo, PlayerName, CreationDate) VALUES (?, ?, ?, ?)",
		{
			a_Alias.From, a_Alias.To, a_Alias.PlayerName, tonumber(a_Alias.CreationDate)
		}
	)
end





--- Returns an array of aliases for the specified player
-- If there are no aliases in the DB, returns an empty table
function g_DB:LoadAliasesForPlayer(a_PlayerName)
	-- Check params:
	assert(self ~= nil)
	assert(type(a_PlayerName) == "string")
	
	-- Query the DB:
	local res = {}
	self:ExecuteStatement(
		"SELECT * FROM Aliases WHERE PlayerName = ?",
		{
			a_PlayerName
		},
		function (a_Values)
			table.insert(res, self:FixupAliasAfterLoad(a_Values))
		end
	)
	
	return res
end





function InitializeStorage()
	-- Open the DB:
	local DBFile = "Aliases.sqlite"
	local ErrCode, ErrMsg
	g_DB.DB, ErrCode, ErrMsg = sqlite3.open(DBFile)
	if not(g_DB.DB) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot open database \"" .. DBFile .. "\": " .. ErrCode .. " / " .. ErrMsg)
		error(ErrCode .. " / " .. ErrMsg)  -- Abort the plugin
	end
	
	-- Create the DB structure, if not already present:
	local AliasesColumns =
	{
		{ "PlayerName",   "TEXT" },
		{ "AliasFrom",    "TEXT" },
		{ "AliasTo",      "TEXT" },
		{ "CreationDate", "INTEGER" },
	}
	if (
		not(g_DB:CreateDBTable("Aliases", AliasesColumns))
	) then
		LOGWARNING(PLUGIN_PREFIX .. "Cannot create DB tables!");
		error("Cannot create DB tables!");
	end
end




