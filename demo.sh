#!/usr/bin/env bash
# One-command demo: builds the WAR, starts MySQL + Tomcat via Docker Compose,
# and prints the URL and demo logins. Requires Docker.
set -euo pipefail
cd "$(dirname "$0")"

PORT="${TRAIN_SCHEDULE_PORT:-8080}"

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
