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

# --- Helper Functions ---

create_sandbox() {
    local name
    name=$(sandbox.sh create)
    echo "$name"
}

clone_repo() {
    local name=$1
    local repo_url=$2
    log "Cloning $repo_url into $name..."
    sandbox.sh clone "$name" "$repo_url" .
}

inject_files() {
    local name=$1
    shift
    local workspace_dir="./workspace-$name"
    mkdir -p "$workspace_dir"
    for file in "$@"; do
        if [[ -f "$file" ]]; then
            cp "$file" "$workspace_dir/"
        else
            log "${YELLOW}Warning: File not found for injection: $file${NC}"
        fi
    done
}

exec_ralph() {
    local name=$1
    local prompt=$2
    local output_file=$3
    local system_prompt_file=${4:-}
    
    log "Executing Ralph in $name..."
    # We use our local ralph.sh by injecting it into the workspace
    cp ./ralph.sh "./workspace-$name/ralph.sh"
    chmod +x "./workspace-$name/ralph.sh"
    
    local cmd
    if [[ -n "$system_prompt_file" ]]; then
        cmd="SYSTEM_PROMPT_FILE=/workspace/$system_prompt_file /workspace/ralph.sh 1 gemini \"$prompt\""
    else
        cmd="/workspace/ralph.sh 1 gemini \"$prompt\""
    fi
    
    docker exec "$name" bash -c "$cmd" > "$output_file" 2>&1 || true
}

handoff_state() {
    local src_name=$1
    local dest_name=$2
    log "Handing off state from $src_name to $dest_name..."
    local src_dir="./workspace-$src_name"
    local dest_dir="./workspace-$dest_name"
    mkdir -p "$dest_dir"
    # Use sudo if necessary, but sandbox.sh should handle permissions
    # We copy everything EXCEPT the injected protocols if they might conflict
    cp -rp "$src_dir/." "$dest_dir/"
}

call_architect() {
    local current_strategy=$1
    local verdict_file=$2
    local output_file=$3
    
    log "Calling Architect to mutate strategy..."
    
    # We use the gemini CLI on host
    # system prompt: protocols/architect.md
    # prompt: current strategy + verdict
    
    local system_prompt
    system_prompt=$(cat "protocols/architect.md")
    
    local prompt
    prompt="CURRENT STRATEGY:
$(cat "$current_strategy")

JUDGE VERDICT AND CRITIQUE:
$(cat "$verdict_file")

Evolve the strategy to prevent the failure described in the critique. Output ONLY the new strategy.md content."

    # Use --yolo and --model if needed, but assuming gemini is configured
    gemini --yolo -p "SYSTEM_PROMPT:
$system_prompt

$prompt" > "$output_file"
}

purge_sandbox() {
    local name=$1
    log "Purging sandbox $name..."
    sandbox.sh purge "$name"
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
        worker_id=$(create_sandbox)
        log "Worker ID: $worker_id"
        
        clone_repo "$worker_id" "$repo_url"
        
        # Prepare combined system prompt for Worker: worker.md + current strategy
        combined_worker_prompt="$gen_dir/worker_combined.md"
        cat "protocols/worker.md" > "$combined_worker_prompt"
        echo -e "\n\n# CURRENT STRATEGY\n" >> "$combined_worker_prompt"
        cat "$current_strategy" >> "$combined_worker_prompt"
        
        inject_files "$worker_id" "$intent_file" "$combined_worker_prompt"
        
        # Construct the worker directive
        worker_directive="Execute intent.md. Follow the instructions in your system prompt strictly."
        
        exec_ralph "$worker_id" "$worker_directive" "$gen_dir/worker_trace.txt" "$(basename "$combined_worker_prompt")"

        # 2. JUDGE PHASE
        log "Phase: JUDGE (Evaluation)"
        judge_id=$(create_sandbox)
        log "Judge ID: $judge_id"
        
        handoff_state "$worker_id" "$judge_id"
        
        # Prepare combined system prompt for Judge: judge.md + intent
        combined_judge_prompt="$gen_dir/judge_combined.md"
        cat "protocols/judge.md" > "$combined_judge_prompt"
        echo -e "\n\n# INTENT TO EVALUATE\n" >> "$combined_judge_prompt"
        cat "$intent_file" >> "$combined_judge_prompt"
        
        inject_files "$judge_id" "$combined_judge_prompt"
        
        # Construct the judge directive
        # We pass the trace as part of the directive, but it might be too large.
        # Ideally the Judge reads it from the workspace.
        inject_files "$judge_id" "$gen_dir/worker_trace.txt"
        
        judge_directive="Evaluate the Worker's execution. Read worker_trace.txt to understand what they did. Output [PASS] or [FAIL] followed by your critique."
        
        exec_ralph "$judge_id" "$judge_directive" "$gen_dir/verdict.txt" "$(basename "$combined_judge_prompt")"

        # 3. VERDICT ANALYSIS
        # The verdict.txt contains the full ralph output. We need to find [PASS] or [FAIL]
        if grep -q "\[PASS\]" "$gen_dir/verdict.txt"; then
            success "Intent satisfied in Generation $gen!"
            cp "$current_strategy" "strategy_vSUCCESS.md"
            log "Frozen successful strategy to: strategy_vSUCCESS.md"
            purge_sandbox "$worker_id"
            purge_sandbox "$judge_id"
            exit 0
        fi

        if [[ $gen -eq $MAX_GENERATIONS ]]; then
            error "DUNKIRK: Max generations reached. Evolution failed."
        fi

        # 4. ARCHITECT PHASE
        log "Phase: ARCHITECT (Mutation)"
        next_strategy_file="strategy_v$((gen + 1)).md"
        
        call_architect "$current_strategy" "$gen_dir/verdict.txt" "$next_strategy_file"
        
        current_strategy="$next_strategy_file"

        # 5. SCORCHED EARTH
        log "Phase: SCORCHED EARTH (Purge)"
        purge_sandbox "$worker_id"
        purge_sandbox "$judge_id"
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
