---
name: rust-patterns
description: Idiomatic Rust patterns, ownership, error handling, traits, concurrency, and best practices for building safe, performant applications.
origin: ECC
---

# Rust Development Patterns

Idiomatic Rust patterns and best practices for building safe, performant, and maintainable applications.

## When to Use

- Writing new Rust code
- Reviewing Rust code
- Refactoring existing Rust code
- Designing crate structure and module layout

## Quick Reference: Rust Idioms

| Idiom | Description |
|-------|-------------|
| Borrow, don't clone | Pass `&T` instead of cloning unless ownership is needed |
| Make illegal states unrepresentable | Use enums to model valid states only |
| `?` over `unwrap()` | Propagate errors, never panic in library/production code |
| Parse, don't validate | Convert unstructured data to typed structs at the boundary |
| Newtype for type safety | Wrap primitives in newtypes to prevent argument swaps |
| Prefer iterators over loops | Declarative chains are clearer and often faster |
| `#[must_use]` on Results | Ensure callers handle return values |
| `Cow` for flexible ownership | Avoid allocations when borrowing suffices |
| Exhaustive matching | No wildcard `_` for business-critical enums |
| Minimal `pub` surface | Use `pub(crate)` for internal APIs |

## Error Handling

### Library errors with `thiserror`, application errors with `anyhow`

```rust
// Library code: structured, typed errors
use thiserror::Error;

#[derive(Debug, Error)]
pub enum StorageError {
    #[error("record not found: {id}")]
    NotFound { id: String },
    #[error("connection failed")]
    Connection(#[from] std::io::Error),
}

// Application code: flexible error handling
use anyhow::{bail, Context, Result};

fn run() -> Result<()> {
    let config = std::fs::read_to_string("app.toml")
        .with_context(|| "failed to read config")?;
    Ok(())
}
```

Never `unwrap()` in production. Never `Box<dyn Error>` in libraries.

## Ownership Patterns

```rust
// Pass references when you don't need ownership
fn process(data: &[u8]) -> usize { data.len() }

// Cow for flexible ownership — zero-cost when no mutation needed
use std::borrow::Cow;
fn normalize(input: &str) -> Cow<'_, str> {
    if input.contains(' ') { Cow::Owned(input.replace(' ', "_")) }
    else { Cow::Borrowed(input) }
}
```

## Enums and Pattern Matching

```rust
// Model states as enums — impossible states unrepresentable
enum ConnectionState {
    Disconnected,
    Connecting { attempt: u32 },
    Connected { session_id: String },
    Failed { reason: String },
}

// Exhaustive matching — no catch-all for business logic
match command {
    Command::Start => start_service(),
    Command::Stop => stop_service(),
    Command::Restart => restart_service(),
    // Adding a new variant forces handling here — no _ => {}
}
```

## Traits and Generics

```rust
// Accept generics, return concrete types
fn read_all(reader: &mut impl Read) -> std::io::Result<Vec<u8>> { ... }

// Newtype pattern for type safety
struct UserId(u64);
struct OrderId(u64);
fn get_order(user: UserId, order: OrderId) -> Result<Order> { ... }
// Can't accidentally swap user_id and order_id
```

## Concurrency

```rust
// Arc<Mutex<T>> for shared mutable state
use std::sync::{Arc, Mutex};
let counter = Arc::new(Mutex::new(0));

// Channels for message passing — prefer over shared state
use std::sync::mpsc;
let (tx, rx) = mpsc::sync_channel(16); // Bounded = backpressure

// Async: never block in async context
async fn good() { tokio::time::sleep(Duration::from_secs(1)).await; }
async fn bad()  { std::thread::sleep(Duration::from_secs(1)); } // blocks executor!
```

## Module Structure

Organize by domain, not by type:
```
my_app/src/
├── auth/       # Domain module (token.rs, middleware.rs)
├── orders/     # Domain module (model.rs, service.rs)
└── db/         # Infrastructure
```

Visibility: `pub(crate)` for internal sharing. Re-export public API from `lib.rs`.

## Anti-Patterns to Avoid

```rust
// BAD: .unwrap() in production code
// BAD: .clone() to satisfy borrow checker without understanding why
// BAD: fn greet(name: String) { } — use &str
// BAD: Box<dyn Error> in libraries — use thiserror
// BAD: let _ = validate(input); — silently discards Result
// BAD: std::thread::sleep() in async context — use tokio::time::sleep().await
// BAD: catch-all _ => {} in business logic enums
// BAD: pub fn internal_helper() — use pub(crate)
```

## Tooling

```bash
cargo check      # Fast type checking without codegen
cargo clippy     # Lints and suggestions
cargo fmt        # Format code
cargo audit      # Security audit
cargo test       # Run tests
cargo bench      # Run benchmarks
```
