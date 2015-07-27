#
<<<<<<< HEAD
# Makefile for installation.
=======
# essentials.lua Makefile for installation.
>>>>>>> 364267c2b6694d376814c45706876bb18b1d18e0
# Copyright (c) 2015 @LuaStoned
# See LICENSE file for license information.
#

CP = cp -r
RM = rm -f
MK = mkdir -p

PREFIX ?= /usr/local
FILENAME = essentials.lua

MAJVER = 1
MINVER = 0
MICVER = 0
ESNVER = $(MAJVER).$(MINVER).$(MICVER)

LUA_VERSION ?= 5.1
LUA_MODULEDIR = $(PREFIX)/share/lua/$(LUA_VERSION)

LUAJIT_VERSION ?= 2.0.4
<<<<<<< HEAD
LUAJIT_MODULEDIR = $(PREFIX)/share/luajit-$(LUAJIT_VERSION)/
=======
LUAJIT_MODULEDIR = $(PREFIX)/share/luajit-$(LUAJIT_VERSION)
>>>>>>> 364267c2b6694d376814c45706876bb18b1d18e0

default: install
clean: uninstall

install:
	@echo "=== Installing $(FILENAME) v$(ESNVER) to: $(LUAJIT_MODULEDIR) ==="
	$(MK) $(LUA_MODULEDIR)
	$(MK) $(LUAJIT_MODULEDIR)
	$(CP) $(FILENAME) $(LUA_MODULEDIR)
	$(CP) $(FILENAME) $(LUAJIT_MODULEDIR)
	@echo "=== Successfully installed $(FILENAME) ==="

uninstall:
<<<<<<< HEAD
	@echo "=== Uninstalling $(FILENAME) from: $(LUAJIT_MODULEDIR) ==="
	$(RM) $(LUA_MODULEDIR)/$(FILENAME)
	$(RM) $(LUAJIT_MODULEDIR)/$(FILENAME)
	@echo "=== Successfully uninstalled $(FILENAME) ==="
=======
	@echo "=== Uninstalling essentials.lua from: $(LUAJIT_MODULEDIR) ==="
	$(RM) $(LUA_MODULEDIR)/essentials.lua
	$(RM) $(LUAJIT_MODULEDIR)/essentials.lua
	@echo "=== Successfully uninstalled essentials.lua ==="
>>>>>>> 364267c2b6694d376814c45706876bb18b1d18e0
