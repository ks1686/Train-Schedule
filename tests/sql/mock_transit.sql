USE trains;

SET FOREIGN_KEY_CHECKS=0; 
TRUNCATE TABLE Stop;
TRUNCATE TABLE TransitLine;
TRUNCATE TABLE Station;
SET FOREIGN_KEY_CHECKS=1; 

-- source: https://www.njtransit.com/pdf/rail/r0070.pdf
INSERT INTO Station (name, city, state)
VALUES 
    ("Trenton Transit Center", "Trenton", "NJ"),
    ("Hamilton", "Hamilton", "NJ"),
    ("Princeton Junction", "Princeton", "NJ"),
    ("Jersey Avenue", "New Brunswick", "NJ"),
    ("New Brunswick", "New Brunswick", "NJ"),
    ("Edison", "Edison", "NJ"),
    ("Metuchen", "Metuchen", "NJ"),
    ("Metropark", "Iselin", "NJ"),
    ("Rahway", "Rahway", "NJ"),
    ("Linden", "Linden", "NJ"),
    ("Elizabeth", "Elizabeth", "NJ"),
    ("North Elizabeth", "Elizabeth", "NJ"),
    ("Newark Int'l Airport", "Newark", "NJ"),
    ("Newark Penn Station", "Newark", "NJ"),
    ("Secaucus Junction", "Secaucus", "NJ"),
    ("New York Penn Station", "New York", "NY");

INSERT INTO TransitLine (lineName, origin, destination, departureDateTime, arrivalDateTime, fare)
VALUES ("NJ Northeast Corridor", 1, 16, "2024-12-10 07:23", "2024-12-10 09:06", 100.00);

INSERT INTO Stop (stopStation, stopLine, departureDateTime, arrivalDateTime)
VALUES 
	(1, 1, "2024-12-10 07:24", "2024-12-10 07:23"),
	(2, 1, "2024-12-10 07:30", "2024-12-10 07:29"),
	(3, 1, "2024-12-10 07:37", "2024-12-10 07:36"),
	(5, 1, "2024-12-10 07:55", "2024-12-10 07:54"),
	(6, 1, "2024-12-10 08:00", "2024-12-10 07:59"),
	(7, 1, "2024-12-10 08:05", "2024-12-10 08:04"),
	(8, 1, "2024-12-10 08:10", "2024-12-10 08:09"),
	(9, 1, "2024-12-10 08:19", "2024-12-10 08:18"),
	(10, 1, "2024-12-10 08:24", "2024-12-10 08:23"),
	(11, 1, "2024-12-10 08:33", "2024-12-10 08:32"),
	(12, 1, "2024-12-10 08:36", "2024-12-10 08:35"),
	(13, 1, "2024-12-10 08:39", "2024-12-10 08:38"),
	(14, 1, "2024-12-10 08:45", "2024-12-10 08:44"),
	(15, 1, "2024-12-10 08:54", "2024-12-10 08:53"),
	(16, 1, "2024-12-10 09:06", "2024-12-10 09:06");