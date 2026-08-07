"""Tool-execution verifier — port of harness/benchmark/verifier.py.

Signature: run_tool_execution(config) -> bool.

Ported from harness `_execute_tool_execution_verifier` (lines 166–193).
Reads the agent trajectory from /logs/agent/trajectory.json via
atif_translator.atif_to_eog_model_response, then checks:
  1. every name in config['selected_tools'] appears at least once, and
  2. total tool_calls length >= config['minimum_tool_calls'] (default 1).
Duplicates and order are preserved during extraction to keep the check
semantically identical to the harness.
"""
from lib.atif_translator import atif_to_eog_model_response


def run_tool_execution(config: dict) -> bool:
    selected_tools = config.get("selected_tools", [])
    minimum_tool_calls = int(config.get("minimum_tool_calls", 1))

    model_response = atif_to_eog_model_response("/logs/agent/trajectory.json")
    tool_calls = model_response.get("tool_calls") or []
    tools_called = [tc.get("name") for tc in tool_calls if isinstance(tc, dict)]

    missing_tools = [t for t in selected_tools if t not in tools_called]
    passed = len(missing_tools) == 0 and len(tools_called) >= minimum_tool_calls

    print(
        f"[tool_verifier] expected={selected_tools} called={tools_called} "
        f"missing={missing_tools} min={minimum_tool_calls} actual={len(tools_called)} "
        f"-> {'PASS' if passed else 'FAIL'}"
    )
    return passed
