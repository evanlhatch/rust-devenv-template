//! Binary entrypoint — fast-observe base wiring.
//!
//! `init()` is zero-config: stdout logs + fastrace console reporter.
//! `#[fast_observe::main]` renders a full fault report + sysexits-style
//! exit code when the future/main errors out.

#![feature(error_generic_member_access)]

use fast_observe::prelude::*;
use myproj::AppError;

fn load_config(path: &str) -> Result<String, AppError> {
    let _span = scope!("app.load_config"); // profiling span + error context
    log::info!(path = path; "loading config");

    ensure!(
        !path.is_empty(),
        AppError::ConfigUnreadable {
            path: path.to_owned()
        }
    );

    // `#[from] Io` wires io::Error → AppError; `?` lifts it into the fault.
    std::fs::read_to_string(path).map_err(AppError::from)
}

#[fast_observe::main]
fn main() {
    init();

    let path = std::env::args().nth(1).unwrap_or_default();
    let _span = scope!("app.main");

    match load_config(&path) {
        Ok(contents) => log::info!(bytes = contents.len(); "config loaded"),
        Err(fault) => {
            // Deterministic one-fact-per-line report.
            print!("{}", render_report(&fault));
        }
    }
}
