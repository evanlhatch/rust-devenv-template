# JavaScript (node + bun). OPT-IN toggle: see mkToggle.
{ pkgs, lib, config, ... }:
(import ../_lib.nix { inherit pkgs lib config; }).mkToggle {
  name = "js";
  description = "javascript (node + bun)";
  mod = { ... }: {
    languages.javascript = {
      enable = true;
      package = pkgs.nodejs-slim;

      # Bun as the primary JS runtime + package manager
      bun = {
        enable = true;
        package = pkgs.bun;
        install.enable = false;
      };

      npm.enable = false;
      pnpm.enable = false;
      yarn.enable = false;
      corepack.enable = false;
    };
  };
}
