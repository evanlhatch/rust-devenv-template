# JavaScript (node + bun) — opt-in devenv PROFILE: `devenv --profile js shell`.
{ ... }:
{
  profiles.js.module =
    { pkgs, ... }:
    {
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
