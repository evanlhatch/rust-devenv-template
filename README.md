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
- **`devenv/lang/lean.nix`** — Lean 4 authoring surface (elan +
  batteries/plausible/Qq/Cli/aesop). Additional langs (`wasm.nix`,
  `js.nix`) ship disabled — uncomment imports in `devenv.nix`.
- **`justfile`** — `check` / `test` (nextest + doctests) / `clippy` /
  `fmt` / `fix` / `deny` / `mutants` / `fuzz`.
- **`Cargo.toml`** — fast-observe-first deps (no thiserror/anyhow),
  `ecow` over smallvec, insta + bolero dev-deps, and the pedantic
  `[lints]` set the projects converge on (panic/unwrap/expect out,
  `allow_attributes_without_reason`, `or_fun_call`, `cast_lossless`, …).
- **`clippy.toml` / `.cargo/config.toml` / `.config/nextest.toml`** —
  lint config, aarch64 lld linker, nextest perf-gate pattern.
- **`.github/workflows/ci.yml`** — devenv-provisioned CI (install-nix +
  devenv cachix cache + rust-cache) running `just test`/`clippy`/`fmt`.
- **`AGENTS.md` + `notes/`** — agent working agreements (jj, verification,
  error policy) and the design-decision log convention.
- **`yek.yaml`** — yek (LLM context packer) ignore rules.
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

Error handling convention: fast-observe is the error tool — no
thiserror/anyhow/eyre. Define faults, flow with `?`, never swallow silently.
