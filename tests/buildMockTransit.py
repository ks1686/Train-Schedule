"""Regenerates tests/sql/table_data.sql.

Seed transit data is generated RELATIVE TO TODAY so a fresh database always
has bookable trains: the schedule window starts one week out and runs 31
days. Re-run this script any time to roll the mock data forward:

    python3 tests/buildMockTransit.py
"""
from datetime import date, timedelta

# Day 0 of the schedule window: one week from today (always bookable).
START_DATE = date.today() + timedelta(days=7)


def D(offset):
    """ISO date string for `offset` days after the window start."""
    return (START_DATE + timedelta(days=offset)).isoformat()


def DT(offset, clock):
    """DATETIME string for `offset` days after the window start."""
    return f"{D(offset)} {clock}"


# Reservations were placed "yesterday"; questions/answers two days ago.
RES_DAY = (date.today() - timedelta(days=1)).isoformat()
QA_DAY = (date.today() - timedelta(days=2)).isoformat()

table = '''USE trains;\n'''

clearTable = '''SET FOREIGN_KEY_CHECKS=0; 
TRUNCATE TABLE Reservation;
TRUNCATE TABLE Answers;
TRUNCATE TABLE Questions;
TRUNCATE TABLE Customer;
TRUNCATE TABLE Manages;
TRUNCATE TABLE Employee;
TRUNCATE TABLE Stop;
TRUNCATE TABLE TransitLine;
TRUNCATE TABLE Train;
TRUNCATE TABLE Station;
SET FOREIGN_KEY_CHECKS=1;
'''

customerFormat = '''INSERT INTO Customer (customerId, firstName, lastName, username, password, email) 
VALUES
    (1, 'Alice', 'Green', 'aliceg', 'securepass1', 'alice@example.com'),
    (2, 'Bob', 'White', 'bobw', 'securepass2', 'bob@example.com'),
    (3, 'Charlie', 'Black', 'charlieb', 'securepass3', 'charlie@example.com'),
    (4, 'Daisy', 'Brown', 'daisyb', 'securepass4', 'daisy@example.com'),
    (5, 'Evan', 'Gray', 'evang', 'securepass5', 'evan@example.com');
'''
employeeFormat = '''INSERT INTO Employee (ssn, firstName, lastName, username, password, role) 
VALUES
    ('111-11-1111', 'employee', 'one', 'emp1', 'emp1', 'Representative'),
    ('123-45-6789', 'John', 'Doe', 'jdoe', 'password123', 'Manager'),
    ('222-22-2222', 'manager', 'one', 'mgr1', 'mgr1', 'Manager'),
    ('321-65-9874', 'Michael', 'Johnson', 'mjohnson', 'passwordabc', 'Manager'),
    ('456-78-9012', 'Emily', 'Brown', 'ebrown', 'password789', 'Representative'),
    ('654-32-1098', 'Sarah', 'Taylor', 'staylor', 'passwordxyz', 'Representative'),
    ('987-65-4321', 'Jane', 'Smith', 'jsmith', 'password456', 'Representative');
'''

managesFormat = '''INSERT INTO Manages (manager_ssn, representative_ssn) 
VALUES
    ('123-45-6789', '111-11-1111'),
    ('123-45-6789', '987-65-4321'),
    ('222-22-2222', '456-78-9012'),
    ('321-65-9874', '654-32-1098');
'''

questionsFormat = f'''INSERT INTO Questions (questionId, customerId, questionText, questionDate) 
VALUES
    (1, 1, 'What are the available discounts?', '{QA_DAY} 02:19:27'),
    (2, 2, 'Are pets allowed on trains?', '{QA_DAY} 02:19:27'),
    (3, 3, 'Can I reschedule my reservation?', '{QA_DAY} 02:19:27'),
    (4, 4, 'What are the COVID-19 precautions?', '{QA_DAY} 02:19:27'),
    (5, 5, 'How can I book a round trip?', '{QA_DAY} 02:19:27');
'''

