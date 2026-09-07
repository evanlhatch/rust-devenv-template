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
      # nixpkgs wasi-libc sysroot (cross-only package; not a usable
      # dev-shell package itself, but its lib dir is the link-time
      # sysroot — replaces the wasi-sdk tarball fetch). crt1-command.o
      # + libc.a live in the wasm32-wasip1 subdir.
      wasip1Lib = "${pkgs.pkgsCross.wasm32-wasip1.wasilibc}/lib/wasm32-wasip1";
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
        WASIP3_SYSROOT = wasip1Lib;

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
          "-L ${wasip1Lib}"
        ];
        RUSTFLAGS_WASM32 = "-C lto=no -C panic=abort -C debuginfo=1";
      };
    };
}
