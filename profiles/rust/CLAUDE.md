# Project Instructions

## Stack
Rust, Cargo, Tokio, Serde, SQLx

## Commands
- `cargo run` — run the application
- `cargo test` — run tests
- `cargo build --release` — production build
- `cargo clippy` — lint (treat warnings as errors)
- `cargo fmt -- --check` — check formatting
- `cargo doc --open` — generate and view docs

## Architecture
- `src/main.rs` — entry point
- `src/lib.rs` — library root (re-exports)
- `src/api/` — HTTP handlers and routing
- `src/domain/` — business logic and domain types
- `src/db/` — database queries and migrations
- `src/config.rs` — configuration and environment
- `src/error.rs` — custom error types
- `tests/` — integration tests

## Critical Constraints
- No `.unwrap()` in non-test code — use `?` operator or proper error handling
- All public types must derive Debug; prefer also Clone, PartialEq
- Minimize `unsafe` blocks; every `unsafe` must have a `// SAFETY:` comment
- Use `&str` for function parameters, `String` for owned fields
- Error types must implement `std::error::Error` and `Display`
- All async functions must be cancellation-safe
