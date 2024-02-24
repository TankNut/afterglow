mysql = mysql or {}

local writeLog = log.Category("MySQL")

if not mysqloo then
	require("mysqloo")
end


local QUERY_SELECT = 1
local QUERY_INSERT = 2
local QUERY_INSERT_IGNORE = 3
local QUERY_UPDATE = 4
local QUERY_UPSERT = 5
local QUERY_DELETE = 6
local QUERY_DROP = 7
local QUERY_TRUNCATE = 8
local QUERY_CREATE = 9
local QUERY_ALTER = 10

local QUERY = {}
QUERY.__index = QUERY


function QUERY:New(queryType, tableName)
	return setmetatable({
		QueryType = queryType,
		TableName = tableName,

		SelectList = {},
		InsertList = {},
		UpdateList = {},
		CreateList = {},
		WhereList = {},
		OrderByList = {},
		AlterList = {},
		PrimaryKeyList = {}
	}, QUERY)
end


function QUERY:Escape(str) return mysql:Escape(str) end
function QUERY:Where(val) table.insert(self.WhereList, val) end

function QUERY:WhereEqual(key, val) table.insert(self.WhereList, string.format("`%s` = '%s'", key, self:Escape(val))) end
function QUERY:WhereNotEqual(key, val) table.insert(self.WhereList, string.format("`%s` = '%s'", key, self:Escape(val))) end

function QUERY:WhereLike(key, val, format)
	format = format or "%%%s%%"
	table.insert(self.WhereList, string.format("`%s` LIKE '" .. format .. "'", key, self:Escape(val)))
end

function QUERY:WhereNotLike(key, val, format)
	format = format or "%%%s%%"
	table.insert(self.WhereList, string.format("`%s` NOT LIKE '" .. format .. "'", key, self:Escape(val)))
end

function QUERY:WhereGT(key, val) table.insert(self.WhereList, string.format("`%s` > '%s'", key, self:Escape(val))) end
function QUERY:WhereLT(key, val) table.insert(self.WhereList, string.format("`%s` < '%s'", key, self:Escape(val))) end
function QUERY:WhereGTE(key, val) table.insert(self.WhereList, string.format("`%s` >= '%s'", key, self:Escape(val))) end
function QUERY:WhereLTE(key, val) table.insert(self.WhereList, string.format("`%s` <= '%s'", key, self:Escape(val))) end

function QUERY:WhereIn(key, values)
	local map = table.Map(values, function(val) return string.format("'%s'", self:Escape(val)) end)

	table.insert(self.WhereList, string.format("`%s` IN (%s)", key, table.concat(map, ", ")))
end

function QUERY:OrderByDesc(key) table.insert(self.OrderByList, string.format("`%s` DESC", key)) end
function QUERY:OrderByAsc(key) table.insert(self.OrderByList, string.format("`%s` ASC", key)) end

function QUERY:Select(key) table.insert(self.SelectList, string.format("`%s`", key)) end
function QUERY:Insert(key, val) table.insert(self.InsertList, {string.format("`%s`", key), string.format("'%s'", self:Escape(val))}) end
function QUERY:Update(key, val) table.insert(self.UpdateList, {string.format("`%s`", key), string.format("'%s'", self:Escape(val))}) end

function QUERY:Create(key, val, primaryKey)
	table.insert(self.CreateList, string.format("`%s` %s", key, val))

	if primaryKey then
		table.insert(self.PrimaryKeyList, string.format("`%s`", key))
	end
end

function QUERY:Add(key, val) table.insert(self.AlterList, string.format("ADD COLUMN `%s` %s", key, val)) end
function QUERY:Drop(key) table.insert(self.AlterList, string.format("DROP COLUMN `%s`", key)) end

function QUERY:Limit(val) self.LimitVal = val end
function QUERY:Offset(val) self.OffsetVal = val end


