CREATE DATABASE IF NOT EXISTS trains;
USE trains;

CREATE TABLE Employee (
    ssn CHAR(11) PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('Manager', 'Representative'),
    INDEX idx_employee_username (username)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Manages (
    manager_ssn CHAR(11) NOT NULL,
    representative_ssn CHAR(11) NOT NULL,
    PRIMARY KEY (manager_ssn, representative_ssn),
    FOREIGN KEY (manager_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (representative_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Customer (
    customerId INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(25) NOT NULL,
    lastName VARCHAR(25) NOT NULL,
    username VARCHAR(10) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL,
    UNIQUE KEY uq_customer_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Questions (
    questionId INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    questionText TEXT NOT NULL,
    questionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Answers (
    answerId INT AUTO_INCREMENT PRIMARY KEY,
    questionId INT NOT NULL,
    employeeSSN CHAR(11) NOT NULL,
    answerText TEXT NOT NULL,
    answerDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_answers_question (questionId),
    FOREIGN KEY (questionId) REFERENCES Questions(questionId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (employeeSSN) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Station (
    stationId INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(20),
    state CHAR(2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Train (
    trainId INT CHECK (1000 <= trainId AND trainId <= 9999) PRIMARY KEY
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE TransitLine (
    lineId INT AUTO_INCREMENT PRIMARY KEY,
    lineName VARCHAR(50),
    trainId INT NOT NULL,
    origin INT NOT NULL,
    destination INT NOT NULL,
    departureDateTime DATETIME,
    arrivalDateTime DATETIME,
    fare DECIMAL(10,2),
    FOREIGN KEY (trainId) REFERENCES Train(trainId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (origin) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (destination) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_transitline_name_depart (lineName, departureDateTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Stop (
    stopId INT AUTO_INCREMENT PRIMARY KEY,
    stopStation INT NOT NULL,
    stopLine INT NOT NULL,
    departureDateTime DATETIME NOT NULL,
    arrivalDateTime DATETIME NOT NULL,
    stopSequence INT NOT NULL DEFAULT 0,
    UNIQUE KEY uq_stop_line_station (stopLine, stopStation),
    FOREIGN KEY (stopStation) REFERENCES Station(stationId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (stopLine) REFERENCES TransitLine(lineId) ON DELETE CASCADE ON UPDATE CASCADE,
    INDEX idx_stop_station_depart (stopStation, departureDateTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE Reservation (
    reservationNo INT AUTO_INCREMENT PRIMARY KEY,
    customerId INT NOT NULL,
    transitLineId INT NOT NULL,
    originStopId INT NOT NULL,
    destinationStopId INT NOT NULL,
    reservationDateTime DATETIME NOT NULL,
    isRoundTrip BOOLEAN NOT NULL,
    discount INT NOT NULL,
    totalFare DECIMAL(10,2) NOT NULL,
    CHECK (discount >= 0 AND discount <= 100),
    CHECK (totalFare >= 0),
    FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (transitLineId) REFERENCES TransitLine(lineId) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (originStopId) REFERENCES Stop(stopId) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (destinationStopId) REFERENCES Stop(stopId) ON DELETE RESTRICT ON UPDATE CASCADE,
    INDEX idx_reservation_customer_line (customerId, transitLineId),
    INDEX idx_reservation_datetime (reservationDateTime)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
