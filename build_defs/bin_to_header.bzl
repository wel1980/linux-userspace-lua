"""Rule to convert binary data to a C header file."""

def _bin_to_header_impl(ctx):
    output = ctx.actions.declare_file(ctx.attr.out)

    ctx.actions.run_shell(
        inputs = [ctx.file.src],
        outputs = [output],
        command = """
            set -e
            INPUT="$1"
            OUTPUT="$2"
            VAR_NAME="$3"

            {
                echo "#ifndef ${VAR_NAME}_H"
                echo "#define ${VAR_NAME}_H"
                echo ""
                echo "#include <stddef.h>"
                echo ""
                echo "static const unsigned char ${VAR_NAME}[] = {"

                # Convert binary to hex using od and format as C array
                od -An -v -tx1 "$INPUT" | \
                    sed 's/[[:space:]]*$//' | \
                    sed 's/[[:space:]][[:space:]]*/,0x/g' | \
                    sed 's/^,/    /' | \
                    sed 's/$/,/'

                echo "};"
                echo ""
                echo "static const size_t ${VAR_NAME}_len = sizeof(${VAR_NAME});"
                echo ""
                echo "#endif /* ${VAR_NAME}_H */"
            } > "$OUTPUT"
        """,
        arguments = [
            ctx.file.src.path,
            output.path,
            ctx.attr.var_name,
        ],
    )

    return [
        DefaultInfo(files = depset([output])),
        CcInfo(
            compilation_context = cc_common.create_compilation_context(
                headers = depset([output]),
                includes = depset([output.dirname]),
            ),
        ),
    ]

bin_to_header = rule(
    implementation = _bin_to_header_impl,
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The binary file to convert",
        ),
        "out": attr.string(
            mandatory = True,
            doc = "Output header file name",
        ),
        "var_name": attr.string(
            mandatory = True,
            doc = "Variable name for the byte array in C",
        ),
    },
)
