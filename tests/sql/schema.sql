CREATE DATABASE trains;
USE trains;

-- Transit --
-- Table: Station
CREATE TABLE Station (
    stationId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(20),
    state CHAR(2)
);

-- Table: TransitLine
CREATE TABLE TransitLine (
    lineId INT AUTO_INCREMENT PRIMARY KEY,
    lineName VARCHAR(50),
    origin INT NOT NULL,
    destination INT NOT NULL,
    departureDateTime DATETIME,
    arrivalDateTime DATETIME,
    fare FLOAT,
    FOREIGN KEY (origin) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (destination) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Train
CREATE TABLE Train (
    trainId INT AUTO_INCREMENT PRIMARY KEY,
    trainName VARCHAR(25),
    lineId INT NOT NULL,
    FOREIGN KEY (lineId) REFERENCES TransitLine(lineId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Stop
CREATE TABLE Stop (
    stopId INT AUTO_INCREMENT UNIQUE,
    stopStation INT,
    stopLine INT,
    departureDateTime DATETIME,
    arrivalDateTime DATETIME,
    PRIMARY KEY(stopId, stopStation, stopLine),
    FOREIGN KEY (stopStation) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stopLine) REFERENCES TransitLine(lineId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Human --
-- Table: Employee
CREATE TABLE Employee (
    ssn CHAR(11) PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    role ENUM('Manager', 'Representative')
);

-- Table: Manages
CREATE TABLE Manages (
    manager_ssn CHAR(11) NOT NULL,
    representative_ssn CHAR(11) NOT NULL,
    PRIMARY KEY (manager_ssn, representative_ssn),
    FOREIGN KEY (manager_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (representative_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Customer
CREATE TABLE Customer (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL
);

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

-- Human to Transit --
-- Table: SViews
CREATE TABLE SViews (
    ssn CHAR(11),
    stopId INT NOT NULL,
    stopStation INT NOT NULL,
    stopLine INT NOT NULL,
    PRIMARY KEY (ssn, stopId, stopStation, stopLine),
    FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stopId) REFERENCES Stop(stopId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stopStation) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stopLine) REFERENCES TransitLine(lineId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Reservation
CREATE TABLE Reservation (
    reservationNo INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    transitLineId INT NOT NULL,
    originStationId INT,
    destinationStationId INT,
    reservationDateTime DATETIME,
    isRoundTrip BOOLEAN,
    discount INT CHECK (discount <= 100),
    FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (transitLineId) REFERENCES TransitLine(lineId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (originStationId) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (destinationStationId) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: RViews
CREATE TABLE RViews (
    reservationNo INT,
    ssn CHAR(11),
    PRIMARY KEY (reservationNo, ssn),
    FOREIGN KEY (reservationNo) REFERENCES Reservation(reservationNo) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index for Searching based on Question
CREATE FULLTEXT INDEX idx_questionText ON Questions (questionText);
