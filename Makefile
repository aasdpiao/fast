.PHONY: all skynet clean proto

TOP=$(PWD)
BUILD_DIR =             $(PWD)/build
BUILD_BIN_DIR =         $(BUILD_DIR)/bin
BUILD_INCLUDE_DIR =     $(BUILD_DIR)/include
BUILD_CLIB_DIR =        $(BUILD_DIR)/clib
BUILD_STATIC_LIB_DIR =  $(BUILD_DIR)/staticlib
BUILD_LUACLIB_DIR =     $(BUILD_DIR)/luaclib
BUILD_LUALIB_DIR =      $(BUILD_DIR)/lualib
BUILD_CSERVICE_DIR =    $(BUILD_DIR)/cservice
BUILD_SERVICE_DIR =    $(BUILD_DIR)/service
BUILD_PROTO_DIR =      $(BUILD_DIR)/proto

PLAT ?= linux
SHARED := -fPIC --shared
CFLAGS = -g -O2 -Wall -I$(BUILD_INCLUDE_DIR)
LDFLAGS= -L$(BUILD_CLIB_DIR) -Wl,-rpath $(BUILD_CLIB_DIR) -lpthread -lm -ldl -lrt
DEFS = -DLUA_COMPAT_APIINTCASTS=1

all : build skynet lua5.3 proto

build:
	-mkdir $(BUILD_DIR)
	-mkdir $(BUILD_BIN_DIR)
	-mkdir $(BUILD_INCLUDE_DIR)
	-mkdir $(BUILD_CLIB_DIR)
	-mkdir $(BUILD_STATIC_LIB_DIR)
	-mkdir $(BUILD_LUACLIB_DIR)
	-mkdir $(BUILD_LUALIB_DIR)
	-mkdir $(BUILD_CSERVICE_DIR)
	-mkdir $(BUILD_SERVICE_DIR)
	-mkdir $(BUILD_PROTO_DIR)

skynet/Makefile :
	git submodule update --init

skynet : skynet/Makefile
	cd 3rd/skynet && $(MAKE) $(PLAT) && cd ../..
	cp 3rd/skynet/skynet-src/skynet_malloc.h $(BUILD_INCLUDE_DIR)
	cp 3rd/skynet/skynet-src/skynet.h $(BUILD_INCLUDE_DIR)
	cp 3rd/skynet/skynet-src/skynet_env.h $(BUILD_INCLUDE_DIR)
	cp 3rd/skynet/skynet-src/skynet_socket.h $(BUILD_INCLUDE_DIR)
	install -p -m 0755 3rd/skynet/skynet $(BUILD_BIN_DIR)/skynet
	cp -r 3rd/skynet/service/* $(BUILD_SERVICE_DIR)
	cp -r 3rd/skynet/cservice/* $(BUILD_CSERVICE_DIR)
	cp -r 3rd/skynet/lualib/* $(BUILD_LUALIB_DIR)
	cp -r 3rd/skynet/luaclib/* $(BUILD_LUACLIB_DIR)

lua5.3:
	cd 3rd/skynet/3rd/lua/ && $(MAKE) MYCFLAGS="-O2 -fPIC -g" linux
	install -p -m 0755 3rd/skynet/3rd/lua/lua $(BUILD_BIN_DIR)/lua
	install -p -m 0755 3rd/skynet/3rd/lua/luac $(BUILD_BIN_DIR)/luac
	install -p -m 0644 3rd/skynet/3rd/lua/liblua.a $(BUILD_STATIC_LIB_DIR)
	install -p -m 0644 3rd/skynet/3rd/lua/lua.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/skynet/3rd/lua/lauxlib.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/skynet/3rd/lua/lualib.h $(BUILD_INCLUDE_DIR)
	install -p -m 0644 3rd/skynet/3rd/lua/luaconf.h $(BUILD_INCLUDE_DIR)

pbc:
	cd 3rd/pbc && $(MAKE)
	cd 3rd/pbc/binding/lua53 && $(MAKE)

$(BUILD_LUACLIB_DIR)/lfs.so: 3rd/luafilesystem/src/lfs.c | $(BUILD_LUACLIB_DIR)
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@

$(BUILD_LUACLIB_DIR)/protobuf.so: 3rd/pbc/binding/lua53/pbc-lua53.c | $(BUILD_LUACLIB_DIR)
	cd 3rd/pbc && make
	$(CC) $(CFLAGS) $(SHARED) $^ -o $@ -I 3rd/pbc/ -L 3rd/pbc/build/ -lpbc
	install -p -m 0644 3rd/pbc/binding/lua53/protobuf.lua $(BUILD_LUALIB_DIR)


LUACLIB = lfs protobuf
LEVENTLIB = #levent bson mongo
CSERVICE =

all : \
	$(foreach v, $(CSERVICE), $(BUILD_CSERVICE_DIR)/$(v).so)\
	$(foreach v, $(LUACLIB), $(BUILD_LUACLIB_DIR)/$(v).so) \
	$(foreach v, $(LEVENTLIB), $(BUILD_LUACLIB_DIR)/levent/$(v).so)

clean :
	-rm -rf build
	-rm -rf log

cleanall:
	-rm -rf build
	-rm -rf log
	cd 3rd/skynet && make clean
	cd 3rd/pbc && make clean

proto:
	protoc --descriptor_set_out  ${BUILD_PROTO_DIR}/client.pb proto/client.proto
