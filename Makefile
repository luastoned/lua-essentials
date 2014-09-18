#
# essentials.lua Makefile for installation.
# Copyright (c) 2014 @LuaStoned
# See LICENSE file for license information.
#

CP = cp -r
RM = rm -f

PREFIX ?= /usr/local

MAJVER = 1
MINVER = 0
MICVER = 0
ESNVER = $(MAJVER).$(MINVER).$(MICVER)

LUA_MODULEDIR = $(PREFIX)/share/lua/5.1

LUAJIT_VERSION ?= 2.0.3
LUAJIT_MODULEDIR = $(PREFIX)/share/luajit-$(LUAJIT_VERSION)

default: install
clean: uninstall

install:
	@echo "=== Installing essentials.lua v$(ESNVER) to: $(LUAJIT_MODULEDIR) ==="
	$(CP) essentials.lua $(LUA_MODULEDIR)
	$(CP) essentials.lua $(LUAJIT_MODULEDIR)
	@echo "=== Successfully installed essentials.lua ==="

uninstall:
	@echo "=== Uninstalling essentials.lua from: $(LUAJIT_MODULEDIR) ==="
	$(RM) $(LUA_MODULEDIR)/essentials.lua
	$(RM) $(LUAJIT_MODULEDIR)/essentials.lua
	@echo "=== Successfully uninstalled essentials.lua ==="