answersFormat = f'''INSERT INTO Answers (answerId, questionId, employeeSSN, answerText, answerDate) 
VALUES
    (1, 1, '987-65-4321', 'Yes, students get 10% off.', '{QA_DAY} 02:20:25'),
    (2, 2, '456-78-9012', 'Yes, small pets are allowed with a carrier.', '{QA_DAY} 02:20:25'),
    (3, 3, '987-65-4321', 'You can reschedule up to 24 hours in advance.', '{QA_DAY} 02:20:25'),
    (4, 4, '654-32-1098', 'We sanitize regularly and enforce mask-wearing.', '{QA_DAY} 02:20:25'),
    (5, 5, '987-65-4321', 'Select the round-trip option during booking.', '{QA_DAY} 02:20:25');
'''

src = '''-- source: https://www.njtransit.com/pdf/rail/r0070.pdf'''

stationFormat = '''INSERT INTO Station (name, city, state)
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
'''

trainFormat = '''INSERT INTO Train (trainId)
VALUES
    (3818),
    (3828),
    (3830),
    (3861),
    (3725),
    (3873);
'''

lineFormat = '''INSERT INTO TransitLine (lineName, trainId, origin, destination, departureDateTime, arrivalDateTime, fare)
VALUES '''
for i in range(0, 31):
    lineFormat += f'''        
    -- {D(i)}
    ("NJ Northeast Corridor 8AM", 3818, 1, 16, "{DT(i, '06:11')}", "{DT(i, '07:50')}", 80.00),
    ("NJ Northeast Corridor 9AM", 3828, 1, 16, "{DT(i, '07:23')}", "{DT(i, '09:06')}", 100.00),
    ("NJ Northeast Corridor 10AM", 3830, 1, 16, "{DT(i, '08:00')}", "{DT(i, '09:37')}", 100.00),
    ("NJ Northeast Corridor 4PM", 3861, 16, 1, "{DT(i, '16:30')}", "{DT(i, '18:04')}", 100.00),
    ("NJ Northeast Corridor 5PM", 3725, 16, 4, "{DT(i, '17:08')}", "{DT(i, '18:13')}", 90.00),
    ("NJ Northeast Corridor 6PM", 3873, 16, 1, "{DT(i, '18:14')}", "{DT(i, '19:43')}", 80.00),
    '''
lineFormat = lineFormat[:-6] + ';\n'


