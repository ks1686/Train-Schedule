CREATE DATABASE trains;
USE trains;

-- Table: Station
-- CREATE TABLE Station (
--     stationId INT AUTO_INCREMENT PRIMARY KEY,
--     Name VARCHAR(50),
--     City VARCHAR(15),
--     State CHAR(2)
-- );

-- Table: Employee
CREATE TABLE Employee (
    ssn CHAR(11) PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    role ENUM('Manager', 'Representative')
);

-- Table: Customer
CREATE TABLE Customer (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL
);

-- Table: TrainSchedule
-- CREATE TABLE TrainSchedule (
--     scheduleId INT AUTO_INCREMENT PRIMARY KEY,
--     lineName VARCHAR(25),
--     trainId INT,
--     origin INT,
--     destination INT,
--     fare FLOAT,
--     departureTime TIME,
--     arrivalTime TIME,
--     FOREIGN KEY (origin) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (destination) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: Stop
-- CREATE TABLE Stop (
--     stopId INT AUTO_INCREMENT PRIMARY KEY,
--     departureTime TIME,
--     arrivalTime TIME,
--     stationId INT,
--     scheduleId INT,
--     FOREIGN KEY (stationId) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (scheduleId) REFERENCES TrainSchedule(scheduleId) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: Emp_Mngr
CREATE TABLE Emp_Mngr (
    manager_ssn CHAR(11) NOT NULL,
    representative_ssn CHAR(11) NOT NULL,
    PRIMARY KEY (manager_ssn, representative_ssn),
    FOREIGN KEY (manager_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (representative_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Manages
-- CREATE TABLE Manages (
--     scheduleId INT,
--     ssn CHAR(11),
--     PRIMARY KEY (scheduleId, ssn),
--     FOREIGN KEY (scheduleId) REFERENCES TrainSchedule(scheduleId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: Assists
-- CREATE TABLE Assists (
--     customerId INT,
--     ssn CHAR(11),
--     PRIMARY KEY (customerId, ssn),
--     FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: Reservation
-- CREATE TABLE Reservation (
--     reservationNo INT AUTO_INCREMENT PRIMARY KEY,
--     scheduleId INT,
--     Departure TIME,
--     Arrival TIME,
--     totalFare FLOAT,
--     dateReserved DATE,
--     origin INT,
--     destination INT,
--     customerId INT NOT NULL,
--     FOREIGN KEY (origin) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (destination) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (scheduleId) REFERENCES TrainSchedule(scheduleId) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: View
-- CREATE TABLE View (
--     reservationNo INT,
--     ssn CHAR(11),
--     PRIMARY KEY (reservationNo, ssn),
--     FOREIGN KEY (reservationNo) REFERENCES Reservation(reservationNo) ON DELETE CASCADE ON UPDATE CASCADE,
--     FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
-- );

-- Table: Questions
CREATE TABLE Questions (
    questionId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    questionText TEXT NOT NULL,
    questionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Answers
CREATE TABLE Answers (
    answerId INT AUTO_INCREMENT PRIMARY KEY,
    questionId INT NOT NULL,
    employeeSSN CHAR(11) NOT NULL,
    answerText TEXT NOT NULL,
    answerDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (questionId) REFERENCES Questions(questionId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (employeeSSN) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index for Searching based on Question
CREATE FULLTEXT INDEX idx_questionText ON Questions (questionText);