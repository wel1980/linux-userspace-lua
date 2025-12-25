load(":musl_toolchain.bzl", "musl_toolchain_config")

filegroup(name = "empty")

musl_toolchain_config(
    name = "musl_config"
);

cc_toolchain(
    name = "musl_toolchain",
    toolchain_identifier = "local",
    toolchain_config = ":musl_config",
    all_files = ":empty",
    compiler_files = ":empty",
    dwp_files = ":empty",
    linker_files = ":empty",
    objcopy_files = ":empty",
    strip_files = ":empty",
    supports_param_files = False,
)

toolchain(
    name = "musl_linux_x86_64",
    exec_compatible_with = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    target_compatible_with = [
        "//platforms:musl",
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    toolchain = ":musl_toolchain",
    toolchain_type = "@bazel_tools//tools/cpp:toolchain_type",
)