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

```bash
# Install safer-ralph first
git clone https://github.com/ianchanning/safer-ralph
cd safer-ralph && ./sandbox.sh build

# Make sandbox.sh available
export PATH="$PATH:/path/to/safer-ralph"
```

---

## Quickstart

```bash
git clone https://github.com/ianchanning/beam-forge
cd beam-forge

# Write your intent (you own this file, it never changes)
cp templates/intent.example.md intent.md
vim intent.md

# Write your initial strategy (beam-forge will evolve this)
cp templates/strategy.example.md strategy_v1.md
vim strategy_v1.md

# Unleash
./beam_forge.sh run intent.md strategy_v1.md https://github.com/your/repo
```

---

## Structure

```
beam_forge.sh              # The loop. Read this first.
protocols/
  BEAM_FORGE.md            # The original concept
  BEAM_FORGE_IMPL.md       # The ratified implementation spec
  worker.md                # Worker system prompt
  judge.md                 # Judge system prompt
  architect.md             # Architect system prompt
templates/
  intent.example.md
  strategy.example.md
runs/                      # Generated. One dir per generation.
  1/
    worker_trace.txt
    verdict.txt
  2/
    ...
orchestrator/              # Stage 3: Elixir supervision (optional)
  README.md
```

---

## The Trail

This project is built in stages. If something seems complex, read the layer below it.

| Layer | What it is | Read |
|-------|-----------|------|
| Concept | The BEAM_FORGE protocol | `protocols/BEAM_FORGE.md` |
| Reference | Bash implementation | `beam_forge.sh` |
| Spec | How the bash was designed | `protocols/BEAM_FORGE_IMPL.md` |
| Optional | Elixir supervision layer | `orchestrator/README.md` |

The Elixir layer is not required. `beam_forge.sh` is the real thing. Elixir adds crash recovery and parallelism when you need them — you probably don't yet.

---

## Exit Codes

| Code | Meaning |
|------|---------|
| `0` | `[PASS]` — see `strategy_vSUCCESS.md` |
| `1` | Unexpected error — check `runs/` |
| `2` | `DUNKIRK` — MAX_GENERATIONS hit, human needed |

---

## Configuration

```bash
export BEAM_MAX_GENERATIONS=5      # default: 5
export BEAM_MAX_STRATEGY_TOKENS=2000  # default: 2000
export SANDBOX_PATH=/path/to/safer-ralph  # if not on PATH
```

---

## What this is not

- Not a safer-ralph fork. safer-ralph is untouched.
- Not a multi-agent framework. It's a bash loop and three system prompts.
- Not production infrastructure. It's a pottery wheel.

---

## Related

- [safer-ralph](https://github.com/ianchanning/safer-ralph) — the foundation
- [everything is a ralph loop](https://ghuntley.com/loop/) — the mindset
- [BEAM_FORGE.md](./protocols/BEAM_FORGE.md) — the original protocol

---

*beam-forge is clay on the pottery wheel. If it doesn't pass, throw it back.*
