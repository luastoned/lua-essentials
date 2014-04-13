--[[

	==================================================
	File:		patch.lua
	Author:		@luastoned
	Version:	v1.0
	==================================================

--]]

--------------------------------------------------
-- Global
--------------------------------------------------

include = dofile

function printf(fmt, ...)
	io.write(string.format(fmt, ...))
end

function runString(str)
	local ok, err = pcall(loadstring(str))
	if (not ok) then
		print(err)
	end
	return ok
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

--------------------------------------------------
-- Debug
--------------------------------------------------

function debug.getparams(f)
	local co = coroutine.create(f)
	local params = {}
	debug.sethook(co, function(event, line)
		local i, k, v = 1, debug.getlocal(co, 2, 1)
		while k do
			if k ~= "(*temporary)" then
				table.insert(params, k)
			end
			i = i+1
			k, v = debug.getlocal(co, 2, i)
		end
		coroutine.yield()
	end, "c")
	
	local res = coroutine.resume(co)
	return params
end

--------------------------------------------------
-- File
--------------------------------------------------

-- If it doesn't already exist create a global file table
file = file or {}
file.rename = os.rename

function file.read(str)
	local fh = io.open(str, "r")
	if (fh == nil) then
		return ""
	end
	
	str = fh:read("*a")
	fh:close()
	return str
end

function file.write(str, src)
	local fh = io.open(str, "w")
	if (fh == nil) then
		return false
	end
	
	fh:write(src or "")
	fh:close()
	return true
end

function file.append(str, src)
	local fh = io.open(str, "a+")
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

	local n = num or 0
	s = string.format("%x", s)
	s = Hex2Bin(s)

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
	return num -- return math.min(high, math.max(num, low))
end

function math.round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------
-- String
--------------------------------------------------

-- character table string
local base64_table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
function string.decBase64(str)
    str = string.gsub(str, "[^" .. base64_table .. "=]", "")
    return (string.gsub(str, ".", function(x)
        if (x == "=") then return "" end
        local r, f = "", (string.find(base64_table, x) - 1)
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

function string.encBase64(str)
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
		return string.sub(base64_table, c + 1, c + 1)
	end) .. ({"", "==", "="})[#str % 3 + 1])
end

function string.split(str, separator, bPattern)
	if (not separator or separator == "") then return string.toTable(str) end

	local ret = {}
	local index, lastPosition = 1, 1

	-- Escape all magic characters in separator
	if not bPattern then separator = string.gsub(separator, "[%-%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1") end

	-- Find the parts
	for startPosition, endPosition in string.gmatch(str, "()" .. separator .. "()") do
		ret[index] = string.sub(str, lastPosition, startPosition - 1)
		index = index + 1

		-- Keep track of the position
		lastPosition = endPosition
	end

	-- Add last part by using the position we stored
	ret[index] = string.sub(str, lastPosition)
	return ret
end

function string.toTable(str, num)
	num = num or 1
	local tbl = {}
	for i = 1, string.len(str), num do
		table.insert(tbl, string.sub(str, i, i + num - 1))
	end
	return tbl
end

--------------------------------------------------
-- Table
--------------------------------------------------

function table.copy(tbl, lookup_tbl)
	local copy = {}
	setmetatable(copy, getmetatable(tbl))
	
	for k, v in pairs(tbl) do
		if (type(v) ~= "table") then
			copy[k] = v
		else
			lookup_tbl = lookup_tbl or {}
			lookup_tbl[tbl] = copy
			if lookup_tbl[v] then
				copy[k] = lookup_tbl[v]
			else
				copy[k] = table.copy(v, lookup_tbl)
			end
		end
	end
	
	return copy
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
		
		local idt = ""
		if nice then
			idt = string.rep("\t", indent)
		end

		local sequential = table.isSequential(tbl)

		for k, v in pairs(tbl) do
			str = str .. idt .. tab

			if not sequential then
				if type(k) == "number" or type(k) == "boolean" then
					k = "[" .. tostring(k) .. "]" .. tab .. "="
				else
					k = tostring(k) .. tab .. "="
				end
			else
				k = ""
			end

			if type(v) == "table" and not done[v] then
				done [v] = true
				str = str .. k .. tab .. "{" .. nl .. makeTable(v, nice, indent + 1, done)
				str = str .. idt .. tab .. "}," .. nl

			else
				if type(v) == "string" then
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