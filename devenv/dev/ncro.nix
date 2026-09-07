# ncro — Nix Cache Route Optimizer (devenv process, ON by default).
#
# Races upstream caches in parallel on localhost:8080. All nix calls put
# localhost:8080 first in substituters (see dev/base.nix); when the
# process is down, nix warns and falls through to the direct upstreams
# (connect-timeout = 2 keeps that cheap).
#
# `devenv up` starts it — plain `devenv shell` does NOT run processes.
{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let
  ncro = inputs.ncro.packages.${pkgs.system}.default;
  cfg = config.templateConfig.ncro;

  upstreamSubmodule = {
    options = {
      url = lib.mkOption { type = lib.types.str; };
      publicKey = lib.mkOption { type = lib.types.str; };
      priority = lib.mkOption {
        type = lib.types.int;
        description = "ncro race priority (lower = preferred upstream).";
      };
    };
  };
in
{
  options.templateConfig.ncro = {
    enable = lib.mkEnableOption "ncro cache proxy process" // {
      default = true;
    };

    # Upstream caches to race (trim/add per project). Consumed by
    # dev/base.nix for substituters + trusted keys, and rendered into the
    # ncro config below.
    upstreams = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule upstreamSubmodule);
      default = [
        {
          url = "https://cache.nixos.org";
          publicKey = "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=";
          priority = 10;
        }
        {
          url = "https://nix-community.cachix.org";
          publicKey = "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=";
          priority = 15;
        }
        {
          url = "https://cache.numtide.com";
          publicKey = "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g=";
          priority = 18;
        }
        {
          url = "https://cache.flox.dev";
          publicKey = "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=";
          priority = 20;
        }
        {
          url = "https://nixpkgs-unfree.cachix.org";
          publicKey = "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs=";
          priority = 25;
        }
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [ ncro ];

    processes.ncro = {
      exec = ''
        mkdir -p "$DEVENV_STATE/ncro"
        cat > "$DEVENV_STATE/ncro/config.toml" <<EOF
        server.listen = ":8080"

        ${lib.concatStringsSep "\n" (map (c: ''
          [[upstreams]]
          url = "${c.url}"
          priority = ${toString c.priority}
          public_key = "${c.publicKey}"
        '') cfg.upstreams)}

        [cache]
        db_path = "$DEVENV_STATE/ncro/routes.db"
        max_entries = 100000
        ttl = "1h"
        latency_alpha = 0.3

        [logging]
        level = "info"
        format = "json"
        EOF
        exec ${ncro}/bin/ncro --config "$DEVENV_STATE/ncro/config.toml"
      '';
      restart.on = "on_failure";
    };
  };
}
