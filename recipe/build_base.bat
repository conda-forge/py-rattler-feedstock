@echo on
set "PYO3_PYTHON=%PYTHON%"

set CARGO_PROFILE_RELEASE_STRIP=symbols
set CARGO_PROFILE_RELEASE_LTO=fat
@rem Remove this wrapper once https://github.com/conda-forge/rust-activation-feedstock/pull/79 is merged
copy %RECIPE_DIR%\cargo-auditable-wrapper.bat %BUILD_PREFIX%\Library\bin\cargo-auditable-wrapper.bat
if %ERRORLEVEL% neq 0 exit 1
set "CARGO=cargo-auditable-wrapper.bat"

set "CMAKE_GENERATOR=NMake Makefiles"
maturin build -v --jobs 1 --release --strip --manylinux off --interpreter=%PYTHON% --no-default-features --features=native-tls || exit 1

cd py-rattler

FOR /F "delims=" %%i IN ('dir /s /b target\wheels\*.whl') DO set py_rattler_wheel=%%i
%PYTHON% -m pip install --ignore-installed --no-deps %py_rattler_wheel% -vv || exit 1

cargo-bundle-licenses --format yaml --output THIRDPARTY.yml || exit 1
