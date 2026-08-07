#!/usr/bin/env bash
set -euo pipefail

mkdir -p /logs/verifier

_write_failure_reward() {
  local reason="${1:-verifier bootstrap error}"
  python -c '
import json, pathlib, sys
pathlib.Path("/logs/verifier/reward.json").write_text(json.dumps({
  "reward": 0.0, "verifier_bootstrap_error": 1.0, "reason": sys.argv[1],
}))' "$reason"
}
trap '_write_failure_reward "test.sh non-zero at line ${BASH_LINENO[0]}"' ERR

if [ ! -d /shared ]; then
  trap - ERR
  _write_failure_reward "/shared directory missing"
  exit 1
fi

export PYTHONPATH=/tests

python - <<'PY'
import json, sys, pathlib
from lib.db_verifier       import run_database_state
from lib.response_verifier import run_response_check
from lib.tool_verifier     import run_tool_execution

SHARED = pathlib.Path("/shared")
db_ids = {}
for f in SHARED.glob("database_id_*"):
    gym = f.name.replace("database_id_", "")
    db_ids[gym] = f.read_text().strip()

VERIFIERS = [json.loads(l) for l in
             pathlib.Path("/tests/verifiers.jsonl").read_text().splitlines() if l.strip()]

rewards = {}
passed_all = True
for v in VERIFIERS:
    key = v["reward_key"]
    gym = v["gym"]
    db_id = db_ids.get(gym)
    try:
        if v["type"] == "database_state":
            ok = run_database_state(gym, v["config"], db_id=db_id)
        elif v["type"] == "response_check":
            ok = run_response_check(gym, v["config"], db_id=db_id)
        elif v["type"] == "tool_execution":
            ok = run_tool_execution(v["config"])
        else:
            ok = False
    except Exception as e:
        print(f"[{key}] verifier crashed: {type(e).__name__}: {e}", file=sys.stderr)
        ok = False
    rewards[key] = 1.0 if ok else 0.0
    passed_all = passed_all and ok
    print(f"[{key}] {'PASS' if ok else 'FAIL'}")

rewards["reward"] = 1.0 if passed_all else 0.0
pathlib.Path("/logs/verifier/reward.json").write_text(json.dumps(rewards, indent=2))
PY
