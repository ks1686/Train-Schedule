#!/usr/bin/env bash
# Manager and representative role smoke checks.
set -uo pipefail
BASE=http://localhost:8080/train-schedule
cd /tmp && rm -f mj.txt rj.txt

echo "== Manager =="
curl -s --max-time 15 -c mj.txt -o /dev/null -w 'login: %{http_code}\n' -d 'username=mgr1&password=mgr1' "$BASE/login.jsp"
curl -s --max-time 20 -b mj.txt "$BASE/Manager/managerWelcome.jsp" > mgr.html
grep -o 'Welcome to the Manager Dashboard' mgr.html | head -1
grep -o 'Top Customer: [^(]*' mgr.html | head -1

curl -s --max-time 30 -b mj.txt -X POST -d 'month=8&year=2026' "$BASE/Manager/getSalesReport.jsp" > sales.html
grep -o '<h2>Sales Report for [^<]*' sales.html | head -1
grep -c '<tr>' sales.html | xargs echo 'sales table rows:'

curl -s --max-time 30 -b mj.txt -X POST -d 'transitLine=NJ+Northeast+Corridor+8AM' "$BASE/Manager/getRevenue.jsp" > rev.html
grep -o '\$[0-9,.]*' rev.html | head -2

curl -s --max-time 30 -b mj.txt -X POST -d 'customerName=Alice+Green' "$BASE/Manager/getReservations.jsp" > resv.html
grep -o 'Filtered Reservations' resv.html

echo "== Representative =="
curl -s --max-time 15 -c rj.txt -o /dev/null -w 'login: %{http_code}\n' -d 'username=emp1&password=emp1' "$BASE/login.jsp"
curl -s --max-time 25 -b rj.txt "$BASE/Representative/repWelcome.jsp" > rep.html
grep -o 'Questions and Answers Section' rep.html | head -1
grep -c '<table' rep.html | xargs echo 'rep tables:'

curl -s --max-time 25 -b rj.txt "$BASE/Representative/viewStops.jsp?lineId=1&origin=Trenton&destination=New+York" > stops.html
grep -o 'Trenton Transit Center' stops.html | head -1
