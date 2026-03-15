# STRATEGY: THE HEART-FIRST HULL (v3)

**CORE PRINCIPLES:**
1.  **FULL INTENT ALIGNMENT:** A task is a failure if even one bullet point from `intent.md` is unaddressed. The Worker MUST perform a final "Audit Turn" where they check every criterion before declaring success.
2.  **DEPENDENCY FIDELITY:** Strict adherence to the `Cargo.toml` requirements in `intent.md` is non-negotiable. Use the exact features requested (e.g., `runtime-tokio-native-tls` vs `rustls`).
3.  **TDD CORE LOGIC:** The "Heart" (Domain Model/Database) precedes the "Hull" (API). Prove the data layer works before wrapping it in a server.

**IMPLEMENTATION RULES:**
1.  **DEPENDENCY LOCKDOWN:** 
    - `sqlx` MUST use the `runtime-tokio-native-tls` feature as requested in `intent.md`.
    - Do not omit `serde_json`. 
    - Only add `chrono` if `TIMESTAMPTZ` or complex date logic is required; otherwise, stick to the `intent.md` manifest.
2.  **THE HEART-FIRST PIPELINE:**
    - **Step 1:** Implement the `EventLog` model in `src/models.rs`.
    - **Step 2:** Write and PASS the TDD suite in `tests/ledger_test.rs` ensuring SQLx migrations are applied.
    - **Step 3:** Implement the Axum "Hull" (`GET /`) only after the model tests pass.
3.  **NO SELECTIVE COMPLETION:** Never skip "hard" tasks (like database integration or TDD) in favor of "easy" ones (like simple routes). Every item in the acceptance criteria is a priority.
4.  **SQLX INTEGRITY:** Ensure `DATABASE_URL` is set or use `sqlite::memory:` for tests, and ALWAYS verify that `migrations/` are executed during the test phase.

**VERIFICATION MANDATES:**
1.  **INTENT AUDIT:** The final turn MUST include a `read_file` of `intent.md` and a verbal check-off of every item.
2.  **CARGO DEPENDENCY CHECK:** Run `cargo tree` or inspect `Cargo.toml` to verify specific features (e.g., `native-tls`) are present and incorrect ones (e.g., `rustls`) are absent.
3.  **MODEL TEST EXECUTION:** `cargo test` MUST be run and its output captured to verify that the `EventLog` model actually functions.

**REFINEMENT HISTORY:**
- **v1:** Initial strategy for Kanban Hull initialization.
- **v2:** Reinforced intent coverage and standardized `sqlx`/`chrono` patterns. Mandated "Hull" handshake.
- **v3:** Shifted priority to "Heart-First" (Model before API) to prevent selective completion. Hardened dependency rules to ensure `native-tls` and `serde_json` fidelity. Mandated a final Intent Audit to catch skipped criteria. Removed misleading `chrono` requirement for SQLite-only starts.
