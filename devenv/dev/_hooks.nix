# mkHook — git-hooks PATH wrapper (real plumbing; was _lib.nix mkHook).
# Import with `import ./_hooks.nix` and call with pkgs+lib in scope of
# the call site:
#
#   let mkHook = import ./_hooks.nix; in
#   mkHook pkgs lib {
#     command = "cargo-clippy";
#     bins = [ pkgs.stdenv.cc ];
#     paths = [ "${root}/.devenv/profile/bin" ];
#     args = "clippy --all-targets";
#   }
#
# Hooks run from the raw `git commit` env — nothing from the shell is on
# PATH — so every hook that dispatches by name (treefmt→rustfmt/dprint,
# clippy→cc/lld) needs this wrap.
#
# Returns an ATTRSET (a script path), never a module-function — a module
# file must eval to one lambda (args → attrset).
pkgs: lib:
{ command, bins ? [ ], paths ? [ ], args ? "" }:
pkgs.writeShellScript "hook-${builtins.baseNameOf command}" ''
  export PATH="${lib.makeBinPath bins}:${lib.concatStringsSep ":" paths}:$PATH"
  exec ${command} ${args}
''
