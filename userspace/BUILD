load("@rules_cc//cc:defs.bzl", "cc_binary")
load("@glua_kit//build_defs/lua:compile.bzl", "lua_compile")
load("//build_defs:bin_to_header.bzl", "bin_to_header")

lua_compile(
    name = "program",
    out = "program.bin",
    lua = ":program.lua",
)

bin_to_header(
    name = "program_bytecode_header",
    src = ":program",
    out = "program_bytecode.h",
    var_name = "program_bytecode",
)

cc_binary(
    name = "init",
    srcs = [
        "init.c",
        "sys_ops.c",
    ],
    deps = [
        ":program_bytecode_header",
        "@lua_mainline//src:includes",
        "@lua_mainline//src:core",
        "@lua_mainline//src:libraries",
    ],
)

genrule(
    name = "initramfs",
    srcs = [
        ":init",
    ],
    outs = ["initramfs.cpio"],
    cmd = "echo init > file_list.txt && cp $(location :init) . && cpio -o -H newc < file_list.txt > $@",
)