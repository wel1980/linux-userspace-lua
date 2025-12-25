constraint_setting(name = "libc")

constraint_value(
    name = "musl",
    constraint_setting = ":libc",
    visibility = ["//visibility:public"],
)

platform(
    name = "x86_64_linux_musl",
    constraint_values = [
        ":musl",
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
)