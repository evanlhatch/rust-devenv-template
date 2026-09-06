# WASM component toolchain, generic. Project-specific linker setup
# (wasi-sdk-derived wasm-component-ld/wasm-ld for wasip3 guests — see
# wasmtron's devenv/lang/wasm.nix for the full derivation) gets added
# here when a project needs it.
{ pkgs, ... }:
{
  packages = with pkgs; [
    lld
    lz4

    # ── WASM component tooling ──
    wasm-tools
    wit-bindgen
    wasmtime
    wac-cli # component composition
  ];
}