function QUERY:BuildSelect()
	local fields = #self.SelectList > 0 and table.concat(self.SelectList, ", ") or "*"
	local where = #self.WhereList > 0 and " WHERE " .. table.concat(self.WhereList, " AND ") or ""
	local order = #self.OrderByList > 0 and " ORDER BY " .. table.concat(self.OrderByList, ", ") or ""
	local limit = self.LimitVal and " LIMIT " .. self.LimitVal or ""
	local offset = self.OffsetVal and " OFFSET " .. self.OffsetVal or ""

	return string.format("SELECT %s FROM `%s`%s%s%s%s", fields, self.TableName, where, order, limit, offset)
end


function QUERY:BuildInsert(ignore)
	local insert = ignore and "INSERT IGNORE INTO" or "INSERT INTO"
	local keys = table.Map(self.InsertList, function(val) return val[1] end)
	local values = table.Map(self.InsertList, function(val) return val[2] end)

	if #keys == 0 then
		return
	end

	return string.format("%s `%s` (%s) VALUES (%s)", insert, self.TableName, table.concat(keys, ", "), table.concat(values, ", "))
end


function QUERY:BuildUpdate()
	local values = table.Map(self.UpdateList, function(val) return string.format("%s = %s", val[1], val[2]) end)
	local where = #self.WhereList > 0 and " WHERE " .. table.concat(self.WhereList, " AND ") or ""

	return string.format("UPDATE `%s` SET %s%s", self.TableName, table.concat(values, ", "), where)
end


function QUERY:BuildUpsert()
	local insert = self:BuildInsert()
	local values = table.Map(self.InsertList, function(val) return string.format("%s = %s", val[1], val[2]) end)

	return string.format("%s ON DUPLICATE KEY UPDATE %s", insert, table.concat(values, ", "))
end


function QUERY:BuildDelete()
	local where = #self.WhereList > 0 and " WHERE " .. table.concat(self.WhereList, " AND ") or ""
	local order = #self.OrderByList > 0 and " ORDER BY " .. table.concat(self.OrderByList, ", ") or ""
	local limit = self.LimitVal and " LIMIT " .. self.LimitVal or ""

	return string.format("DELETE FROM `%s`%s%s%s", self.TableName, where, order, limit)
end


function QUERY:BuildDrop() return string.format("DROP TABLE `%s`", self.TableName) end
function QUERY:BuildTruncate() return string.format("TRUNCATE TABLE `%s`", self.TableName) end


function QUERY:BuildCreate()
	local columns = table.concat(self.CreateList, ", ") or ""
	local primary = #self.PrimaryKeyList > 0 and string.format(", PRIMARY KEY(%s)", table.concat(self.PrimaryKeyList, ", ")) or ""

	return string.format("CREATE TABLE IF NOT EXISTS `%s`(%s%s)", self.TableName, columns, primary)
end


function QUERY:BuildAlter()
	return string.format("ALTER TABLE `%s` %s", self.TableName, table.concat(self.AlterList, ", "))
end


function QUERY:Execute(callback)
	local query

	if self.QueryType == QUERY_SELECT then
		query = self:BuildSelect()
	elseif self.QueryType == QUERY_INSERT then
		query = self:BuildInsert()
	elseif self.QueryType == QUERY_INSERT_IGNORE then
		query = self:BuildInsert(true)
	elseif self.QueryType == QUERY_UPDATE then
		query = self:BuildUpdate()
	elseif self.QueryType == QUERY_UPSERT then
		query = self:BuildUpsert()
	elseif self.QueryType == QUERY_DELETE then
		query = self:BuildDelete()
	elseif self.QueryType == QUERY_DROP then
		query = self:BuildDrop()
	elseif self.QueryType == QUERY_TRUNCATE then
		query = self:BuildTruncate()
	elseif self.QueryType == QUERY_CREATE then
		query = self:BuildCreate()
	elseif self.QueryType == QUERY_ALTER then
		query = self:BuildAlter()
	end

	if query then
		return mysql:Query(query, callback)
	end
end


