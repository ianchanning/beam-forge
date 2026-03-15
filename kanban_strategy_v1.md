# STRATEGY: RUST TDD EVOLUTION (v1)

**CORE PRINCIPLE:** Reliability through TDD and strict type safety.

**IMPLEMENTATION RULES:**
1.  **TDD FIRST:** Write a failing test for the `EventLog` model before implementing the logic.
2.  **MINIMAL MONOLITH:** Start with a clean structure in `src/main.rs` and `src/models.rs`.
3.  **DEFENSIVE SQL:** Use SQLx macros for compile-time query verification.
4.  **AXUM HANDSHAKE:** Ensure the server binds to `0.0.0.0:3000` for container access.

**VERIFICATION MANDATES:**
- Run `cargo test` after every significant change.
- Run `cargo check` to ensure SQLx macros pass.

**REFINEMENT HISTORY:**
- v1: Initial strategy for Kanban Hull initialization.
