#include <stdio.h>
#include <stdlib.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

#include "program_bytecode.h"

/* Declare the sys_ops module opener */
extern int luaopen_sys_ops(lua_State *L);

/* Preload sys_ops so require("sys_ops") works */
static void preload_sys_ops(lua_State *L) {
    luaL_getsubtable(L, LUA_REGISTRYINDEX, LUA_PRELOAD_TABLE);
    lua_pushcfunction(L, luaopen_sys_ops);
    lua_setfield(L, -2, "sys_ops");
    lua_pop(L, 1);
}

int main() {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        fprintf(stderr, "Failed to create Lua state\n");
        return 1;
    }

    luaL_openlibs(L);
    preload_sys_ops(L);

    int status = luaL_loadbuffer(L, (const char *)program_bytecode,
                                  program_bytecode_len, "program");
    if (status != LUA_OK) {
        fprintf(stderr, "Failed to load bytecode: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    status = lua_pcall(L, 0, LUA_MULTRET, 0);
    if (status != LUA_OK) {
        fprintf(stderr, "Failed to execute program: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    lua_close(L);
    return 0;
}
