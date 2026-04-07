#!/usr/bin/env bash
# Blocks Claude from reading files/folders listed in .blocked-paths.
# Each line is a path (relative to project root, absolute, or ~-prefixed).
# Lines starting with # are comments. Empty lines are ignored.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BLOCKED_PATHS_FILE="$PROJECT_ROOT/.blocked-paths"

[[ ! -f "$BLOCKED_PATHS_FILE" ]] && exit 0

INPUT=$(cat)

# Extract fields from JSON using python3
read_json() {
  python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d$2 if $3 else '')" "$INPUT" 2>/dev/null || true
}

TOOL_NAME=$(python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d.get('tool_name',''))" "$INPUT" 2>/dev/null)

case "$TOOL_NAME" in
  Read)  CHECK_PATH=$(python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d.get('tool_input',{}).get('file_path',''))" "$INPUT" 2>/dev/null) ;;
  Glob)  CHECK_PATH=$(python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d.get('tool_input',{}).get('path',''))" "$INPUT" 2>/dev/null) ;;
  Grep)  CHECK_PATH=$(python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d.get('tool_input',{}).get('path',''))" "$INPUT" 2>/dev/null) ;;
  Bash)  CHECK_PATH=$(python3 -c "import sys,json; d=json.loads(sys.argv[1]); print(d.get('tool_input',{}).get('command',''))" "$INPUT" 2>/dev/null) ;;
  *)     exit 0 ;;
esac

[[ -z "$CHECK_PATH" ]] && exit 0

# Resolve to absolute path for file tools (Bash uses substring match on the command string)
if [[ "$TOOL_NAME" != "Bash" && "$CHECK_PATH" != /* ]]; then
  CHECK_PATH="$PROJECT_ROOT/$CHECK_PATH"
fi

while IFS= read -r blocked || [[ -n "$blocked" ]]; do
  [[ -z "$blocked" || "$blocked" == \#* ]] && continue

  # Expand ~ and make absolute
  blocked="${blocked/#\~/$HOME}"
  if [[ "$blocked" != /* ]]; then
    blocked="$PROJECT_ROOT/$blocked"
  fi

  if [[ "$CHECK_PATH" == "$blocked"* || "$CHECK_PATH" == *"$blocked"* ]]; then
    python3 -c "import sys,json; print(json.dumps({'hookSpecificOutput':{'hookEventName':'PreToolUse','permissionDecision':'deny','permissionDecisionReason':'Blocked by .blocked-paths: '+sys.argv[1]}}))" "$blocked"
    exit 0
  fi
done < "$BLOCKED_PATHS_FILE"

exit 0
