#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <errno.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

/* mount(source, target, fstype) -> 0 on success, errno on failure */
static int l_mount(lua_State *L) {
    const char *source = luaL_checkstring(L, 1);
    const char *target = luaL_checkstring(L, 2);
    const char *fstype = luaL_optstring(L, 3, "ext4");

    int result = mount(source, target, fstype, 0, NULL);
    if (result == 0) {
        lua_pushinteger(L, 0);
    } else {
        lua_pushinteger(L, errno);
    }
    return 1;
}

/* umount(target) -> 0 on success, errno on failure */
static int l_umount(lua_State *L) {
    const char *target = luaL_checkstring(L, 1);

    int result = umount(target);
    if (result == 0) {
        lua_pushinteger(L, 0);
    } else {
        lua_pushinteger(L, errno);
    }
    return 1;
}

/* readdir(path) -> table of filenames, or nil + error message */
static int l_readdir(lua_State *L) {
    const char *path = luaL_optstring(L, 1, ".");

    DIR *dir = opendir(path);
    if (!dir) {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }

    lua_newtable(L);
    int i = 1;
    struct dirent *entry;
    while ((entry = readdir(dir)) != NULL) {
        lua_pushstring(L, entry->d_name);
        lua_rawseti(L, -2, i++);
    }
    closedir(dir);

    return 1;
}

/* mkdir(path, mode) -> 0 on success, errno on failure */
static int l_mkdir(lua_State *L) {
    const char *path = luaL_checkstring(L, 1);
    int mode = luaL_optinteger(L, 2, 0755);

    int result = mkdir(path, mode);
    if (result == 0) {
        lua_pushinteger(L, 0);
    } else {
        lua_pushinteger(L, errno);
    }
    return 1;
}

/* chdir(path) -> 0 on success, errno on failure */
static int l_chdir(lua_State *L) {
    const char *path = luaL_checkstring(L, 1);

    int result = chdir(path);
    if (result == 0) {
        lua_pushinteger(L, 0);
    } else {
        lua_pushinteger(L, errno);
    }
    return 1;
}

/* getcwd() -> current working directory string */
static int l_getcwd(lua_State *L) {
    char buf[PATH_MAX];
    if (getcwd(buf, sizeof(buf)) != NULL) {
        lua_pushstring(L, buf);
    } else {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }
    return 1;
}

/* stat(path) -> table with file info, or nil + error */
static int l_stat(lua_State *L) {
    const char *path = luaL_checkstring(L, 1);
    struct stat st;

    if (stat(path, &st) != 0) {
        lua_pushnil(L);
        lua_pushstring(L, strerror(errno));
        return 2;
    }

    lua_newtable(L);

    lua_pushinteger(L, st.st_size);
    lua_setfield(L, -2, "size");

    lua_pushinteger(L, st.st_mode);
    lua_setfield(L, -2, "mode");

    lua_pushboolean(L, S_ISDIR(st.st_mode));
    lua_setfield(L, -2, "isdir");

    lua_pushboolean(L, S_ISREG(st.st_mode));
    lua_setfield(L, -2, "isfile");

    return 1;
}

/* strerror(errno) -> error string */
static int l_strerror(lua_State *L) {
    int errnum = luaL_checkinteger(L, 1);
    lua_pushstring(L, strerror(errnum));
    return 1;
}

static const struct luaL_Reg sys_ops_funcs[] = {
    {"mount", l_mount},
    {"umount", l_umount},
    {"readdir", l_readdir},
    {"mkdir", l_mkdir},
    {"chdir", l_chdir},
    {"getcwd", l_getcwd},
    {"stat", l_stat},
    {"strerror", l_strerror},
    {NULL, NULL}
};

int luaopen_sys_ops(lua_State *L) {
    luaL_newlib(L, sys_ops_funcs);
    return 1;
}
