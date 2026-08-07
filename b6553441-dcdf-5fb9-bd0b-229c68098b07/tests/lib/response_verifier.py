"""Response-check verifier — port of harness/benchmark/verifier.py.

Signature: run_response_check(gym, config, db_id) -> bool.

Ported from harness `_execute_response_check_verifier` (lines 129–164) and
`_compare_with_llm` (lines 412–482). The judge system-prompt and user-prompt
templates are copied BYTE-FOR-BYTE from harness lines 421–446. Any deviation
destroys the response-check parity guarantee (mapping doc §5A.2).
"""
import json
import os
from typing import Any, Optional

from lib.atif_translator import atif_to_eog_model_response
from lib.db_verifier import _execute_sql_query


_JUDGE_SYSTEM_PROMPT = """You are an AI judge evaluating the quality and accuracy of an AI assistant's response.
Compare the database query result with the AI's response and rate how well they match.
Provide a score from 1-10 where:
- 1-3: Poor match, incorrect or missing information
- 4-6: Partial match, some correct information
- 7-8: Good match, mostly correct
- 9-10: Excellent match, fully accurate

Respond with ONLY a JSON object in this format:
{
  "score": <number 1-10>,
  "reasoning": "<brief explanation>"
}"""


def _build_judge_user_prompt(sql_result: dict, llm_response: str, comparison_prompt: str) -> str:
    sql_result_str = json.dumps(sql_result.get("result", {}), indent=2)
    return (
        "Database Query Result:\n"
        f"{sql_result_str}\n"
        "\n"
        "AI Assistant Response:\n"
        f"{llm_response}\n"
        "\n"
        "Comparison Task:\n"
        f"{comparison_prompt}\n"
        "\n"
        "Please provide your judgment as JSON."
    )


def _extract_llm_content(model_response: dict) -> str:
    if "content" in model_response:
        return str(model_response["content"])
    if "text" in model_response:
        return str(model_response["text"])
    if "response" in model_response:
        return str(model_response["response"])
    return str(model_response)


def _call_judge(system_prompt: str, user_prompt: str, model: str) -> str:
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("ANTHROPIC_API_KEY not set — cannot run response_check verifier")

    try:
        import anthropic
    except ImportError as e:
        raise RuntimeError(
            "anthropic package required for response_check verifier: pip install anthropic"
        ) from e

    if model.startswith("anthropic/"):
        model = model.split("/", 1)[1]

    client = anthropic.Anthropic(api_key=api_key)
    msg = client.messages.create(
        model=model,
        max_tokens=1024,
        temperature=0.0,
        system=system_prompt,
        messages=[{"role": "user", "content": user_prompt}],
    )
    parts = []
    for block in msg.content:
        if getattr(block, "type", None) == "text":
            parts.append(block.text)
    return "".join(parts)


def _parse_judge_response(response_text: str) -> tuple[int, str]:
    if "```json" in response_text:
        response_text = response_text.split("```json")[1].split("```")[0].strip()
    elif "```" in response_text:
        response_text = response_text.split("```")[1].split("```")[0].strip()

    judge_result = json.loads(response_text)
    score = int(judge_result.get("score", 0))
    reasoning = str(judge_result.get("reasoning", ""))
    return score, reasoning


def run_response_check(gym: str, config: dict, db_id: Optional[str]) -> bool:
    sql_query = config.get("sql_query")
    comparison_prompt = config.get("comparison_prompt")
    minimum_score = int(config.get("minimum_comparison_value", 7))

    if not sql_query or not comparison_prompt:
        print("[response_verifier] missing sql_query or comparison_prompt")
        return False

    sql_result = _execute_sql_query(sql_query, gym, db_id)
    if not sql_result.get("success"):
        print(f"[response_verifier] SQL failed on gym={gym}: {sql_result.get('error')}")
        return False

    model_response = atif_to_eog_model_response("/logs/agent/trajectory.json")
    llm_response_text = _extract_llm_content(model_response)

    judge_user_prompt = _build_judge_user_prompt(sql_result, llm_response_text, comparison_prompt)
    judge_model = os.environ.get("JUDGE_MODEL", "anthropic/claude-haiku-4-5-20260215")

    try:
        raw = _call_judge(_JUDGE_SYSTEM_PROMPT, judge_user_prompt, judge_model)
        score, reasoning = _parse_judge_response(raw)
    except Exception as e:
        print(f"[response_verifier] judge call failed: {type(e).__name__}: {e}")
        return False

    passed = score >= minimum_score
    print(
        f"[response_verifier] gym={gym} score={score} min={minimum_score} "
        f"reasoning={reasoning!r} -> {'PASS' if passed else 'FAIL'}"
    )
    return passed
