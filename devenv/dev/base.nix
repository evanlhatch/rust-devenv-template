# Core development module — always on.
# Shell init lives in this file (no background tasks; those are
# devenv processes).
{ pkgs, lib, config, inputs, ... }:
{
  packages = with pkgs; [
    jujutsu
    just
    ripgrep
    yek # repo → LLM context packer (respects yek.yaml + .gitignore)
    difftastic
    elan # Lean toolchain manager (lean.nix also uses it)
  ];

  difftastic.enable = true;
  dotenv.enable = false;

  # ── Multiple binary caches (sheath base.nix pattern) ─────────────
  env.NIX_CONFIG = ''
    connect-timeout = 2
    substituters = https://nix-community.cachix.org https://cache.nixos.org
    trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
    experimental-features = nix-command flakes ca-derivations
  '';
  env.NIXPKGS_ALLOW_UNFREE = "1";

  enterShell = ''
    echo "🦀 devenv ready"
  '';
}
