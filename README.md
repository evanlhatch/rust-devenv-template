# rust-devenv-template

Devenv-based Rust project starter. The repo itself is the documentation —
read `devenv/` for how things are wired.

## New project

```sh
gh repo create myproj --template evanlhatch/rust-devenv-template --clone
direnv allow        # or: devenv shell; or no-direnv cd activation
just check
```

No direnv? devenv 2.1+ does cd-activation itself — add to your shell
config: `eval "$(devenv hook bash)"` (zsh/fish/nushell variants exist),
then `devenv allow` in the project.

## Conventions (short version)

- **Errors**: fast-observe only — no thiserror/anyhow/eyre.
- **Lang profiles**: opt-in languages live in `devenv/lang/` as devenv
  profiles — activate with `devenv --profile wasm shell` (compose flags;
  no config needed).
- **Per-machine overrides**: `devenv.local.nix` (gitignored).
- **Binary caches**: ncro proxy (localhost:8080) is on by default and
  races the upstream caches — start it with `devenv up` (plain
  `devenv shell` does not run processes; nix falls back to the direct
  upstreams when ncro is down).
- **wasm**: `just check-wasip3` (check) / `just wasm-build` (full
  component link, proven via the nix-built wasi-libc wasip3 sysroot —
  see `devenv/lang/wasm.nix`); needs the vendored getrandom patch (see
  Cargo.toml `[patch.crates-io]`).
