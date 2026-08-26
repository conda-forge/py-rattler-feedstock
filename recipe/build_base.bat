@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat

set "CMAKE_GENERATOR=NMake Makefiles"
if "%target_platform%"=="win-arm64" (
    @rem Keep CMake's object paths below Windows' limit.
    set "CARGO_TARGET_DIR=%TMP%\py-rattler-cargo-target"
    set "CARGO_HOME=%TMP%\py-rattler-cargo-home"

    @rem Use CMake for aws-lc-sys and clang-cl for its ARM64 assembly.
    set "AWS_LC_SYS_CMAKE_BUILDER=1"
    set "CC_aarch64_pc_windows_msvc=clang-cl.exe"
    set "CXX_aarch64_pc_windows_msvc=clang-cl.exe"
    set "ASM_aarch64_pc_windows_msvc=clang-cl.exe"
    set "CMAKE_GENERATOR=Ninja"
)

@rem Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
copy %RECIPE_DIR%\cargo-auditable-wrapper.bat %BUILD_PREFIX%\Library\bin\cargo-auditable-wrapper.bat
if %ERRORLEVEL% neq 0 exit 1
set "CARGO=cargo-auditable-wrapper.bat"

maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% --no-default-features --features=native-tls --out dist || exit 1

FOR /F "delims=" %%i IN ('dir /s /b dist\*.whl') DO set py_rattler_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps "%py_rattler_wheel%" -vv || exit 1

cd py-rattler
cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
