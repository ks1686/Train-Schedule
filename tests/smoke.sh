#!/usr/bin/env bash
# End-to-end smoke test against the local docker stack.
set -uo pipefail
cd /tmp && rm -f cj.txt
BASE=http://localhost:8080/train-schedule
TARGET_DATE=$(date -v+7d +%F 2>/dev/null || date -d '+7 days' +%F)
echo "target date: $TARGET_DATE"

code=$(curl -s -o /dev/null -w '%{http_code}' "$BASE/login.jsp"); echo "login page: $code"

code=$(curl -s -c cj.txt -o /dev/null -w '%{http_code}' -d 'username=aliceg&password=securepass1' "$BASE/login.jsp")
echo "customer login POST: $code"
curl -s -b cj.txt "$BASE/Customer/customerWelcome.jsp" | grep -o 'Hello, [^<]*' | head -1

curl -s -b cj.txt -d "originStationId=1&destinationStationId=16&reservationDate=$TARGET_DATE" \
  "$BASE/Customer/viewSchedules.jsp" > sched.html
echo "reserve buttons found: $(grep -c 'Reserve</button>' sched.html)"
LINE_ID=$(grep -o 'name="reserve" value="[0-9]*"' sched.html | head -1 | grep -o '[0-9]*')
echo "picking lineId=$LINE_ID"

curl -s -b cj.txt "$BASE/Customer/confirmReservation.jsp?reserve=$LINE_ID" > conf.html
grep -o '<h2>Confirm Reservation</h2>' conf.html
CSRF=$(grep -o 'name="csrfToken" value="[^"]*"' conf.html | head -1 | sed 's/.*value="//; s/"//')
echo "csrf token length: ${#CSRF}"

loc=$(curl -s -b cj.txt -o /dev/null -w '%{redirect_url}' \
  -d "reserve=$LINE_ID&tripType=oneway&age=30&disability=no&csrfToken=$CSRF" \
  "$BASE/Customer/placeReservation.jsp")
echo "place reservation -> $loc"

curl -s -b cj.txt "$BASE/Customer/customerWelcome.jsp" > wel.html
grep -o 'Reservation Secured' wel.html | head -1
RES_NO=$(grep -o 'name="cancel" value="[0-9]*"' wel.html | head -1 | grep -o '[0-9]*')
echo "newest reservationNo=$RES_NO"

curl -s -b cj.txt -o /dev/null -w 'cancel -> %{redirect_url}\n' \
  -d "cancel=$RES_NO&csrfToken=$CSRF" "$BASE/Customer/cancelReservation.jsp"

echo "--- guard checks ---"
curl -s -b cj.txt -o /dev/null -w 'confirm garbage lineId -> %{http_code}\n' \
  "$BASE/Customer/confirmReservation.jsp?reserve=abc"
curl -s -b cj.txt -o /dev/null -w 'sales report bad month -> %{http_code}\n' -X POST \
  -d 'month=13&year=abcd' "$BASE/Manager/getSalesReport.jsp"
