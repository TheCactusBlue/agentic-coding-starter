---
name: "domain:rust"
description: "Loaded automatically when working with Rust code. Defines project conventions for idiomatic Rust, error handling, testing, and preferred dependencies."
---

# Rust Conventions

## Idioms

- Prefer iterators and combinators over explicit loops
- Use the `?` operator for error propagation — avoid manual `match` on `Result`
- Prefer `impl Trait` in return position for complex return types
- Derive `Debug`, `Clone`, `PartialEq` on most types; add `Eq`, `Hash` when useful
- Prefer owned types (`String`, `Vec<T>`) in public API signatures
- Use `From`/`Into` conversions instead of manual transformation functions
- Prefer `&str` over `&String` in function parameters
- Use `Default` trait for structs with sensible defaults

## Project Structure

- Standard Cargo layout: `src/lib.rs` or `src/main.rs` at root
- Use workspaces (`Cargo.toml` with `[workspace]`) for multi-crate projects
- Feature flags for optional functionality — keep the default feature set minimal
- `examples/` directory for runnable examples
- `benches/` directory for benchmarks using criterion

## Testing

- Use built-in `#[cfg(test)]` modules for unit tests in the same file
- Integration tests go in `tests/` directory at crate root
- Use `proptest` for property-based testing of pure logic
- Prefer `assert_eq!` and `assert!` — use `assert_matches!` for enum variants
- Test error cases explicitly — ensure `Result::Err` paths are covered
- Use `#[should_panic]` sparingly; prefer testing `Result` returns

## Error Handling

- Use `thiserror` for library error types — derive structured, typed errors
- Use `anyhow` for application-level error handling
- Never use `.unwrap()` or `.expect()` in production paths
- `.unwrap()` is acceptable in tests and examples
- Define one error enum per module or domain boundary
- Implement `Display` for all error types via `thiserror`

## Dependencies

- **Serialization:** serde + serde_json
- **Async runtime:** tokio (with only needed features enabled)
- **CLI:** clap with derive macros
- **Logging/tracing:** tracing + tracing-subscriber
- **HTTP:** reqwest (client), axum (server)
- **Testing:** proptest, assert_matches

## Anti-patterns

- Excessive `.clone()` to appease the borrow checker — restructure ownership instead
- Stringly-typed APIs — use enums and newtypes
- Ignoring clippy lints — run `cargo clippy` and address warnings
- `unsafe` without a safety comment and clear justification
- Large functions — decompose into smaller, testable units
- Using `Box<dyn Error>` when a proper error enum is feasible
