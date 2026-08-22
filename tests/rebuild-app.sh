#!/usr/bin/env bash
# Rebuild just the app container (db keeps running) and wait until it serves.
set -euo pipefail
cd "$(dirname "$0")"
docker compose up --build --detach app
for i in $(seq 1 60); do
  code="$(curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/train-schedule/login.jsp || true)"
  [ "$code" = "200" ] && { echo "app ready"; exit 0; }
  sleep 3
done
echo "app not ready; logs:"; docker compose logs --tail 30 app
exit 1
