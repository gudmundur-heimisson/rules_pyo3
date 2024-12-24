"""pyo3 dependencies"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# buildifier: disable=unnamed-macro
def rules_pyo3_dependencies():
    """Defines pyo3 dependencies"""
    maybe(
        http_archive,
        name = "rules_rust",
        integrity = "sha256-8TBqrAsli3kN8BrZq8arsN8LZUFsdLTvJ/Sqsph4CmQ=",
        urls = ["https://github.com/bazelbuild/rules_rust/releases/download/0.56.0/rules_rust-0.56.0.tar.gz"],
    )

    maybe(
        http_archive,
        name = "rules_python",
        sha256 = "4f7e2aa1eb9aa722d96498f5ef514f426c1f55161c3c9ae628c857a7128ceb07",
        strip_prefix = "rules_python-1.0.0",
        url = "https://github.com/bazelbuild/rules_python/releases/download/1.0.0/rules_python-1.0.0.tar.gz",
    )

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "bc283cdfcd526a52c3201279cda4bc298652efa898b10b4db0837dc51652756f",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.7.1/bazel-skylib-1.7.1.tar.gz",
        ],
    )

# buildifier: disable=unnamed-macro
def register_pyo3_toolchains(register_toolchains = True):
    """Defines pytest dependencies"""
    if register_toolchains:
        native.register_toolchains(
            str(Label("//pyo3/toolchains:toolchain")),
            str(Label("//pyo3/toolchains:rust_toolchain")),
        )

_TOOLCHAIN_BUILD_TEMPLATE = """
load("@rules_rust//rust:defs.bzl", "rust_library_group")
load("@rules_pyo3//pyo3:defs.bzl", "pyo3_toolchain", "rust_pyo3_toolchain")

rust_library_group(
    name = "pyo3",
    deps = [
        "{PYO3}",
    ],
)

rust_pyo3_toolchain(
    name = "rust_pyo3_toolchain",
    pyo3 = ":pyo3",
)

toolchain(
    name = "rust_toolchain",
    toolchain = ":rust_pyo3_toolchain",
    toolchain_type = "@rules_pyo3//pyo3:rust_toolchain_type",
)

pyo3_toolchain(
    name = "pyo3_toolchain",
)

toolchain(
    name = "toolchain",
    toolchain = ":pyo3_toolchain",
    toolchain_type = "@rules_pyo3//pyo3:toolchain_type",
)
"""

def _pyo3_toolchain_repo_impl(repository_ctx):
    repository_ctx.file("WORKSPACE.bazel", """workspace(name = "{}")""".format(repository_ctx.name))
    repository_ctx.file(
        "BUILD.bazel",
        _TOOLCHAIN_BUILD_TEMPLATE.format(PYO3 = repository_ctx.attr.pyo3),
    )

pyo3_toolchain_repo = repository_rule(
    implementation = _pyo3_toolchain_repo_impl,
    attrs = {
        "pyo3": attr.label(doc = "The PyO3 to use."),
    },
)
