FROM python:3.12-slim@sha256:d657ab0ade19f404a6ccc883ab399540de667aff751748ce23c07330c5a89e64
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates jq \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

CMD ["sleep", "infinity"]
