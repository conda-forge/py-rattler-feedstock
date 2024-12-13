@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set "CMAKE_GENERATOR=NMake Makefiles"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% --no-default-features --features=native-tls || exit 1

%PYTHON% -m pip install --no-deps --ignore-installed target\wheels\*.whl -vv || exit 1

cd py-rattler
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
