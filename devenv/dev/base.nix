# Core development module — always on.
# Shell init lives in this file (no background tasks; those are
# devenv processes).
{ pkgs, lib, config, inputs, ... }:
let
  # Binary cache routing (single source: dev/ncro.nix `upstreams` option).
  # ncro (localhost:8080) races the upstreams and goes first; if the
  # process is down, nix warns and falls through to the direct upstreams.
  ncroEnabled = config.templateConfig.ncro.enable;
  upstreams = config.templateConfig.ncro.upstreams;
  substituters =
    lib.optionals ncroEnabled [ "http://localhost:8080" ]
    ++ map (c: c.url) upstreams;
  pubkeys = map (c: c.publicKey) upstreams;
in
{
  packages = with pkgs; [
    jujutsu
    just
    ripgrep
    yek # repo → LLM context packer (respects yek.yaml + .gitignore)
    difftastic
    watchexec # file-watcher wrapper for codegen loops (just watch-gen et al)
    elan # Lean toolchain manager (lean.nix also uses it)
  ];

  difftastic.enable = true;
  dotenv.enable = false;

  # ── Binary caches: ncro proxy first, direct upstream fallback ─────
  env.NIX_CONFIG = ''
    connect-timeout = 2
    substituters = ${lib.concatStringsSep " " substituters}
    trusted-public-keys = ${lib.concatStringsSep " " pubkeys}
    experimental-features = nix-command flakes ca-derivations
  '';
  env.NIXPKGS_ALLOW_UNFREE = "1";

  enterShell = ''
    echo "🦀 devenv ready"
  '';
}
