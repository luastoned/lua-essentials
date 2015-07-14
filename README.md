# Lua Essentials

> Lua is a minimalistic language, “no-batteries-included” ..

This all-in-one file extens the standard Lua API with helpful functions.

---

### Core Functions

- **include(**file**)**  a clone of dofile, just for convenience
	- file - a .lua file, full path or local to the current executable
- printf(fmt, ...)
	- fmt - format for printing, see [lua.org](http://lua.org)
    - ... - varags
- clear()
- get()

### Meta Changes

- string __index
- string __mod
- string __mul

### Library Functions

Libraries are extended by following functions.

#### debug

- debug.getparams(func)
```lua
-- this is lua
function add(arg1, num2)
	return arg1 + num2
end
debug.getparams(add) ->
```

#### file

- file.read(name, mode)
- file.write(name, content, mode)
- file.append(name, content, mode)
- file.rename(name, name)
- file.delete(name)

#### math

- math.round(num)

#### string

- string.hax

#### table

- table.hax