function mysql:Select(tableName) return QUERY:New(QUERY_SELECT, tableName) end
function mysql:Insert(tableName) return QUERY:New(QUERY_INSERT, tableName) end
function mysql:InsertIgnore(tableName) return QUERY:New(QUERY_INSERT_IGNORE, tableName) end
function mysql:Update(tableName) return QUERY:New(QUERY_UPDATE, tableName) end
function mysql:Upsert(tableName) return QUERY:New(QUERY_UPSERT, tableName) end
function mysql:Delete(tableName) return QUERY:New(QUERY_DELETE, tableName) end
function mysql:Drop(tableName) return QUERY:New(QUERY_DROP, tableName) end
function mysql:Truncate(tableName) return QUERY:New(QUERY_TRUNCATE, tableName) end
function mysql:Create(tableName) return QUERY:New(QUERY_CREATE, tableName) end
function mysql:Alter(tableName) return QUERY:New(QUERY_ALTER, tableName) end


function mysql:Begin()
	self.Transaction = {}

	writeLog("Transaction: START")
end


local function startQuery(query, suppress, callback)
	local cr = coroutine.running()

	if isfunction(callback) then
		query.onSuccess = function(_, data)
			if suppress then
				callback(true, data, query.lastInsert and tonumber(query:lastInsert()))
			else
				callback(data, query.lastInsert and tonumber(query:lastInsert()))
			end
		end

		query.onError = function(_, err)
			if suppress then
				callback(false, err)
			else
				error(string.format("MySQL Error:\n  %s\n", err))
			end
		end

		query:start()
	elseif cr and not callback then
		query.onSuccess = function(_, data)
			if suppress then
				coroutine.Resume(cr, true, data, query.lastInsert and tonumber(query:lastInsert()))
			else
				coroutine.Resume(cr, data, query.lastInsert and tonumber(query:lastInsert()))
			end
		end

		query.onError = function(_, err)
			if suppress then
				coroutine.Resume(cr, false, err)
			else
				error(string.format("MySQL Error:\n  %s\n", err))
			end
		end

		query:start()

		return true
	else
		if not suppress then
			query.onError = function(_, err)
				error(string.format("MySQL Error:\n  %s\n", err))
			end
		end

		query:start()
	end
end


function mysql:Commit(callback)
	writeLog("Transaction: COMMIT")

	if not self.Transaction then
		error("MySQL tried to commit a transaction that doesn't exist!")
	elseif #self.Transaction < 1 then
		self.Transaction = nil

		if isfunction(callback) then
			callback(suppress and true)
		end

		return
	end

	local transaction = self.Connection:createTransaction()

	for _, v in pairs(self.Transaction) do
		local queryObject = self.Connection:query(v)

		transaction:addQuery(queryObject)
	end

	local yield = startQuery(transaction, self.SuppressState, callback)

	self.Transaction = nil
	self.SuppressState = nil

	if yield then
		return coroutine.yield()
	end
end


function mysql:Query(query, callback)
	if self.Transaction then
		table.insert(self.Transaction, query)

		writeLog("Transaction: %s", query)

		return
	end

	writeLog("Query: %s", query)

	local queryObject = self.Connection:query(query)
	local yield = startQuery(queryObject, self.SuppressState, callback)

	self.SuppressState = nil

	if yield then
		return coroutine.yield()
	end
end


function mysql:Suppress()
	self.SuppressState = true
end


function mysql:Escape(str)
	return self.Connection:escape(str)
end


function mysql:Connect(host, username, password, database, port)
	if self.Connection and self.Connection:ping() then
		return
	end

	self.Connection = mysqloo.connect(host, username, password, database, port or 3306)
	self.Connection.onConnected = function()
		local ok, err = self.Connection:setCharacterSet("utf8mb4")

		if ok then
			self:Query(string.format("ALTER DATABASE %s CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci", database))
		else
			error(string.format("Failed to set MySQL encoding:\n  %s", err))
		end

		hook.Run("DatabaseConnected")
	end

	self.Connection.onConnectionFailed = function(_, err)
		hook.Run("DatabaseConnectionFailed", err, host, username, database, port)
	end

	self.Connection:connect()
end


function mysql:Disconnect()
	self.Connection:disconnect(true)
end


function GM:DatabaseConnected()
end


function GM:DatabaseConnectionFailed(err, host, username, database, port)
	error(string.format("Failed to connect to '%s' at %s@%s:%s:\n  %s", database, username, host, port, err))
end
