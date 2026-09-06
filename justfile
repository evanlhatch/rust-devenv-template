# Verification recipes

# Full check: tests, clippy, fmt.
check: test clippy fmt

# nextest is the default runner. nextest does not run doctests —
# they run separately (flatland pattern).
test:
	cargo nextest run && cargo test --doc

clippy:
	cargo clippy --all-targets
	cargo clippy --all-targets --all-features

fmt:
	cargo fmt --check

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

# Property/fuzz ingress boundary tests (bolero). Corpora live in
# devenv state (DEVENV_STATE/bolero-corpus).
fuzz name:
	cargo bolero run {{name}}
