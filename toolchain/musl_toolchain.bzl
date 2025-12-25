load("@bazel_tools//tools/cpp:cc_toolchain_config_lib.bzl", "feature", "tool_path", "flag_group", "flag_set")
load("@bazel_tools//tools/build_defs/cc:action_names.bzl", "ACTION_NAMES")
load("@rules_cc//cc/common:cc_common.bzl", "cc_common")

def _impl(ctx):
    tool_paths = [
        tool_path(name = "gcc", path = "/usr/local/musl/bin/musl-gcc"),
        tool_path(name = "ld", path = "/usr/bin/ld"),
        tool_path(name = "ar", path = "/usr/bin/ar"),
        tool_path(name = "cpp", path = "/usr/bin/cpp"),
        tool_path(name = "gcov", path = "/usr/bin/gcov"),
        tool_path(name = "nm", path = "/usr/bin/nm"),
        tool_path(name = "objdump", path = "/usr/bin/objdump"),
        tool_path(name = "strip", path = "/usr/bin/strip"),
    ]

    LINK_ACTIONS = [
        ACTION_NAMES.cpp_link_executable,
    ]
    
    link_static = feature(
        name = "link_static",
        enabled = True,
        flag_sets = [
            flag_set(
                actions = LINK_ACTIONS,
                flag_groups = [
                    flag_group(
                        flags = ["-static"],
                    ),
                ],
            )
        ],
    )
    
    features = [link_static]
    
    return cc_common.create_cc_toolchain_config_info(
        ctx = ctx,
        toolchain_identifier = "local",
        host_system_name = "local",
        target_system_name = "local",
        target_cpu = "x86",
        target_libc = "musl",
        compiler = "gcc",
        abi_version = "unknown",
        abi_libc_version = "unknown",
        tool_paths = tool_paths,
        cxx_builtin_include_directories = [
            "/usr/local/musl/include/",
        ],
        features = features,
    )

musl_toolchain_config = rule(
    implementation = _impl,
    attrs = {},
    provides = [CcToolchainConfigInfo],
)