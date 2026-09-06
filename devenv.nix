{ pkgs, config, inputs, lib, ... }:
{
  imports = [
    ./devenv/lang/rust.nix
    # ./devenv/lang/lean.nix   # uncomment for Lean 4 authoring surface
  ];

  # ── System packages ─────────────────────────────────────────────
  packages = with pkgs; [
    jujutsu
    just
    ripgrep
    difftastic
  ];

  enterShell = ''
    echo "🦀 devenv ready"
  '';
}
