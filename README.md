# beam-forge

[BEAM_FORGE](./protocols/BEAM_FORGE.md)... but real.

An evolutionary loop for AI coding agents. A Worker executes. A Judge evaluates. An Architect mutates the strategy. Repeat until passing. Vaporise everything between generations.

**Requires:** [safer-ralph](https://github.com/ianchanning/safer-ralph) — `sandbox.sh` must be on your PATH.

---

## The Idea

safer-ralph gives you a single agent in a clean sandbox. beam-forge gives you a loop that *improves itself*.

```
intent.md (yours, immutable)
strategy_v1.md (yours, mutable)
        ↓
  Worker executes
        ↓
  Judge evaluates → [PASS] or [FAIL + CRITIQUE]
        ↓
  Architect rewrites strategy_v{N+1}.md
        ↓
  Scorched earth. Fresh container. Repeat.
        ↓
  strategy_vSUCCESS.md
```

The output isn't just a passing codebase — it's a **vetted strategy document** that you can reuse as a persona in future ralph loops.

---

## Prerequisites

1. **safer-ralph:** Install and link to your path.
   ```bash
   git clone https://github.com/ianchanning/safer-ralph
   cd safer-ralph && ./sandbox.sh build
   mkdir -p ~/.local/bin
   ln -s "$(pwd)/sandbox.sh" ~/.local/bin/sandbox.sh
   ```
2. **gemini-cli:** Required for the Architect (host-side reasoning).
   ```bash
   npm install -g @google/gemini-cli
   ```
3. **Docker:** Required for the sandboxes.

---

## Quickstart

```bash
git clone https://github.com/ianchanning/beam-forge
cd beam-forge

# You can now use the templates to start a loop:
cp templates/intent.example.md intent.md
cp templates/strategy.example.md strategy_v1.md
./beam_forge.sh run -i intent.md -s strategy_v1.md -r https://github.com/ianchanning/calculator-toy
```

---

## How it Works

1. **Worker:** Executes in a fresh sandbox. Clones the repo and attempts to fulfill the `intent.md` using the `strategy.md`. Its full trace is captured.
2. **Handoff:** The modified workspace from the Worker is copied to a *fresh* Judge sandbox. This ensures the Judge sees the actual code changes, but in a clean environment (no "poisoned well").
3. **Judge:** Adversarially evaluates the Worker's trace and the resulting codebase. It looks for "Clever Hans" shortcuts and functional flaws.
4. **Architect:** If the Judge fails the generation, the Architect (running on the host via `gemini-cli`) analyzes the critique and mutates the `strategy.md` to prevent similar failures in the next generation.
5. **Scorched Earth:** All sandboxes and temporary workspaces are purged between generations. Evolution starts from true zero every time.

---

## Structure

```
beam_forge.sh              # The loop orchestrator.
ralph.sh                   # The heartbeat loop (injected into sandboxes).
protocols/
  worker.md                # Worker system prompt.
  judge.md                 # Judge system prompt.
  architect.md             # Architect system prompt.
templates/
  intent.example.md
  strategy.example.md
runs/                      # Generated logs and traces per generation.
```

---

## Configuration

```bash
export BEAM_MAX_GENERATIONS=5      # default: 5
export BEAM_MAX_STRATEGY_TOKENS=2000  # default: 2000
export GEMINI_MODEL=gemini-2.5-flash # Used by ralph.sh and Architect
```

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | `[PASS]` — see `strategy_vSUCCESS.md` |
| `1` | Unexpected error — check `runs/` |
| `2` | `DUNKIRK` — MAX_GENERATIONS hit, human needed |

---

## Related

- [safer-ralph](https://github.com/ianchanning/safer-ralph) — the foundation
- [everything is a ralph loop](https://ghuntley.com/loop/) — the mindset
- [BEAM_FORGE.md](./protocols/BEAM_FORGE.md) — the original protocol

---

*beam-forge is clay on the pottery wheel. If it doesn't pass, throw it back.*
