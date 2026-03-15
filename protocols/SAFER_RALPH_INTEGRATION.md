# SAFER-RALPH INTEGRATION PATCH (Draft)

**GOAL:** Make `safer-ralph` a true global CLI tool that can be called from anywhere (`beam-forge`, other projects) without relying on relative paths or `cd`ing into its directory.

## THE PROBLEM
Currently, `sandbox.sh` relies on `pwd` and relative paths for its assets:
- `Dockerfile.sandbox` (for `build`)
- `init_identity.sh` (for `create`/`up`)
- `ralph-sandbox-swarm` (mothership clone)

If you symlink `sandbox.sh` to `/usr/local/bin` and run it from `~/Projects/my-app`, it will fail to find `Dockerfile.sandbox` because it looks in `~/Projects/my-app`.

## THE SOLUTION: "Location Agnosticism"
Modify `sandbox.sh` to resolve its own installation directory at runtime.

### 1. Resolve Script Directory
Add this to the top of `sandbox.sh`:
```bash
# Resolve the directory where this script lives, resolving symlinks
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
SCRIPT_DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
```

### 2. Update Asset Paths
Change all references to local files to use `$SCRIPT_DIR`:

- **Build:** `docker build -t $IMAGE_NAME -f "$SCRIPT_DIR/Dockerfile.sandbox" "$SCRIPT_DIR"`
- **Init:** `ln -sf /root/mothership/init_identity.sh /usr/local/bin/init_identity.sh` (This is inside container, so it's fine as is, but we might want to inject `init_identity.sh` from host if we change it locally).
- **Mothership:** The `git clone` inside the container is fine.

### 3. Workspace Logic (Keep "Current Directory" Behavior)
The workspace creation logic:
```bash
WORKSPACE_DIR="$(pwd)/workspace-$NAME"
```
This is **CORRECT** for a CLI tool. If I run `ralph up` in `~/Projects/my-app`, I expect the sandbox workspace to be created in `~/Projects/my-app/workspace-shark-alpha`. This allows `beam-forge` to own the workspaces it creates.

## BEAM-FORGE IMPLICATIONS
With these changes, `beam-forge` can simply assume `sandbox.sh` is in the `PATH`.
- **Command:** `sandbox.sh create`
- **Output:** `shark-alpha`
- **Workspace:** `./workspace-shark-alpha` (relative to where `beam-forge` runs).

## ACTION PLAN
1.  Apply the "Location Agnosticism" patch to `safer-ralph/sandbox.sh`.
2.  Symlink `sandbox.sh` to a directory in `PATH` (e.g., `~/bin` or `/usr/local/bin`).
3.  Update `beam-forge.sh` to check for `sandbox.sh` in PATH.
