# BEAM_FORGE: THE CAPTAIN'S LOG (NOTES.md)

## Current Status: THE FORGE IS COLD
We have the blueprints (`BEAM_FORGE.md`, `BEAM_FORGE_IMPL.rfc.md`), but the iron hasn't been struck. 

## The Mission
Build an evolutionary loop for AI agents. 
- Worker executes.
- Judge critiques.
- Architect evolves.
- Scorched Earth between generations.

## Strategic Decisions
- [2026-03-14] **Multi-File Prompting:** `GEMINI.md`, `AGENTS.md`, and `CONVENTIONS.md` are clones to ensure compatibility with different tool-chains (Aider, Gemini CLI, etc.). 
- [2026-03-14] **The Bash First Mandate:** Stage 1 is the ground truth. We don't touch Elixir until the bash loop has survived three real-world trials.
- [2026-03-14] **Quantum Judge:** The Judge needs a fresh container. No cross-contamination from the Worker's potential "Clever Hans" shortcuts.
- [2026-03-14] **The Pirate Flow:** Branching strategy (master, feat/stage-X, research/*) to maintain a stable ground truth.
- [2026-03-14] **Atomic Precision:** Commit frequently. Commit atomically. Use Conventional Commits. No sloppy "stuff changed" messages.

## The Rabbit Hole Tracker
- [/] Forge `beam_forge.sh` (Structure only).
- [x] Scribe `protocols/worker.md`.
- [x] Scribe `protocols/judge.md`.
- [x] Scribe `protocols/architect.md`.
- [ ] First run: Evolution of a simple script.

## The Meta-Conflict Check
- `NOTES.md` lives on the **HOST**. It is our persistent memory.
- The **WORKER** lives in the **SANDBOX**. Its memory is vaporized.
- **Verdict:** No conflict. The Host remembers so the Worker can forget and start fresh.
