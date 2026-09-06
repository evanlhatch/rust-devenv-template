# Python — uv-managed (sheath pattern). Opt-in: no Python in this repo by
# default; uncomment the import in devenv.nix when a project needs it.
#
# uv manages the venv at .venv (UV_PROJECT_ENVIRONMENT); devenv's sync task
# runs `uv sync` with --active so it uses exactly that venv. uv never
# downloads its own Python — nix provides the interpreter (managed).
{ pkgs, lib, config, ... }:
{
  env.UV_PYTHON_DOWNLOADS = "never";
  env.UV_PYTHON_PREFERENCE = lib.mkForce "managed";
  env.UV_PROJECT_ENVIRONMENT = lib.mkForce "${config.env.DEVENV_ROOT}/.venv";

  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync = {
        enable = true;
        groups = [ "base" ];
        arguments = [
          "--active"
          "--project"
          "${config.env.DEVENV_ROOT}"
          # Handle Python version mismatches (e.g. lockfile < 3.13 but devenv has 3.13)
          "--upgrade"
        ];
      };
    };
  };

  # Language-specific tools
  packages = with pkgs; [
    ruff
    ty
  ];

  # Dependency hygiene hooks (treefmt/clippy/etc are configured in rust.nix).
  pre-commit.hooks = {
    uv-check.enable = true; # pyproject.toml is valid
    uv-lock.enable = true; # uv.lock is up to date
  };
}
