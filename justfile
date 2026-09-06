# Verification recipes

# Full check: tests, clippy, fmt.
check: test clippy fmt

test:
	cargo nextest run

clippy:
	cargo clippy --all-targets
	cargo clippy --all-targets --all-features

fmt:
	cargo fmt --check

# Auto-fix lint/format findings (separate target dir, no -Zthreads).
fix:
	cargo-fix
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
