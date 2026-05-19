#!/bin/bash

set -euxo pipefail

export CARGO_PROFILE_RELEASE_STRIP=symbols
export CARGO_PROFILE_RELEASE_LTO=fat
# Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
mkdir -p ${BUILD_PREFIX}/bin
cp ${RECIPE_DIR}/cargo-auditable-wrapper.sh ${BUILD_PREFIX}/bin/cargo-auditable-wrapper
export CARGO="cargo-auditable-wrapper"

export OPENSSL_DIR=$PREFIX

# Use native-tls on conda-forge
export MATURIN_PEP517_ARGS="--no-default-features --features=native-tls"

# Run the maturin build via pip which works for direct and
# cross-compiled builds.
$PYTHON -m pip install . -vv

pushd py-rattler
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml
