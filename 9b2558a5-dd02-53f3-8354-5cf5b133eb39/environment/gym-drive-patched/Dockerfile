# Derived image: the published drive gym + two bug-fix files layered on top.
# No original source needed — we COPY the patched handlers over the baked-in ones.
FROM shivakrishnareddyma225/enterpriseops-gym-mcp-drive:latest
COPY permissions_router.py /app/app/api/permissions_router.py
COPY files_router.py       /app/app/api/files_router.py
