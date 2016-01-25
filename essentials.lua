local essentials = {
    _VERSION        = "essentials.lua v1.1.0",
    _DESCRIPTION    = "Extends the standard Lua API with helpful functions.",
    _URL            = "https://github.com/luastoned/lua-essentials",
    _LICENSE        = [[Copyright (c) 2015 @LuaStoned]]
}

-- http://www.emoji-cheat-sheet.com/

--------------------------------------------------
-- Local Helpers
--------------------------------------------------

local function patternEscape(str)
	return string.gsub(str, "[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0")
	--return string.gsub(str, "[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
	--return string.gsub(str, "[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
end

local patternReplacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z",
}

local function patternSafe(str)
	return string.gsub(str, ".", patternReplacements)
end

local function expandTab(str, num)
	return string.gsub(str, "([^\t]*)\t", function(s)
		return s .. string.rep(" ", num - #s % num)
	end)
end

local function expandTabs(str, num)
	num = num or 8
	if not string.find(str, "\n") then
		return expandTab(str, num)
	end
	
	local res = {}
	for k, line in pairs(string.split(str, "\n")) do
		res[k] = expandTab(line, num)
	end
	return table.concat(res, "\n")
end

local function getMetaMethod(func, method)
	local ok, m = pcall(function(x)
		return getmetatable(x)[method]
	end, func)
	if (type(m) ~= "function") then
		m = nil
	end
	return m
end

local function isCallable(func)
	if (type(func) == "function") then
		return func
	end
	return getMetaMethod(func, "__call")
end

--------------------------------------------------
-- Global Defines and Functions
--------------------------------------------------

include = dofile

function printf(fmt, ...)
	io.write(string.format(fmt, ...))
end

function runString(str)
	local runStr = rawget(_G, "loadstring") or load
	local ok, err = pcall(runStr(str))
	if (not ok) then
		print(err)
	end
	return ok
end

function eval(str)
	local runStr = rawget(_G, "loadstring") or load
	return runStr("return " .. str)()
end

function profile(func, ...)
	local t = os.clock()
	func(...)
	return os.clock() - t
end

function clear()
	os.execute("cls")
end

function get()
	return io.stdin:read()
end

function lerp(delta, from, to)
	if (delta > 1) then return to end
	if (delta < 0) then return from end
	return from + (to - from) * delta
end

--------------------------------------------------
-- Meta Additions aka Magic
--------------------------------------------------

-- http://www.lua.org/manual/5.1/manual.html#2.8

local stringMeta = getmetatable("")

stringMeta.__index = function(self, key)
	if (string[key]) then
		return string[key]
	elseif (tonumber(key)) then
		return string.sub(self, key, key)
	else
		error("attempt to index a string value with bad key ('" .. tostring(key) .. "' is not part of the string library)", 2)
	end
end

stringMeta.__mul = function(self, num)
	return string.rep(self, num)
end

stringMeta.__mod = function(self, arg)
	if (type(arg) == "string") then
		return string.format(self, arg)
	else
		return string.format(self, unpack(arg))
	end
end

--------------------------------------------------
-- Debug
--------------------------------------------------

-- http://leafo.net/guides/dynamic-scoping-in-lua.html
function debug.dynamic(name)
	local level = 2
	-- iterate over 
	while true do
		local i = 1
		-- iterate over each local by index
		while true do
			local found_name, found_val = debug.getlocal(level, i)
			if not found_name then break end
			if found_name == name then
				return found_val
			end
			i = i + 1
		end
		level = level + 1
	end
end

-- http://www.facepunch.com/showthread.php?884409-debug.getparams-Get-the-names-of-a-function-s-arguments
function debug.getparams(func)
	local co = coroutine.create(func)
	local params = {}
	debug.sethook(co, function(event, line)
		local i, k, v = 1, debug.getlocal(co, 2, 1)
		while k do
			if k ~= "(*temporary)" then
				table.insert(params, k)
			end
			i = i + 1
			k, v = debug.getlocal(co, 2, i)
		end
		coroutine.yield()
	end, "c")
	
	local res = coroutine.resume(co)
	return params
end

function debug.getparamnames(func)
    local func_paramInfoDict = debug.getinfo(func, 'u')
    local func_paramCount = func_paramInfoDict.nparams
    local func_isVarArg = func_paramInfoDict.isvararg
    local paramNameList = {}
    for i = 1, func_paramCount do
        local param_name, param_value = debug.getlocal(func, i)
        paramNameList[i] = param_name
    end
    return paramNameList, func_isVarArg
end

-- Argument Check
local prevFunc, prevLine, curArg = "", 0, 0
local function requireArg(arg, expected)
	local info = debug.getinfo(2)
	if (prevLine >= info.currentline or prevFunc ~= info.name) then
		curArg = 0
	end
	
	curArg = curArg  + 1
	prevFunc = info.name
	prevLine = info.currentline
	assert(type(arg) == expected, string.format("bad argument #%d to '%s' (%s expected, got %s)", curArg, info.name, expected, type(arg)))
end

--------------------------------------------------
-- File
--------------------------------------------------

-- If it doesn't already exist create a global file table
file = file or {}
file.delete = os.remove
file.rename = os.rename

file.fileSeperator = string.sub(package.config, 1, 1)
file.fileSeperator = string.match(package.config, "^(%S+)\n")

function file.catFile(...)
	return table.concat({...}, file.fileSeperator)
end

function file.read(str, mode)
	local fh = io.open(str, mode or "r")
	if (fh == nil) then
		return ""
	end
	
	str = fh:read("*a")
	fh:close()
	return str
end

function file.write(str, src, mode)
	local fh = io.open(str, mode or "w")
	if (fh == nil) then
		return false
	end
	
	fh:write(src or "")
	fh:close()
	return true
end

function file.append(str, src, mode)
	local fh = io.open(str, mode or "a+")
	if (fh == nil) then
		return false
	end
	
	fh:write(src or "")
	fh:close()
	return true
end

--------------------------------------------------
-- Math
--------------------------------------------------

local hex2bin = {
	["0"] = "0000",
	["1"] = "0001",
	["2"] = "0010",
	["3"] = "0011",
	["4"] = "0100",
	["5"] = "0101",
	["6"] = "0110",
	["7"] = "0111",
	["8"] = "1000",
	["9"] = "1001",
	["a"] = "1010",
	["b"] = "1011",
	["c"] = "1100",
	["d"] = "1101",
	["e"] = "1110",
	["f"] = "1111",
}

local bin2hex = {
	["0000"] = "0",
	["0001"] = "1",
	["0010"] = "2",
	["0011"] = "3",
	["0100"] = "4",
	["0101"] = "5",
	["0110"] = "6",
	["0111"] = "7",
	["1000"] = "8",
	["1001"] = "9",
	["1010"] = "A",
	["1011"] = "B",
	["1100"] = "C",
	["1101"] = "D",
	["1110"] = "E",
	["1111"] = "F",
}

function math.hex2bin(s)
	-- s -> hexadecimal string
	local ret = ""
	local i = 0

	for i in string.gfind(s, ".") do
		i = string.lower(i)
		ret = ret .. hex2bin[i]
	end

	return ret
end

function math.bin2hex(s)
	-- s -> binary string
	local l = 0
	local h = ""
	local b = ""
	local rem

	l = string.len(s)
	rem = l % 4
	l = l - 1
	h = ""

	-- need to prepend zeros to eliminate mod 4
	if (rem > 0) then
		s = string.rep("0", 4 - rem) .. s
	end

	for i = 1, l, 4 do
		b = string.sub(s, i, i + 3)
		h = h..bin2hex[b]
	end

	return h
end

function math.bin2dec(s)
	-- return tonumber(bin,2)
	-- s -> binary string
	local num = 0
	local ex = string.len(s) - 1
	local l = 0

	l = ex + 1
	for i = 1, l do
		b = string.sub(s, i, i)
		if b == "1" then
			num = num + 2 ^ ex
		end
		ex = ex - 1
	end

	return string.format("%u", num)
end

function math.dec2bin(s, num)
	-- s -> Base10 string
	-- num -> string length to extend to
	
	--[[
	local str = string.format("%o",int)

	local a = {
			["0"]="000",["1"]="001", ["2"]="010",["3"]="011",
        		["4"]="100",["5"]="101", ["6"]="110",["7"]="111"
		  }
	local bin = string.gsub( str, "(.)", function ( d ) return a[ d ] end )
	return bin
	]]

	local n = num or 0
	s = string.format("%x", s)
	s = math.hex2bin(s)

	while string.len(s) < n do
		s = "0" .. s
	end

	return s
end

function math.hex2dec(s)
	-- s -> hexadecimal string
	local s = math.hex2bin(s)
	return math.bin2dec(s)
end

function math.dec2hex(s)
	-- s -> Base10 string
	s = string.format("%x", s)
	return s
end

function math.clamp(num, low, high)
	if (num < low) then return low end
	if (num > high) then return high end
	return num
	--return math.min(high, math.max(num, low))
end

function math.round(num, idp)
	local e = 10^(idp or 0)
	return math.floor(num * e + 0.5) / e
end

--------------------------------------------------
-- String
--------------------------------------------------

-- character table string
local base64table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function string.decodeBase64(str)
    str = string.gsub(str, "[^" .. base64table .. "=]", "")
    return (string.gsub(str, ".", function(x)
        if (x == "=") then return "" end
        local r, f = "", (string.find(base64table, x) - 1)
        for i = 6, 1, -1 do
			r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
		end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if (#x ~= 8) then return "" end
        local c = 0
        for i=1, 8 do
			c =c + (string.sub(x, i, i) == "1" and 2 ^ (8 - i) or 0)
		end
        return string.char(c)
    end))
end

function string.encodeBase64(str)
	return ((string.gsub(str, ".", function(x)
		local r, b = "", string.byte(x)
		for i = 8, 1, -1 do
			r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
		end
		return r
	end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
		if (#x < 6) then return "" end
		local c = 0
		for i = 1, 6 do
			c = c + (string.sub(x, i, i) == "1" and 2 ^ (6 - i) or 0)
		end
		return string.sub(base64table, c + 1, c + 1)
	end) .. ({"", "==", "="})[#str % 3 + 1])
end

function string.getChar(str, pos)
	return string.sub(str, pos, pos)
end

function string.setChar(str, pos, char)
	local pre = string.sub(str, 0, pos - 1)
	local post = string.sub(str, pos + 1)
	return pre .. char .. post
end

function string.trim(str, char)
	char = char and patternSafe(char) or "%s"
	return string.match(str, "^" .. char .. "*(.-)" .. char .. "*$") or str
end

function string.left(str, num)
	return string.sub(str, 1, num)
end

function string.right(str, num)
	return string.sub(str, -num)
end

function string.replace(str, find, replace)
	return string.gsub(str, patternSafe(find), string.gsub(replace, "%%", "%%%1"))
end

function string.split(str, separator, isPattern)
	if (not separator or separator == "") then return string.toTable(str) end

	local tbl = {}
	local index, lastPosition = 1, 1

	-- Escape all magic characters in separator
	if not isPattern then separator = string.gsub(separator, "[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1") end

	-- Find the parts
	for startPosition, endPosition in string.gmatch(str, "()" .. separator .. "()") do
		tbl[index] = string.sub(str, lastPosition, startPosition - 1)
		index = index + 1

		-- Keep track of the position
		lastPosition = endPosition
	end

	-- Add last part by using the position we stored
	tbl[index] = string.sub(str, lastPosition)
	return tbl
end

function string.toTable(str, num)
	num = num or 1
	local tbl = {}
	for i = 1, string.len(str), num do
		table.insert(tbl, string.sub(str, i, i + num - 1))
	end
	return tbl
end

function string.fromHex(str, fmt)
	return string.gsub(str, fmt or "..", function(num)
		return string.char(tonumber(num, 16))
	end)
end

function string.toHex(str, fmt)
	return string.gsub(".", function(char)
		return string.format(fmt or "%02X", string.byte(char))
	end)
end

--------------------------------------------------
-- Table
--------------------------------------------------

function table.copy(tbl, lookupTbl)
	local tblCopy = {}
	setmetatable(tblCopy, getmetatable(tbl))
	
	for k, v in pairs(tbl) do
		if (type(v) ~= "table") then
			tblCopy[k] = v
		else
			lookupTbl = lookupTbl or {}
			lookupTbl[tbl] = tblCopy
			if lookupTbl[v] then
				tblCopy[k] = lookupTbl[v]
			else
				tblCopy[k] = table.copy(v, lookupTbl)
			end
		end
	end
	
	return tblCopy
end

function table.count(tbl)
	local i = 0
	for k in pairs(tbl) do i = i + 1 end
	return i
end

function table.forEach(tbl, func)
	for k, v in pairs(tbl) do
		func(k, v)
	end
end

function table.getFirstKey(tbl)
	local k, v = next(tbl)
	return k
end

function table.getFirstValue(tbl)
	local k, v = next(tbl)
	return v
end

function table.getLastKey(tbl)
	local k, v = next(tbl, table.count(tbl) - 1)
	return k
end

function table.getLastValue(tbl)
	local k, v = next(tbl, table.count(tbl) - 1)
	return v
end

function table.findNext(tbl, val)
	local bFound = false
	for k, v in pairs(tbl) do
		if (bFound) then return v end
		if (val == v) then bFound = true end
	end
	return table.getFirstValue(tbl)
end

function table.findPrev(tbl, val)
	local last = table.getLastValue(tbl)
	for k, v in pairs(tbl) do
		if (val == v) then return last end
		last = v
	end
	return last
end

function table.hasKey(tbl, key)
	for k, v in pairs(tbl) do
		if (k == key) then
			return true
		end
	end
	return false
end

function table.hasValue(tbl, val)
	for k, v in pairs(tbl) do
		if (v == val) then
			return true
		end
	end
	return false
end

function table.invert(tbl)
	local inv = {}
	for k, v in pars(tbl) do
		inv[v] = k
	end
	return tbl
end

function table.isSequential(tbl)
	local i = 1
	for k, v in pairs(tbl) do
		if not tonumber(i) or key ~= i then
			return false
		end
		
		i = i + 1
	end
	return true
end

function table.merge(dest, source)
	for k, v in pairs(source) do
		if (type(v) == "table" and type(dest[k]) == "table") then
			-- don't overwrite one table with another;
			-- instead merge them recurisvely
			table.merge(dest[k], v)
		else
			dest[k] = v
		end
	end
	return dest
end

function table.toString(tbl, n, nice)
	nice = nice or true
	
	local nl, tab = "", ""
	if nice then
		nl, tab = "\n", "\t"
	end

	local function makeTable(tbl, nice, indent, done)
		local str = ""
		local done = done or {}
		local indent = indent or 0
		local isSequential = table.isSequential(tbl)
		
		local idt = ""
		if (nice) then
			idt = string.rep("\t", indent)
		end

		for k, v in pairs(tbl) do
			str = str .. idt .. tab

			if (not isSequential) then
				if type(k) == "number" or type(k) == "boolean" then
					k = "[" .. tostring(k) .. "]" .. tab .. "="
				else
					k = tostring(k) .. tab .. "="
				end
			else
				k = ""
			end

			if (type(v) == "table" and not done[v]) then
				done [v] = true
				str = str .. k .. tab .. "{" .. nl .. makeTable(v, nice, indent + 1, done)
				str = str .. idt .. tab .. "}," .. nl

			else
				if (type(v) == "string") then
					v = '"' .. tostring(v) .. '"'
				else
					v = tostring(v)
				end

				str = str .. k .. tab .. v .. "," .. nl
			end
		end
		return str
	end
	
	local str = ""
	if n then
		str = n .. tab .. "=" .. tab
	end
	
	str = str .. "{" .. nl .. makeTable(tbl, nice) .. "}"
	return str
end

function table.print(tbl)
	print(table.toString(tbl))
end

return essentials
