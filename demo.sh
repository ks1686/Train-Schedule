#!/usr/bin/env bash
# One-command demo: builds the WAR, starts MySQL + Tomcat via Docker Compose,
# and prints the URL and demo logins. Requires Docker.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${TRAIN_SCHEDULE_PORT:-8080}"

# The committed seed data is dated relative to the day it was generated, so it
# goes stale. Regenerate it so the schedule window starts a week from today.
if command -v python3 >/dev/null 2>&1; then
  echo "==> Regenerating seed data relative to today..."
  python3 tests/buildMockTransit.py
  echo "    Note: an existing database volume keeps its old data; run 'docker compose down -v' first to reseed."
else
  echo "==> python3 not found; using committed seed data (dates may be in the past)."
fi

echo "==> Starting MySQL and Tomcat (first run downloads images)..."
docker compose up --build --detach

echo "==> Waiting for http://localhost:${PORT}/train-schedule/ ..."
for i in $(seq 1 60); do
  status="$(curl -s -o /dev/null -w '%{http_code}' "http://localhost:${PORT}/train-schedule/login.jsp" || true)"
  if [ "$status" = "200" ]; then
    break
  fi
  sleep 2
done

if [ "$status" != "200" ]; then
  echo "App did not come up. Check logs with: docker compose logs app"
  exit 1
fi

cat <<EOF

==========================================================
 Train Reservation System is running!

   Open:   http://localhost:${PORT}/train-schedule/

   Log in as any of:
     Customer        aliceg  / securepass1
     Representative  emp1    / emp1
     Manager         mgr1    / mgr1

   Bookable trains are seeded one week out from today,
   for the next 31 days (search that date range).

 Stop everything with:  docker compose down -v
==========================================================
EOF
