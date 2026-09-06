//! Crate root. Feature gates for fast-observe are declared here —
//! nightly features, tracked in fast-observe's README.
#![feature(error_generic_member_access)]

pub mod errors;

pub use errors::AppError;
