# WASM component toolchain — opt-in devenv PROFILE: `devenv --profile wasm shell`.
# Self-registers as a profile (native devenv mechanism; replaced the old
# templateConfig.toggles / _lib.nix mkToggle).
#
# Curated package list (wasmtron pipeline):
#   wasm-tools        — compose, component wit, validate — core of the pipeline
#   wasmtime          — compile AOT CLI, dev/CI driver (library comes via cargo)
#   wasm-component-ld — linker for wasm32-wasip3 component output (replaces
#                       the wasi-sdk clang driver)
#   binaryen          — wasm-opt for the release pipeline
#   wabt              — wasm2wat/wasm-validate for debugging, wasm2c for native-AOT
#   wit-bindgen       — generated bindings
#   wac-cli           — component composition
#   lld/lz4           — link + compression
# Skip: wasm-language-tools/wit-ls (no LSP by design).
{
  profiles.wasm.module =
    { pkgs, lib, ... }:
    let
      # wasi-libc sysroot for wasm32-wasip3, built from source.
      #
      # Why not nixpkgs pkgsCross.wasm32-wasip1.wasilibc: the wasip3
      # target's rustc passes `--cooperative-threading` to lld, which
      # rejects wasip1 libc objects ("object file uses globals for thread
      # context"). wasi-libc must be built for TARGET wasm32-wasip3 with
      # -DENABLE_COOP_THREADS=ON, which needs clang 23 (nixpkgs
      # llvmPackages_23) — nixpkgs ships no such wasilibc cross package.
      #
      # Fixed-output derivation: wasi-libc's cmake fetches `wkg` + wasi
      # WIT deps + wasi-sdk builtins from the network at build time.
      # Hash-pinned, so drift is a hard error.
      wasiLibcP3 = pkgs.stdenv.mkDerivation {
        pname = "wasi-libc-wasip3-sysroot";
        version = "0.3.0-unstable-2026-09-07";

        src = pkgs.fetchFromGitHub {
          owner = "WebAssembly";
          repo = "wasi-libc";
          rev = "06513b9ae0c1b14ca3010924939c007ed27628a1";
          hash = "sha256-L+aRwRLZ6m0Qq0MgDN6CQDayipDBuVtmc+O8j+h++8Y=";
        };

        nativeBuildInputs = with pkgs; [
          cmake
          git
          wit-bindgen
          wasm-tools
          wasm-component-ld
          llvmPackages_23.llvm
          llvmPackages_23.clang-unwrapped
        ];

        outputHashAlgo = "sha256";
        outputHashMode = "recursive";
        outputHash =
          "sha256-cpPPCP+OkZDjJV6jusK0msbl9x3Xe5xdgON+Gmoe+AQ="; # placeholder

        dontUseCmakeConfigure = true;
        cmakeFlags = [
          "-DTARGET_TRIPLE=wasm32-wasip3"
          "-DENABLE_COOP_THREADS=ON"
          "-DBUILD_SHARED=OFF"
          "-DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY"
        ];

        preConfigure = ''
          export CMAKE_C_COMPILER="${pkgs.llvmPackages_23.clang-unwrapped}/bin/clang"
          export CMAKE_AR="${pkgs.llvmPackages_23.llvm}/bin/llvm-ar"
          export CMAKE_NM="${pkgs.llvmPackages_23.llvm}/bin/llvm-nm"
          export CMAKE_RANLIB="${pkgs.llvmPackages_23.llvm}/bin/llvm-ranlib"
        '';

        buildPhase = ''
          cmake -B build . $cmakeFlags \
            -DCMAKE_C_COMPILER="$CMAKE_C_COMPILER" \
            -DCMAKE_AR="$CMAKE_AR" -DCMAKE_NM="$CMAKE_NM" \
            -DCMAKE_RANLIB="$CMAKE_RANLIB"
          cmake --build build -j "$NIX_BUILD_CORES"
        '';

        # Rustc needs only the link dir (crt1-command.o, libc.a); headers
        # are consumed at libc build time, not at rust link time.
        installPhase = ''
          mkdir -p "$out/lib"
          cp -r build/sysroot/lib/wasm32-wasip3 "$out/lib/"
        '';
      };

      wasip3Lib = "${wasiLibcP3}/lib/wasm32-wasip3";
    in
    {
      packages = with pkgs; [
        lld
        lz4

        # ── WASM component tooling ──
        wasm-tools # compose, component wit, validate
        wasmtime # compile AOT CLI, dev/CI driver
        wasm-component-ld # wasm32-wasip3 linker
        binaryen # wasm-opt for the release pipeline
        wabt # wasm2wat/wasm-validate debugging, wasm2c native-AOT
        wit-bindgen # generated bindings
        wac-cli # component composition
      ];

      env = {
        # Link-time sysroot for wasm32-wasip3 (consumed by justfile
        # `just wasm-build` via RUSTFLAGS_WASIP3).
        WASIP3_SYSROOT = wasip3Lib;

        # WASM builds: the dev rustflags carry `-C target-cpu=native` +
        # host -Z flags that break wasm targets. Use these sets instead
        # (wasmtron pattern) via `just check-wasip3` / `just wasm-build`.
        # The wasip3 LINK needs wasm-component-ld + the wasi-libc sysroot;
        # `cargo check` doesn't link, `cargo build` proves the full chain.
        RUSTFLAGS_WASIP3 = lib.concatStringsSep " " [
          "-C lto=no"
          "-C panic=abort"
          "-C debuginfo=1"
          "-C linker=wasm-component-ld"
          "-L ${wasip3Lib}"
        ];
        RUSTFLAGS_WASM32 = "-C lto=no -C panic=abort -C debuginfo=1";
      };
    };
}
