"""Bzlmod module extensions"""

load("//pyo3:repositories.bzl", "pyo3_toolchain_repo")

def _find_module(module_ctx):
    rules_pyo3 = None
    root = None
    for mod in module_ctx.modules:
        if mod.name == "rules_pyo3":
            rules_pyo3 = mod
        if mod.is_root:
            root = mod
    if rules_pyo3 == None:
        fail("couldn't find rules_pyo3")
    return root, rules_pyo3

def _pyo3_impl(module_ctx):
    root, rules_pyo3 = _find_module(module_ctx)
    toolchains = root.tags.toolchain or rules_pyo3.tags.toolchain
    toolchain_names = []
    for toolchain in toolchains:
        toolchain_name = str(toolchain.pyo3)
        pyo3_toolchain_repo(
            name = "pyo3_toolchains",
            pyo3 = toolchain.pyo3,
        )
        toolchain_names.append(toolchain_name)

pyo3 = module_extension(
    doc = "pyo3 toolchain extension.",
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "pyo3": attr.label(doc = "The PyO3 to use."),
            },
        ),
    },
    implementation = _pyo3_impl,
)
