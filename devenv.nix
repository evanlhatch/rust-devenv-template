{ pkgs, config, inputs, lib, ... }:
{
  # ── Languages — enable per project. ─────────────────────────────
  imports = [
    ./devenv/lang/rust.nix
    ./devenv/lang/lean.nix
    # ./devenv/lang/wasm.nix   # WASM component tooling
    # ./devenv/lang/js.nix     # node + bun
  ];

  # ── System packages ─────────────────────────────────────────────
  packages = with pkgs; [
    jujutsu
    just
    ripgrep
    difftastic
    yek # repo → LLM context packer (respects yek.yaml + .gitignore)
  ];

  enterShell = ''
    echo "🦀 devenv ready"
  '';
}
