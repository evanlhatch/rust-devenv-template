# WASM component toolchain. OPT-IN: templateConfig.languages.wasm.enable.
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
# Project-specific linker setup (wasi-sdk-derived wasm-component-ld/wasm-ld
# for wasip3 guests — see wasmtron's devenv/lang/wasm.nix) gets added here.
{ pkgs, lib, config, ... }:
let
  cfg = config.templateConfig.languages.wasm;
in
{
  options.templateConfig.languages.wasm = {
    enable = lib.mkEnableOption "wasm component tooling" // {
      default = false;
    };

    # Middleware splicing at WIT edges (splicer). Heavy rust build; opt-in.
    enableSplicer = lib.mkEnableOption "splicer interposition tooling" // {
      default = false;
    };

    # Pre-init snapshots (weval — wizer successor; wizer path rejected for
    # components, see wasmtron notes/weval-verdict.md). Opt-in.
    enablePreinit = lib.mkEnableOption "weval pre-initializer" // {
      default = false;
    };

    # wasip3 guest linking: rustc's wasip3 target emits
    # --cooperative-threading, which needs an LLVM-23 wasm-ld. nixpkgs
    # lld (21/22) rejects the flag. Try nixpkgs wasm-component-ld first;
    # if the wasip3 link fails, port the wasi-sdk-34 linker extraction
    # from wasmtron's devenv/lang/wasm.nix (fetchurl + patchelf block).
    enableWasip3Guest = lib.mkEnableOption "wasip3 guest link support" // {
      default = false;
    };
  };

  config = lib.mkIf cfg.enable {
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
      # NOTE: nixpkgs `wasilibc` is cross-only (host platform must be a wasm
      # target) — not a usable dev-shell package. The wasi-libc sysroot for
      # linking still comes from a wasi-sdk fetch (wasmtron pattern). Removed
      # from packages for that reason.
    ]
    ++ lib.optionals cfg.enableSplicer [
      # packaged upstream in wasmtron — copy that derivation when needed
    ]
    ++ lib.optionals cfg.enablePreinit [
      # weval — copy wasmtron's pinned-rev derivation when needed
      # (release tags lag the component-model feature)
    ];

    env =
      { }
      // lib.optionalAttrs cfg.enableWasip3Guest {
        # Feature name for RUSTFLAGS_WASIP3 (guest link flags), consumed by
        # justfile wasm-guest-* recipes. Empty here — full flag set needs
        # the wasi-sdk linker; wire when enableWasip3Guest is used for real.
        WASM_WASIP3 = "1";
      };
  };
}
