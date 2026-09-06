# JavaScript (node + bun). OPT-IN: templateConfig.languages.js.enable.
{ pkgs, lib, config, ... }:
let
  cfg = config.templateConfig.languages.js;
in
{
  options.templateConfig.languages.js.enable = lib.mkEnableOption "javascript (node + bun)" // {
    default = false;
  };

  config = lib.mkIf cfg.enable {
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
