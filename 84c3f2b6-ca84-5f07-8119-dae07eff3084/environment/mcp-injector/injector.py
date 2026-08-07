"""MCP reverse-proxy sidecar for EnterpriseOps-Gym tasks.

Reads per-gym HTTP headers from GYM_CONTEXTS_JSON and per-gym database_id
files from /shared/database_id_<gym>, and injects them onto every proxied
MCP request. Streams the response back verbatim.
"""
import json
import os
from pathlib import Path

import httpx
from fastapi import FastAPI, Request
from fastapi.responses import Response

app = FastAPI()

GYM_CONTEXTS: dict[str, dict[str, str]] = json.loads(os.environ["GYM_CONTEXTS_JSON"])
GYM_UPSTREAMS: dict[str, str] = json.loads(os.environ["GYM_UPSTREAMS_JSON"])
SHARED_DIR = Path(os.environ.get("SHARED_DIR", "/shared"))


def _read_database_id(gym: str) -> str | None:
    path = SHARED_DIR / f"database_id_{gym}"
    if path.exists():
        return path.read_text().strip() or None
    return None


@app.api_route("/mcp/{gym}{path:path}", methods=["GET", "POST", "PUT", "DELETE", "PATCH"])
async def proxy(gym: str, path: str, request: Request):
    if gym not in GYM_UPSTREAMS:
        return Response(f"unknown gym: {gym}", status_code=404)
    upstream = GYM_UPSTREAMS[gym].rstrip("/") + path
    headers = {k: v for k, v in request.headers.items() if k.lower() != "host"}
    headers.update(GYM_CONTEXTS.get(gym, {}))
    db_id = _read_database_id(gym)
    if db_id:
        headers["x-database-id"] = db_id
    body = await request.body()
    async with httpx.AsyncClient(timeout=60.0) as client:
        upstream_resp = await client.request(
            request.method,
            upstream,
            headers=headers,
            content=body,
            params=dict(request.query_params),
        )
    return Response(
        content=upstream_resp.content,
        status_code=upstream_resp.status_code,
        headers={
            k: v
            for k, v in upstream_resp.headers.items()
            if k.lower() != "content-encoding"
        },
    )


@app.get("/healthz")
def healthz():
    return {"ok": True, "gyms": list(GYM_UPSTREAMS.keys())}
