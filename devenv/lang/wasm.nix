# WASM component toolchain. OPT-IN toggle: see mkToggle.
#
# Curated package list (wasmtron pipeline):
#   wasm-tools  — compose, component wit, validate — core of the pipeline
#   wasmtime    — compile AOT CLI, dev/CI driver (library comes via cargo)
#   binaryen    — wasm-opt for the release pipeline
#   wabt        — wasm2wat/wasm-validate for debugging, wasm2c for native-AOT
#   wit-bindgen — generated bindings
#   wac-cli     — component composition
#   lld/lz4     — link + compression
# Skip: wasm-language-tools/wit-ls (no LSP by design).
#
# NOTE: nixpkgs `wasilibc` is cross-only (host platform must be a wasm
# target) — not a usable dev-shell package. The wasi-libc sysroot for
# linking still comes from a wasi-sdk fetch (wasmtron pattern). Removed
# from packages for that reason.
{ pkgs, lib, config, ... }:
(import ../_lib.nix { inherit pkgs lib config; }).mkToggle {
  name = "wasm";
  description = "wasm component tooling";
  mod = { ... }: {
    packages = with pkgs; [
      lld
      lz4

      # ── WASM component tooling ──
      wasm-tools # compose, component wit, validate
      wasmtime # compile AOT CLI, dev/CI driver
      binaryen # wasm-opt for the release pipeline
      wabt # wasm2wat/wasm-validate debugging, wasm2c native-AOT
      wit-bindgen # generated bindings
      wac-cli # component composition
    ];
  };
}
