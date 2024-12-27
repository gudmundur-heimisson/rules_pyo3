"""Bzlmod module extensions"""

load("//pyo3:repositories.bzl", "pyo3_toolchain_repo")
load("//pyo3/3rdparty/crates:crates.bzl", "crate_repositories")

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

    # only use the default toolchain if the root doesn't define any
    toolchains = root.tags.toolchain or rules_pyo3.tags.toolchain
    for toolchain in toolchains:
        pyo3_toolchain_repo(
            name = toolchain.name,
            pyo3 = toolchain.pyo3,
        )

pyo3 = module_extension(
    doc = "pyo3 toolchain extension.",
    tag_classes = {
        "toolchain": tag_class(
            attrs = {
                "name": attr.string(doc = "Toolchain repo name."),
                "pyo3": attr.label(doc = "The PyO3 to use."),
            },
        ),
    },
    implementation = _pyo3_impl,
)

def _pyo3_vendored_impl(module_ctx):
    # is_dev_dep is ignored here. It's not relevant for internal_deps, as dev
    # dependencies are only relevant for module extensions that can be used
    # by other MODULES.
    direct_deps = []
    direct_deps.extend(crate_repositories())
    return module_ctx.extension_metadata(
        root_module_direct_deps = [repo.repo for repo in direct_deps],
        root_module_direct_dev_deps = [],
    )

pyo3_vendored = module_extension(
    doc = "PyO3 vendored dependencies repo.",
    tag_classes = {},
    implementation = _pyo3_vendored_impl,
)