stopFormat = '''INSERT INTO Stop (stopStation, stopLine, departureDateTime, arrivalDateTime)
VALUES'''
for i in range(0, 31):
    stopFormat += f'''         
-- {D(i)}
    -- 3818 to NY (7:50 AM)
    (1, {i * 6 + 1}, "{DT(i, '06:12')}", "{DT(i, '06:11')}"),
    (2, {i * 6 + 1}, "{DT(i, '06:18')}", "{DT(i, '06:17')}"),
    (3, {i * 6 + 1}, "{DT(i, '06:26')}", "{DT(i, '06:25')}"),
    (5, {i * 6 + 1}, "{DT(i, '06:41')}", "{DT(i, '06:40')}"),
    (6, {i * 6 + 1}, "{DT(i, '06:46')}", "{DT(i, '06:45')}"),
    (7, {i * 6 + 1}, "{DT(i, '06:51')}", "{DT(i, '06:50')}"),
    (8, {i * 6 + 1}, "{DT(i, '06:56')}", "{DT(i, '06:55')}"),
    (9, {i * 6 + 1}, "{DT(i, '07:04')}", "{DT(i, '07:03')}"),
    (10, {i * 6 + 1}, "{DT(i, '07:09')}", "{DT(i, '07:08')}"),
    (11, {i * 6 + 1}, "{DT(i, '07:15')}", "{DT(i, '07:14')}"),
    (12, {i * 6 + 1}, "{DT(i, '07:18')}", "{DT(i, '07:17')}"),
    (13, {i * 6 + 1}, "{DT(i, '07:23')}", "{DT(i, '07:22')}"),
    (14, {i * 6 + 1}, "{DT(i, '07:30')}", "{DT(i, '07:29')}"),
    (15, {i * 6 + 1}, "{DT(i, '07:38')}", "{DT(i, '07:37')}"),
    (16, {i * 6 + 1}, "{DT(i, '07:50')}", "{DT(i, '07:50')}"),
    
    -- 3828 to NY (9:06 AM)
    (1, {i * 6 + 2}, "{DT(i, '07:24')}", "{DT(i, '07:23')}"),
    (2, {i * 6 + 2}, "{DT(i, '07:30')}", "{DT(i, '07:29')}"),
    (3, {i * 6 + 2}, "{DT(i, '07:37')}", "{DT(i, '07:36')}"),
    (5, {i * 6 + 2}, "{DT(i, '07:55')}", "{DT(i, '07:54')}"),
    (6, {i * 6 + 2}, "{DT(i, '08:00')}", "{DT(i, '07:59')}"),
    (7, {i * 6 + 2}, "{DT(i, '08:05')}", "{DT(i, '08:04')}"),
    (8, {i * 6 + 2}, "{DT(i, '08:10')}", "{DT(i, '08:09')}"),
    (9, {i * 6 + 2}, "{DT(i, '08:19')}", "{DT(i, '08:18')}"),
    (10, {i * 6 + 2}, "{DT(i, '08:24')}", "{DT(i, '08:23')}"),
    (11, {i * 6 + 2}, "{DT(i, '08:33')}", "{DT(i, '08:32')}"),
    (12, {i * 6 + 2}, "{DT(i, '08:36')}", "{DT(i, '08:35')}"),
    (13, {i * 6 + 2}, "{DT(i, '08:39')}", "{DT(i, '08:38')}"),
    (14, {i * 6 + 2}, "{DT(i, '08:45')}", "{DT(i, '08:44')}"),
    (15, {i * 6 + 2}, "{DT(i, '08:54')}", "{DT(i, '08:53')}"),
    (16, {i * 6 + 2}, "{DT(i, '09:06')}", "{DT(i, '09:06')}"),
    
    -- 3830 to NY (9:37 AM)
    (1, {i * 6 + 3}, "{DT(i, '08:01')}", "{DT(i, '08:00')}"),
    (2, {i * 6 + 3}, "{DT(i, '08:08')}", "{DT(i, '08:07')}"),
    (3, {i * 6 + 3}, "{DT(i, '08:15')}", "{DT(i, '08:14')}"),
    (5, {i * 6 + 3}, "{DT(i, '08:36')}", "{DT(i, '08:35')}"),
    (6, {i * 6 + 3}, "{DT(i, '08:40')}", "{DT(i, '08:39')}"),
    (7, {i * 6 + 3}, "{DT(i, '08:45')}", "{DT(i, '08:44')}"),
    (8, {i * 6 + 3}, "{DT(i, '08:49')}", "{DT(i, '08:48')}"),
    (9, {i * 6 + 3}, "{DT(i, '08:55')}", "{DT(i, '08:54')}"),
    (10, {i * 6 + 3}, "{DT(i, '08:59')}", "{DT(i, '08:58')}"),
    (11, {i * 6 + 3}, "{DT(i, '09:05')}", "{DT(i, '09:04')}"),
    (12, {i * 6 + 3}, "{DT(i, '09:08')}", "{DT(i, '09:07')}"),
    (13, {i * 6 + 3}, "{DT(i, '09:12')}", "{DT(i, '09:11')}"),
    (14, {i * 6 + 3}, "{DT(i, '09:17')}", "{DT(i, '09:16')}"),
    (15, {i * 6 + 3}, "{DT(i, '09:25')}", "{DT(i, '09:24')}"),
    (16, {i * 6 + 3}, "{DT(i, '09:37')}", "{DT(i, '09:37')}"),
    
    -- 3861 from NY (4:30 PM)
    (16, {i * 6 + 4}, "{DT(i, '16:31')}", "{DT(i, '16:30')}"),
    (15, {i * 6 + 4}, "{DT(i, '16:41')}", "{DT(i, '16:40')}"),
    (14, {i * 6 + 4}, "{DT(i, '16:50')}", "{DT(i, '16:49')}"),
    (13, {i * 6 + 4}, "{DT(i, '16:56')}", "{DT(i, '16:55')}"),
    (12, {i * 6 + 4}, "{DT(i, '17:00')}", "{DT(i, '16:59')}"),
    (11, {i * 6 + 4}, "{DT(i, '17:03')}", "{DT(i, '17:02')}"),
    (10, {i * 6 + 4}, "{DT(i, '17:08')}", "{DT(i, '17:07')}"),
    (9, {i * 6 + 4}, "{DT(i, '17:12')}", "{DT(i, '17:11')}"),
    (8, {i * 6 + 4}, "{DT(i, '17:17')}", "{DT(i, '17:16')}"),
    (7, {i * 6 + 4}, "{DT(i, '17:22')}", "{DT(i, '17:21')}"),
    (6, {i * 6 + 4}, "{DT(i, '17:26')}", "{DT(i, '17:25')}"),
    (5, {i * 6 + 4}, "{DT(i, '17:30')}", "{DT(i, '17:29')}"),
    (3, {i * 6 + 4}, "{DT(i, '17:46')}", "{DT(i, '17:45')}"),
    (2, {i * 6 + 4}, "{DT(i, '17:53')}", "{DT(i, '17:52')}"),
    (1, {i * 6 + 4}, "{DT(i, '18:04')}", "{DT(i, '18:04')}"),
    
    -- 3725 from NY (5:08 PM)
    (16, {i * 6 + 5}, "{DT(i, '17:09')}", "{DT(i, '17:08')}"),
    (15, {i * 6 + 5}, "{DT(i, '17:29')}", "{DT(i, '17:18')}"),
    (14, {i * 6 + 5}, "{DT(i, '17:30')}", "{DT(i, '17:29')}"),
    (13, {i * 6 + 5}, "{DT(i, '17:36')}", "{DT(i, '17:35')}"),
    (8, {i * 6 + 5}, "{DT(i, '17:50')}", "{DT(i, '17:49')}"),
    (7, {i * 6 + 5}, "{DT(i, '17:55')}", "{DT(i, '17:54')}"),
    (6, {i * 6 + 5}, "{DT(i, '18:00')}", "{DT(i, '17:59')}"),
    (5, {i * 6 + 5}, "{DT(i, '18:04')}", "{DT(i, '18:04')}"),
    (4, {i * 6 + 5}, "{DT(i, '18:13')}", "{DT(i, '18:13')}"),
    
    -- 3873 from NY (6:14 PM)
    (16, {i * 6 + 6}, "{DT(i, '18:15')}", "{DT(i, '18:14')}"),
    (14, {i * 6 + 6}, "{DT(i, '18:31')}", "{DT(i, '18:30')}"),
    (13, {i * 6 + 6}, "{DT(i, '18:37')}", "{DT(i, '18:36')}"),
    (9, {i * 6 + 6}, "{DT(i, '18:47')}", "{DT(i, '18:46')}"),
    (8, {i * 6 + 6}, "{DT(i, '18:53')}", "{DT(i, '18:52')}"),
    (7, {i * 6 + 6}, "{DT(i, '18:58')}", "{DT(i, '18:57')}"),
    (6, {i * 6 + 6}, "{DT(i, '19:04')}", "{DT(i, '19:03')}"),
    (5, {i * 6 + 6}, "{DT(i, '19:08')}", "{DT(i, '19:07')}"),
    (4, {i * 6 + 6}, "{DT(i, '19:13')}", "{DT(i, '19:12')}"),
    (3, {i * 6 + 6}, "{DT(i, '19:25')}", "{DT(i, '19:24')}"),
    (2, {i * 6 + 6}, "{DT(i, '19:32')}", "{DT(i, '19:31')}"),
    (1, {i * 6 + 6}, "{DT(i, '19:43')}", "{DT(i, '19:43')}"),
    '''
