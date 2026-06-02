#!/bin/bash

set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
# Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
mkdir -p ${BUILD_PREFIX}/bin
cp ${RECIPE_DIR}/cargo-auditable-wrapper.sh ${BUILD_PREFIX}/bin/cargo-auditable-wrapper
export CARGO="cargo-auditable-wrapper"

export OPENSSL_DIR=$PREFIX

# rust-lld (LLD) cannot handle some of the relocations GCC emits for ppc64le
# (e.g. inline-PLT R_PPC64_PLTSEQ/PLTCALL), which breaks linking of C-based
# crates such as aws-lc-sys and libdbus-sys. Fall back to the GNU bfd linker on
# that platform, which handles these relocations. gcc honors the last
# -fuse-ld, so this overrides rustc's bundled rust-lld default.
if [[ "${target_platform}" == "linux-ppc64le" ]]; then
  export CARGO_BUILD_RUSTFLAGS="${CARGO_BUILD_RUSTFLAGS:-} -C link-arg=-fuse-ld=bfd"
fi

# Use native-tls on conda-forge
export MATURIN_PEP517_ARGS="--no-default-features --features=native-tls"

# Run the maturin build via pip which works for direct and
# cross-compiled builds.
$PYTHON -m pip install . -vv

pushd py-rattler
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
