"""Database-state verifier — port of harness/benchmark/verifier.py.

Signature: run_database_state(gym, config, db_id) -> bool.

Ported from harness `_execute_database_state_verifier` (lines 81–127),
`_extract_value_from_sql_result` (lines 291–372), and `_compare_values`
(lines 374–399). Preserves the exact 10-branch parse tree so verifier
verdicts are byte-identical to the harness.
"""
from typing import Any, Optional

import httpx

_GYM_TO_HOST_PORT: dict[str, tuple[str, int]] = {
    "calendar_v4":          ("gym-calendar", 8003),
    "teams-internal-prod":  ("gym-teams",    8002),
    "email_v4":             ("gym-email",    8004),
    "sn-hr-internal":       ("gym-hr",       8008),
    "gym-itsm-mcp":         ("gym-itsm",     8006),
    "gym-email-mcp":        ("gym-email",    8004),
    "gym-calendar":         ("gym-calendar", 8003),
    "gym-teams-mcp":        ("gym-teams",    8002),
    "sn-csm-server":        ("gym-csm",      8001),
    "gym-google-drive-mcp": ("gym-drive",    8009),
}


def _execute_sql_query(query: str, gym: str, db_id: Optional[str]) -> dict:
    if gym not in _GYM_TO_HOST_PORT:
        return {"success": False, "error": f"unknown gym: {gym}"}
    host, port = _GYM_TO_HOST_PORT[gym]
    api_url = f"http://{host}:{port}/api/sql-runner"
    payload = {"query": query, "database_id": db_id}
    headers = {"Content-Type": "application/json"}
    if db_id:
        headers["x-database-id"] = db_id
    try:
        with httpx.Client(timeout=httpx.Timeout(30.0)) as client:
            resp = client.post(api_url, json=payload, headers=headers)
            resp.raise_for_status()
            return {"success": True, "result": resp.json()}
    except httpx.HTTPStatusError as e:
        body = ""
        try:
            body = e.response.text
        except Exception:
            body = "<no body>"
        return {"success": False, "error": f"HTTP {e.response.status_code}: {body}"}
    except httpx.HTTPError as e:
        return {"success": False, "error": f"HTTP error: {e}"}


def _extract_value_from_sql_result(result: dict) -> Any:
    if not result:
        return None

    if not result.get("success"):
        result_data = result.get("result", {})
        if isinstance(result_data, dict) and "content" in result_data:
            content = result_data["content"]
            if isinstance(content, list) and len(content) > 0:
                for item in content:
                    if isinstance(item, dict) and item.get("type") == "text":
                        return item.get("text", "Error")
        return None

    result_data = result.get("result", {})

    if isinstance(result_data, dict):
        if "data" in result_data:
            data = result_data["data"]
            if isinstance(data, list) and len(data) > 0:
                if (
                    len(data) == 1
                    and isinstance(data[0], dict)
                    and len(data[0]) == 1
                ):
                    return list(data[0].values())[0]
                elif len(data) == 1:
                    return data[0]
                else:
                    return data
            return data

        elif "rows" in result_data:
            rows = result_data["rows"]
            if isinstance(rows, list) and len(rows) > 0:
                if (
                    len(rows) == 1
                    and isinstance(rows[0], dict)
                    and len(rows[0]) == 1
                ):
                    return list(rows[0].values())[0]
                elif (
                    len(rows) == 1
                    and isinstance(rows[0], list)
                    and len(rows[0]) == 1
                ):
                    return rows[0][0]
                elif len(rows) == 1:
                    return rows[0]
                else:
                    return rows
            return rows

        elif "content" in result_data:
            content = result_data["content"]
            if isinstance(content, list) and len(content) > 0:
                for item in content:
                    if isinstance(item, dict) and item.get("type") == "text":
                        return item.get("text", result_data)
            return content

        elif "result" in result_data:
            return result_data["result"]

    return result_data


def _compare_values(actual: Any, expected: Any, comparison_type: str) -> bool:
    try:
        if comparison_type == "equals":
            return actual == expected
        if comparison_type == "greater_than":
            return actual > expected
        if comparison_type == "less_than":
            return actual < expected
        if comparison_type == "contains":
            return expected in str(actual)
        return False
    except Exception:
        return False


def run_database_state(gym: str, config: dict, db_id: Optional[str]) -> bool:
    sql_query = config.get("query")
    expected_value = config.get("expected_value")
    comparison_type = config.get("comparison_type", "equals")

    if not sql_query:
        print(f"[db_verifier] no query in config for gym={gym}")
        return False

    result = _execute_sql_query(sql_query, gym, db_id)
    if not result.get("success"):
        print(f"[db_verifier] SQL failed on gym={gym}: {result.get('error')}")
        return False

    actual_value = _extract_value_from_sql_result(result)
    passed = _compare_values(actual_value, expected_value, comparison_type)
    print(
        f"[db_verifier] gym={gym} comparison={comparison_type} "
        f"expected={expected_value!r} actual={actual_value!r} -> {'PASS' if passed else 'FAIL'}"
    )
    return passed
