#!/usr/bin/env bash
# Oracle solution for task 2c744514 (taskgen-hybrid format) — port-corrected, self-contained
# replay of the reference walkthrough: seeds all 5 gyms on fresh dbs, executes the 80-step oracle
# plan over MCP, then scores every verifier. Exit 0 iff all pass. (45/45 verifiers.)
set -uo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$DIR/solve_replay.py"
