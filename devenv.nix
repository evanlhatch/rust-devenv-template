# Shell entrypoint — auto-discovers all modules under ./devenv/ (sheath
# pattern). New modules are picked up with no wiring; prefix a file/dir
# with `_` to exclude it. Each module gates itself via options.

{ pkgs, lib, inputs, ... }:
let
  # Auto-discover devenv modules.
  findModules =
    dir:
    let
      entries = builtins.readDir dir;
      processEntry =
        name: type:
        if lib.hasPrefix "_" name then
          [ ]
        else if type == "directory" then
          findModules (dir + "/${name}")
        else if lib.hasSuffix ".nix" name then
          [ (dir + "/${name}") ]
        else
          [ ];
    in
    lib.flatten (lib.mapAttrsToList processEntry entries);
in
{
  imports = findModules ./devenv;
}
