"""Bzlmod module extensions"""

load("//pyo3/3rdparty/crates:crates.bzl", "crate_repositories")

def _rust_ext_impl(module_ctx):
    # This should contain the subset of WORKSPACE.bazel that defines
    # repositories.
    direct_deps = []

    direct_deps.extend(crate_repositories())

    # is_dev_dep is ignored here. It's not relevant for internal_deps, as dev
    # dependencies are only relevant for module extensions that can be used
    # by other MODULES.
    return module_ctx.extension_metadata(
        root_module_direct_deps = [repo.repo for repo in direct_deps],
        root_module_direct_dev_deps = [],
    )

rust_ext = module_extension(
    doc = "Dependencies for pyo3 rules extension.",
    implementation = _rust_ext_impl,
)
