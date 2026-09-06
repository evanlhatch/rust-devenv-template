//! Application error types — fast-observe is the error tool.
//!
//! Define faults with `error!`: one variant per failure mode, each with
//! a stable `#[code]`, a `#[category]` (retry/abort policy), and where
//! useful an `#[advice]`. Flow with `?`. No thiserror/anyhow/eyre.

use fast_observe::error;

error! {
    /// Errors the application can fail with.
    pub enum AppError {
        /// check the path exists and is readable
        #[error("config unreadable: {path}")]
        #[code = "E100", category = Content]
        ConfigUnreadable {
            /// The path we tried to read.
            path: String,
        },
        /// The underlying I/O failure.
        #[error("io: {0}")]
        #[code = "E101", category = Transient, advice = "retry; if persistent, check the disk"]
        #[from]
        Io(std::io::Error),
    }
}
