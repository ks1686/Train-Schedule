CREATE TABLE `Answers` (
  `answerId` int NOT NULL AUTO_INCREMENT,
  `questionId` int NOT NULL,
  `employeeSSN` char(11) NOT NULL,
  `answerText` text NOT NULL,
  `answerDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`answerId`),
  KEY `questionId` (`questionId`),
  KEY `employeeSSN` (`employeeSSN`),
  CONSTRAINT `answers_ibfk_1` FOREIGN KEY (`questionId`) REFERENCES `Questions` (`questionId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `answers_ibfk_2` FOREIGN KEY (`employeeSSN`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Customer` (
  `customerId` int NOT NULL AUTO_INCREMENT,
  `firstName` varchar(25) DEFAULT NULL,
  `lastName` varchar(25) DEFAULT NULL,
  `username` varchar(10) DEFAULT NULL,
  `password` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`customerId`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Emp_Mngr` (
  `manager_ssn` char(11) NOT NULL,
  `representative_ssn` char(11) NOT NULL,
  PRIMARY KEY (`manager_ssn`,`representative_ssn`),
  KEY `representative_ssn` (`representative_ssn`),
  CONSTRAINT `emp_mngr_ibfk_1` FOREIGN KEY (`manager_ssn`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `emp_mngr_ibfk_2` FOREIGN KEY (`representative_ssn`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Employee` (
  `ssn` char(11) NOT NULL,
  `firstName` varchar(25) NOT NULL,
  `lastName` varchar(25) NOT NULL,
  `username` varchar(10) NOT NULL,
  `password` varchar(50) NOT NULL,
  `role` enum('Manager','Representative') DEFAULT NULL,
  PRIMARY KEY (`ssn`),
  UNIQUE KEY `username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Manages` (
  `scheduleId` int NOT NULL,
  `ssn` char(11) NOT NULL,
  PRIMARY KEY (`scheduleId`,`ssn`),
  KEY `ssn` (`ssn`),
  CONSTRAINT `manages_ibfk_1` FOREIGN KEY (`ssn`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Questions` (
  `questionId` int NOT NULL AUTO_INCREMENT,
  `customerId` int NOT NULL,
  `questionText` text NOT NULL,
  `questionDate` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`questionId`),
  KEY `customerId` (`customerId`),
  FULLTEXT KEY `idx_questionText` (`questionText`),
  CONSTRAINT `questions_ibfk_1` FOREIGN KEY (`customerId`) REFERENCES `Customer` (`customerId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Reservation` (
  `reservationNo` int NOT NULL AUTO_INCREMENT,
  `customerId` int NOT NULL,
  `transitLineId` int NOT NULL,
  `originStationId` int DEFAULT NULL,
  `destinationStationId` int DEFAULT NULL,
  `reservationDateTime` datetime DEFAULT NULL,
  `isRoundTrip` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`reservationNo`),
  KEY `customerId` (`customerId`),
  KEY `transitLineId` (`transitLineId`),
  KEY `originStationId` (`originStationId`),
  KEY `destinationStationId` (`destinationStationId`),
  CONSTRAINT `reservation_ibfk_1` FOREIGN KEY (`customerId`) REFERENCES `Customer` (`customerId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservation_ibfk_2` FOREIGN KEY (`transitLineId`) REFERENCES `TransitLine` (`lineId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservation_ibfk_3` FOREIGN KEY (`originStationId`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `reservation_ibfk_4` FOREIGN KEY (`destinationStationId`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `RViews` (
  `reservationNo` int NOT NULL,
  `ssn` char(11) NOT NULL,
  PRIMARY KEY (`reservationNo`,`ssn`),
  KEY `ssn` (`ssn`),
  CONSTRAINT `rviews_ibfk_1` FOREIGN KEY (`reservationNo`) REFERENCES `Reservation` (`reservationNo`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `rviews_ibfk_2` FOREIGN KEY (`ssn`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Station` (
  `stationId` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `city` varchar(20) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  PRIMARY KEY (`stationId`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Stop` (
  `stopId` int NOT NULL AUTO_INCREMENT,
  `stopStation` int NOT NULL,
  `stopLine` int NOT NULL,
  `departureDateTime` datetime DEFAULT NULL,
  `arrivalDateTime` datetime DEFAULT NULL,
  PRIMARY KEY (`stopId`,`stopStation`,`stopLine`),
  UNIQUE KEY `stopId` (`stopId`),
  KEY `stopStation` (`stopStation`),
  KEY `stopLine` (`stopLine`),
  CONSTRAINT `stop_ibfk_1` FOREIGN KEY (`stopStation`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `stop_ibfk_2` FOREIGN KEY (`stopLine`) REFERENCES `TransitLine` (`lineId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `SViews` (
  `ssn` char(11) NOT NULL,
  `stopId` int NOT NULL,
  `stopStation` int NOT NULL,
  `stopLine` int NOT NULL,
  PRIMARY KEY (`ssn`,`stopId`,`stopStation`,`stopLine`),
  KEY `stopId` (`stopId`),
  KEY `stopStation` (`stopStation`),
  KEY `stopLine` (`stopLine`),
  CONSTRAINT `sviews_ibfk_1` FOREIGN KEY (`ssn`) REFERENCES `Employee` (`ssn`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sviews_ibfk_2` FOREIGN KEY (`stopId`) REFERENCES `Stop` (`stopId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sviews_ibfk_3` FOREIGN KEY (`stopStation`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `sviews_ibfk_4` FOREIGN KEY (`stopLine`) REFERENCES `TransitLine` (`lineId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `Train` (
  `trainId` int NOT NULL AUTO_INCREMENT,
  `trainName` varchar(25) DEFAULT NULL,
  `lineId` int NOT NULL,
  PRIMARY KEY (`trainId`),
  KEY `lineId` (`lineId`),
  CONSTRAINT `train_ibfk_1` FOREIGN KEY (`lineId`) REFERENCES `TransitLine` (`lineId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE `TransitLine` (
  `lineId` int NOT NULL AUTO_INCREMENT,
  `lineName` varchar(50) DEFAULT NULL,
  `origin` int NOT NULL,
  `destination` int NOT NULL,
  `departureDateTime` datetime DEFAULT NULL,
  `arrivalDateTime` datetime DEFAULT NULL,
  `fare` float DEFAULT NULL,
  PRIMARY KEY (`lineId`),
  KEY `origin` (`origin`),
  KEY `destination` (`destination`),
  CONSTRAINT `transitline_ibfk_1` FOREIGN KEY (`origin`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `transitline_ibfk_2` FOREIGN KEY (`destination`) REFERENCES `Station` (`stationId`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `Customer` (`customerId`, `firstName`, `lastName`, `username`, `password`, `email`) VALUES
(1, 'John', 'Doe', 'user1', 'password1', 'john@aol.com'),
(2, 'Jane', 'Doe', 'user2', 'password2', 'jane@hotmail.com');

INSERT INTO `Employee` (`ssn`, `firstName`, `lastName`, `username`, `password`, `role`) VALUES
('111-11-1111', 'emp1Fname', 'emp1Lname', 'rep1', 'rep1', 'Representative'),
('222-22-2222', 'Mgr1Fname', 'Mgr1Lname', 'mgr1', 'mgr1', 'Manager');

INSERT INTO `Reservation` (`reservationNo`, `customerId`, `transitLineId`, `originStationId`, `destinationStationId`, `reservationDateTime`, `isRoundTrip`) VALUES
(5, 1, 1, 1, 16, '2024-11-15 14:30:00', 0),
(6, 2, 1, 5, 14, '2024-11-20 18:15:00', 1),
(7, 1, 1, 3, 12, '2024-01-05 10:00:00', 0),
(8, 2, 1, 7, 15, '2024-01-10 15:45:00', 1);

INSERT INTO `Station` (`stationId`, `name`, `city`, `state`) VALUES
(1, 'Trenton Transit Center', 'Trenton', 'NJ'),
(2, 'Hamilton', 'Hamilton', 'NJ'),
(3, 'Princeton Junction', 'Princeton', 'NJ'),
(4, 'Jersey Avenue', 'New Brunswick', 'NJ'),
(5, 'New Brunswick', 'New Brunswick', 'NJ'),
(6, 'Edison', 'Edison', 'NJ'),
(7, 'Metuchen', 'Metuchen', 'NJ'),
(8, 'Metropark', 'Iselin', 'NJ'),
(9, 'Rahway', 'Rahway', 'NJ'),
(10, 'Linden', 'Linden', 'NJ'),
(11, 'Elizabeth', 'Elizabeth', 'NJ'),
(12, 'North Elizabeth', 'Elizabeth', 'NJ'),
(13, 'Newark Int\'l Airport', 'Newark', 'NJ'),
(14, 'Newark Penn Station', 'Newark', 'NJ'),
(15, 'Secaucus Junction', 'Secaucus', 'NJ'),
(16, 'New York Penn Station', 'New York', 'NY');

INSERT INTO `Stop` (`stopId`, `stopStation`, `stopLine`, `departureDateTime`, `arrivalDateTime`) VALUES
(1, 1, 1, '2024-12-10 07:24:00', '2024-12-10 07:23:00'),
(2, 2, 1, '2024-12-10 07:30:00', '2024-12-10 07:29:00'),
(3, 3, 1, '2024-12-10 07:37:00', '2024-12-10 07:36:00'),
(4, 5, 1, '2024-12-10 07:55:00', '2024-12-10 07:54:00'),
(5, 6, 1, '2024-12-10 08:00:00', '2024-12-10 07:59:00'),
(6, 7, 1, '2024-12-10 08:05:00', '2024-12-10 08:04:00'),
(7, 8, 1, '2024-12-10 08:10:00', '2024-12-10 08:09:00'),
(8, 9, 1, '2024-12-10 08:19:00', '2024-12-10 08:18:00'),
(9, 10, 1, '2024-12-10 08:24:00', '2024-12-10 08:23:00'),
(10, 11, 1, '2024-12-10 08:33:00', '2024-12-10 08:32:00'),
(11, 12, 1, '2024-12-10 08:36:00', '2024-12-10 08:35:00'),
(12, 13, 1, '2024-12-10 08:39:00', '2024-12-10 08:38:00'),
(13, 14, 1, '2024-12-10 08:45:00', '2024-12-10 08:44:00'),
(14, 15, 1, '2024-12-10 08:54:00', '2024-12-10 08:53:00'),
(15, 16, 1, '2024-12-10 09:06:00', '2024-12-10 09:06:00');

INSERT INTO `TransitLine` (`lineId`, `lineName`, `origin`, `destination`, `departureDateTime`, `arrivalDateTime`, `fare`) VALUES
(1, 'NJ Northeast Corridor', 1, 16, '2024-12-10 07:23:00', '2024-12-10 09:06:00', 100);