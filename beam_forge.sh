#!/usr/bin/env bash

# BEAM_FORGE (v1.0-bash) - The Evolutionary Loop
# "If it doesn't pass, throw it back into the fire."

set -euo pipefail

# --- Defaults ---
MAX_GENERATIONS=${BEAM_MAX_GENERATIONS:-5}
MAX_STRATEGY_TOKENS=${BEAM_MAX_STRATEGY_TOKENS:-2000}
RUNS_DIR="runs"

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[BEAM_FORGE]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

usage() {
    cat <<EOF
Usage: $0 run -i <intent.md> -s <strategy.md> -r <repo_url>

Options:
  -i    Path to the immutable intent file
  -s    Path to the initial (mutable) strategy file
  -r    URL of the repository to work on
EOF
    exit 1
}

run_loop() {
    local intent_file=$1
    local strategy_file=$2
    local repo_url=$3

    log "Starting evolutionary loop for: $repo_url"
    log "Max Generations: $MAX_GENERATIONS"

    # Ensure files exist
    [[ -f "$intent_file" ]] || error "Intent file not found: $intent_file"
    [[ -f "$strategy_file" ]] || error "Strategy file not found: $strategy_file"

    mkdir -p "$RUNS_DIR"

    current_strategy="$strategy_file"

    for gen in $(seq 1 "$MAX_GENERATIONS"); do
        log "${YELLOW}--- Generation $gen ---${NC}"
        gen_dir="$RUNS_DIR/$gen"
        mkdir -p "$gen_dir"

        # 1. WORKER PHASE
        log "Phase: WORKER (Execution)"
        # TODO: sandbox.sh go $repo_url
        # TODO: Inject protocols/worker.md + intent_file + current_strategy
        # TODO: Capture trace to $gen_dir/worker_trace.txt
        echo "Worker trace placeholder" > "$gen_dir/worker_trace.txt"

        # 2. JUDGE PHASE
        log "Phase: JUDGE (Evaluation)"
        # TODO: sandbox.sh go $repo_url (fresh)
        # TODO: Inject protocols/judge.md + $gen_dir/worker_trace.txt + intent_file
        # TODO: Capture verdict to $gen_dir/verdict.txt
        # For now, let's simulate a failure until we have real execution
        echo "[FAIL]" > "$gen_dir/verdict.txt"
        echo "---" >> "$gen_dir/verdict.txt"
        echo "Critique placeholder: Strategy needs more grit." >> "$gen_dir/verdict.txt"

        # 3. VERDICT ANALYSIS
        verdict=$(head -n 1 "$gen_dir/verdict.txt")
        if [[ "$verdict" == "[PASS]" ]]; then
            success "Intent satisfied in Generation $gen!"
            cp "$current_strategy" "strategy_vSUCCESS.md"
            log "Frozen successful strategy to: strategy_vSUCCESS.md"
            exit 0
        fi

        if [[ $gen -eq $MAX_GENERATIONS ]]; then
            error "DUNKIRK: Max generations reached. Evolution failed."
        fi

        # 4. ARCHITECT PHASE
        log "Phase: ARCHITECT (Mutation)"
        next_strategy="strategy_v$((gen + 1)).md"
        # TODO: Call Architect with current_strategy + $gen_dir/verdict.txt
        # TODO: Enforce token limits
        echo "Strategy v$((gen + 1)) placeholder" > "$next_strategy"
        current_strategy="$next_strategy"

        # 5. SCORCHED EARTH
        log "Phase: SCORCHED EARTH (Purge)"
        # TODO: sandbox.sh purge
    done
}

# --- Main Entry Point ---

if [[ $# -lt 1 ]]; then usage; fi

subcommand=$1
shift

case "$subcommand" in
    run)
        intent=""
        strategy=""
        repo=""
        while getopts "i:s:r:" opt; do
            case $opt in
                i) intent=$OPTARG ;;
                s) strategy=$OPTARG ;;
                r) repo=$OPTARG ;;
                *) usage ;;
            esac
        done
        [[ -z "$intent" || -z "$strategy" || -z "$repo" ]] && usage
        run_loop "$intent" "$strategy" "$repo"
        ;;
    *)
        usage
        ;;
esac
