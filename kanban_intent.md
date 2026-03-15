# INTENT: INITIALIZE THE HULL & THE LEDGER

**GOAL:** Initialize the Rust workspace with the core stack (Axum, SQLx, SQLite) and implement the foundational `EventLog` model using TDD.

**ACCEPTANCE CRITERIA:**
1.  **Cargo.toml:** Updated with `axum`, `sqlx` (with `runtime-tokio-native-tls`, `sqlite`, `macros` features), `tokio` (full), `serde`, and `serde_json`.
2.  **Ledger Model:** An `EventLog` model implemented in `src/models.rs`.
3.  **TDD Proof:** A test suite in `tests/ledger_test.rs` (or within `models.rs`) that verifies:
    *   An event can be appended to the ledger.
    *   The ledger is append-only (no updates/deletes exposed via the model).
4.  **Handshake:** A basic Axum route (`GET /`) that returns a 200 OK with a "Hello Captain" message.
5.  **SQLx Setup:** The existing migration `migrations/20260213194758_create_event_log.sql` must be runnable and used by the tests.

**RESOURCES:**
- `Cargo.toml`
- `src/main.rs`
- `migrations/`
