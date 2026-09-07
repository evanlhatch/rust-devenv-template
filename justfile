# Verification recipes

# Full check: tests, clippy, fmt, typos, secrets.
check: test clippy fmt typos secrets

# nextest is the default runner. nextest does not run doctests —
# they run separately (flatland pattern).
test:
	cargo nextest run && cargo test --doc

clippy:
	cargo clippy --all-targets
	cargo clippy --all-targets --all-features

fmt:
	cargo fmt --check

# Everything formatter: rustfmt + dprint (treefmt.toml + .dprint.json).
format:
	treefmt

# Spell-check (typos.toml).
typos:
	typos

# Secret scanner (ripsecrets).
secrets:
	ripsecrets

# Auto-fix lint/format findings (separate target dir, no -Zthreads).
fix:
	cargo-clippy-fix
	cargo fmt

clippy-fix:
	cargo-clippy-fix

# Dependency hygiene
deny:
	cargo deny check

outdated:
	cargo outdated

machete:
	cargo machete

# Mutation testing (pass a module name: just mutants foo)
mutants name:
	cargo mutants -f {{name}}

# ── Codegen loop (buf-style: watched = same command, wrapped) ────────
# `gen`/`check`/`breaking` run identically in CI and in watchers. The
# watcher never changes what runs, only when.

# Emit wit/ + src/generated/ + wasm from the type-definition layer.
# Placeholder impl — swap for steelc/lake when wired.
gen:
	@echo "TODO: steelc emit"

# Fast type-check only, no emission (buf lint analog).
check-schema:
	@echo "TODO: steelc check"

# Schema-compat diff vs last released schema (buf breaking analog).
breaking:
	@echo "TODO: schema diff"

# Watchers — watchexec wraps the SAME commands, no redefinition.
# --restart: kill in-flight gen on new save (codegen is idempotent).
watch-gen:
	watchexec -r -w lean -e lean -- just gen

# Host restart on generated OUTPUTS + host code (not lean/ — the gen
# write into src/generated is what triggers this, one write per change).
watch-host:
	watchexec -r -w src -w wit -- cargo run

# Fast schema check without emission.
watch-check:
	watchexec -w lean -e lean -- just check-schema

# Property/fuzz ingress boundary tests (bolero). Corpora live in
# devenv state (DEVENV_STATE/bolero-corpus).
fuzz name:
	cargo bolero run {{name}}

# ── WASM compile checks (nightly + rust-src required) ────────────────
# RUSTFLAGS_WASIP3/RUSTFLAGS_WASM32 (devenv/lang/wasm.nix) strip host-only
# flags (target-cpu=native, -Z*) and add the wasip3 linker + sysroot.
check-wasip3:
	RUSTFLAGS="$RUSTFLAGS_WASIP3" cargo check --target wasm32-wasip3 -Z build-std=std,panic_abort

# Full wasip3 link — the real gate (wasm-component-ld + wasi-libc sysroot,
# both from nixpkgs; no wasi-sdk tarball).
wasm-build:
	RUSTFLAGS="$RUSTFLAGS_WASIP3" cargo build --target wasm32-wasip3 -Z build-std=std,panic_abort

check-wasm:
	RUSTFLAGS="$RUSTFLAGS_WASM32" cargo check --target wasm32-unknown-unknown
