"""ATIF trajectory -> EOG model_response translator.

NOTE: intentional deviation from harness fallback semantics — see
research/enterpriseops-gym-to-harbor-mapping.md §5A.1.

The Harbor agent writes an ATIF (Agent Trajectory Interchange Format)
JSON file to /logs/agent/trajectory.json. Its shape is::

    {
      "steps": [
        {
          "agent": {"text": "...optional assistant text..."},
          "tool_call": {"name": "...", "arguments": {...}, "call_id": "..."},
          "observation": {...}
        },
        ...
      ]
    }

EOG verifiers (`response_check`, `tool_execution`) expect an EOG-shaped
model_response dict::

    {
      "content": "<concatenated final text>",
      "tool_calls": [
        {"name": ..., "arguments": ..., "call_id": ...},
        ...
      ]
    }

atif_to_eog_model_response performs the translation, preserving trajectory
order and duplicates. Missing text falls back to '' rather than raising.
"""
import json
import pathlib
from typing import Any


def atif_to_eog_model_response(atif_trajectory_path: str) -> dict[str, Any]:
    path = pathlib.Path(atif_trajectory_path)
    if not path.exists():
        return {"content": "", "tool_calls": []}

    try:
        raw = json.loads(path.read_text())
    except json.JSONDecodeError as e:
        print(f"[atif_translator] trajectory is not valid JSON ({e}); returning empty response")
        return {"content": "", "tool_calls": []}

    steps = raw.get("steps") if isinstance(raw, dict) else None
    if not isinstance(steps, list):
        return {"content": "", "tool_calls": []}

    content_chunks: list[str] = []
    tool_calls: list[dict[str, Any]] = []

    for step in steps:
        if not isinstance(step, dict):
            continue

        agent_block = step.get("agent")
        if isinstance(agent_block, dict):
            text = agent_block.get("text")
            if isinstance(text, str) and text:
                content_chunks.append(text)

        tool_call = step.get("tool_call")
        if isinstance(tool_call, dict):
            name = tool_call.get("name")
            if isinstance(name, str) and name:
                tool_calls.append({
                    "name": name,
                    "arguments": tool_call.get("arguments", {}),
                    "call_id": tool_call.get("call_id", ""),
                })

    final_content = content_chunks[-1] if content_chunks else ""

    return {
        "content": final_content,
        "tool_calls": tool_calls,
    }
