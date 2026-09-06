# rust-devenv-template

Starter repo for Rust projects using [devenv](https://devenv.sh) — the good
parts distilled from real projects.

## What's inside

- **`flake.nix` + `devenv.nix` + `devenv.yaml`** — devenv shell via
  flake-parts; `nixpkgs` rolling + `rust-overlay` + `git-hooks` inputs.
- **`devenv/lang/rust.nix`** — pinned nightly toolchain with the full
  component set, `wild` linker, dev `rustflags` (share-generics, polonius,
  ub-checks, target-cpu=native), the cargo utility suite (nextest,
  llvm-cov, expand, deny, hack, bloat, bolero, mutants, bacon, …),
  `cargo-fix` / `cargo-clippy-fix` scripts, pre-commit hooks (rustfmt,
  clippy, cargo-deny), and disk autoprune for stale incremental/build dirs.
- **`devenv/lang/lean.nix`** — opt-in Lean 4 authoring surface (elan +
  batteries/plausible/Qq/Cli/aesop). Uncomment the import in `devenv.nix`.
- **`justfile`** — `check` / `test` / `clippy` / `fmt` / `fix` /
  `deny` / `mutants`.
- **`.gitignore`** — covers target dirs, devenv/direnv state, secrets,
  editor noise.

## Usage

```sh
# new project from this template
gh repo create myproj --template <owner>/rust-devenv-template --clone

direnv allow        # or: nix develop / devenv shell
just check
```

Set `channel`/`version` in `devenv/lang/rust.nix` to pin the toolchain you
want (defaults to current nightly).