stopFormat = stopFormat[:-6] + ';\n'

reservationFormat = f'''INSERT INTO Reservation (customerId, transitLineId, originStopId, destinationStopId, reservationDateTime, isRoundTrip, discount, totalFare)
VALUES 
    (1, 49, 650, 653, '{RES_DAY} 01:42:15', 1, 50, 17.14),
    (1, 56, 747, 753, '{RES_DAY} 01:59:24', 0, 0, 42.86),
    (1, 78, 1042, 1048, '{RES_DAY} 02:00:00', 1, 0, 87.27),
    (1, 90, 1205, 1212, '{RES_DAY} 02:00:46', 0, 0, 50.91),
    (1, 25, 330, 336, '{RES_DAY} 02:00:56', 1, 0, 68.57),
    (1, 45, 600, 610, '{RES_DAY} 02:01:10', 1, 0, 142.86),
    (2, 43, 569, 577, '{RES_DAY} 02:03:53', 1, 50, 45.71),
    (2, 56, 748, 751, '{RES_DAY} 02:04:09', 1, 50, 21.43),
    (2, 64, 856, 868, '{RES_DAY} 02:04:24', 1, 50, 85.71),
    (2, 76, 1020, 1032, '{RES_DAY} 02:04:39', 1, 35, 111.43),
    (3, 31, 407, 415, '{RES_DAY} 02:05:22', 1, 25, 68.57),
    (3, 56, 749, 759, '{RES_DAY} 02:05:41', 0, 25, 53.57),
    (3, 64, 856, 862, '{RES_DAY} 02:05:57', 1, 25, 64.29),
    (4, 59, 790, 794, '{RES_DAY} 02:06:25', 0, 35, 29.25),
    (4, 59, 790, 794, '{RES_DAY} 02:06:56', 1, 25, 67.50),
    (4, 59, 790, 794, '{RES_DAY} 02:07:11', 1, 0, 90.00),
    (4, 59, 790, 794, '{RES_DAY} 02:07:39', 1, 50, 45.00),
    (5, 60, 799, 803, '{RES_DAY} 02:09:03', 0, 0, 29.09),
    (5, 31, 410, 417, '{RES_DAY} 02:09:17', 1, 0, 80.00),
    (5, 150, 2022, 2024, '{RES_DAY} 02:09:34', 1, 0, 29.09),
    (5, 154, 2075, 2080, '{RES_DAY} 02:09:55', 1, 0, 71.43),
    (5, 176, 2366, 2376, '{RES_DAY} 02:13:03', 1, 0, 142.86);
'''

# Refresh optimizer statistics: without this, stats captured on the empty
# tables make MySQL 8 pick plans that explode on the seeded volumes.
analyzeFormat = '''ANALYZE TABLE Employee;
ANALYZE TABLE Manages;
ANALYZE TABLE Customer;
ANALYZE TABLE Questions;
ANALYZE TABLE Answers;
ANALYZE TABLE Station;
ANALYZE TABLE Train;
ANALYZE TABLE TransitLine;
ANALYZE TABLE Stop;
ANALYZE TABLE Reservation;
'''

with open('tests/sql/table_data.sql', 'w') as f:
    print(table, file=f)
    print(clearTable, file=f)
    print(customerFormat, file=f)
    print(employeeFormat, file=f)
    print(managesFormat, file=f)
    print(questionsFormat, file=f)
    print(answersFormat, file=f)
    print(src, file=f)
    print(stationFormat, file=f)
    print(trainFormat, file=f)
    print(lineFormat, file=f)
    print(stopFormat, file=f)
    print(reservationFormat, file=f)
    print(analyzeFormat, file=f)
