INSERT INTO `Answers` (`answerId`, `questionId`, `employeeSSN`, `answerText`, `answerDate`) VALUES
(1, 1, '987-65-4321', 'Yes, students get 10% off.', '2024-12-08 02:20:25'),
(2, 2, '456-78-9012', 'Yes, small pets are allowed with a carrier.', '2024-12-08 02:20:25'),
(3, 3, '987-65-4321', 'You can reschedule up to 24 hours in advance.', '2024-12-08 02:20:25'),
(4, 4, '654-32-1098', 'We sanitize regularly and enforce mask-wearing.', '2024-12-08 02:20:25'),
(5, 5, '987-65-4321', 'Select the round-trip option during booking.', '2024-12-08 02:20:25');

INSERT INTO `Customer` (`customerId`, `firstName`, `lastName`, `username`, `password`, `email`) VALUES
(1, 'Alice', 'Green', 'aliceg', 'securepass1', 'alice@example.com'),
(2, 'Bob', 'White', 'bobw', 'securepass2', 'bob@example.com'),
(3, 'Charlie', 'Black', 'charlieb', 'securepass3', 'charlie@example.com'),
(4, 'Daisy', 'Brown', 'daisyb', 'securepass4', 'daisy@example.com'),
(5, 'Evan', 'Gray', 'evang', 'securepass5', 'evan@example.com');

INSERT INTO `Employee` (`ssn`, `firstName`, `lastName`, `username`, `password`, `role`) VALUES
('111-11-1111', 'employee', 'one', 'emp1', 'emp1', 'Representative'),
('123-45-6789', 'John', 'Doe', 'jdoe', 'password123', 'Manager'),
('222-22-2222', 'manager', 'one', 'mgr1', 'mgr1', 'Manager'),
('321-65-9874', 'Michael', 'Johnson', 'mjohnson', 'passwordabc', 'Manager'),
('456-78-9012', 'Emily', 'Brown', 'ebrown', 'password789', 'Representative'),
('654-32-1098', 'Sarah', 'Taylor', 'staylor', 'passwordxyz', 'Representative'),
('987-65-4321', 'Jane', 'Smith', 'jsmith', 'password456', 'Representative');

INSERT INTO `Manages` (`manager_ssn`, `representative_ssn`) VALUES
('123-45-6789', '111-11-1111'),
('123-45-6789', '987-65-4321'),
('222-22-2222', '456-78-9012'),
('321-65-9874', '654-32-1098');

INSERT INTO `Questions` (`questionId`, `customerId`, `questionText`, `questionDate`) VALUES
(1, 1, 'What are the available discounts?', '2024-12-08 02:19:27'),
(2, 2, 'Are pets allowed on trains?', '2024-12-08 02:19:27'),
(3, 3, 'Can I reschedule my reservation?', '2024-12-08 02:19:27'),
(4, 4, 'What are the COVID-19 precautions?', '2024-12-08 02:19:27'),
(5, 5, 'How can I book a round trip?', '2024-12-08 02:19:27');

INSERT INTO `Reservation` (`reservationNo`, `customerId`, `transitLineId`, `originStopId`, `destinationStopId`, `reservationDateTime`, `isRoundTrip`, `discount`) VALUES
(1, 1, 1, 1, 4, '2024-12-01 10:00:00', 1, 10),
(2, 2, 2, 3, 2, '2024-12-02 12:00:00', 0, 0),
(3, 3, 3, 4, 3, '2024-12-03 14:00:00', 0, 5),
(4, 4, 4, 5, 2, '2024-12-04 16:00:00', 1, 20),
(5, 5, 5, 1, 3, '2024-12-05 18:00:00', 1, 15);

INSERT INTO `RViews` (`reservationNo`, `ssn`) VALUES
(1, '987-65-4321'),
(2, '456-78-9012'),
(3, '654-32-1098'),
(4, '987-65-4321'),
(5, '456-78-9012');

INSERT INTO `Station` (`stationId`, `name`, `city`, `state`) VALUES
(1, 'Union Station', 'Los Angeles', 'CA'),
(2, 'Grand Central', 'New York', 'NY'),
(3, 'Union Station', 'Chicago', 'IL'),
(4, 'King Street Station', 'Seattle', 'WA'),
(5, 'Boston South Station', 'Boston', 'MA');

INSERT INTO `Stop` (`stopId`, `stopStation`, `stopLine`, `departureDateTime`, `arrivalDateTime`) VALUES
(1, 1, 1, '2024-12-10 08:00:00', NULL),
(2, 4, 1, NULL, '2024-12-10 20:00:00'),
(3, 3, 2, NULL, '2024-12-11 09:00:00'),
(4, 2, 2, NULL, '2024-12-11 18:00:00'),
(5, 3, 5, '2024-12-14 14:00:00', NULL);

INSERT INTO `SViews` (`ssn`, `stopId`, `stopStation`, `stopLine`) VALUES
('456-78-9012', 2, 4, 1),
('456-78-9012', 5, 3, 5),
('654-32-1098', 3, 3, 2),
('987-65-4321', 1, 1, 1),
('987-65-4321', 4, 2, 2);

INSERT INTO `Train` (`trainId`, `trainName`, `lineId`) VALUES
(1, 'Amtrak 101', 1),
(2, 'Amtrak 201', 2),
(3, 'Amtrak 301', 3),
(4, 'Amtrak 401', 4),
(5, 'Amtrak 501', 5);

INSERT INTO `TransitLine` (`lineId`, `lineName`, `origin`, `destination`, `departureDateTime`, `arrivalDateTime`, `fare`) VALUES
(1, 'Pacific Surfliner', 1, 4, '2024-12-10 08:00:00', '2024-12-10 20:00:00', 75.5),
(2, 'Lake Shore Limited', 3, 2, '2024-12-11 09:00:00', '2024-12-11 18:00:00', 100),
(3, 'Empire Builder', 4, 3, '2024-12-12 10:00:00', '2024-12-12 22:00:00', 150),
(4, 'Northeast Regional', 5, 2, '2024-12-13 06:00:00', '2024-12-13 12:00:00', 60),
(5, 'Southwest Chief', 1, 3, '2024-12-14 14:00:00', '2024-12-14 23:59:00', 120);