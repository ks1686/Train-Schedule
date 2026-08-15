USE trains;

ALTER TABLE Employee
    MODIFY password VARCHAR(255) NOT NULL;

ALTER TABLE Customer
    MODIFY password VARCHAR(255) NOT NULL,
    ADD UNIQUE KEY uq_customer_email (email);

ALTER TABLE Answers
    ADD UNIQUE KEY uq_answers_question (questionId);

ALTER TABLE TransitLine
    MODIFY fare DECIMAL(10,2),
    ADD INDEX idx_transitline_name_depart (lineName, departureDateTime);

ALTER TABLE Stop
    ADD COLUMN stopSequence INT NOT NULL DEFAULT 0,
    DROP PRIMARY KEY,
    ADD PRIMARY KEY (stopId),
    ADD UNIQUE KEY uq_stop_line_station (stopLine, stopStation),
    ADD INDEX idx_stop_station_depart (stopStation, departureDateTime);

ALTER TABLE Reservation
    DROP FOREIGN KEY Reservation_ibfk_2,
    DROP FOREIGN KEY Reservation_ibfk_3,
    DROP FOREIGN KEY Reservation_ibfk_4;

ALTER TABLE Reservation
    MODIFY discount INT NOT NULL,
    MODIFY totalFare DECIMAL(10,2) NOT NULL,
    ADD INDEX idx_reservation_customer_line (customerId, transitLineId),
    ADD INDEX idx_reservation_datetime (reservationDateTime);

-- Existing totalFare is the one-way segment fare. Persist the charged amount.
UPDATE Reservation
SET totalFare = ROUND(totalFare * IF(isRoundTrip, 2, 1) * (1 - discount / 100), 2);

ALTER TABLE Reservation
    ADD CONSTRAINT fk_reservation_line
        FOREIGN KEY (transitLineId) REFERENCES TransitLine(lineId) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_reservation_origin
        FOREIGN KEY (originStopId) REFERENCES Stop(stopId) ON DELETE RESTRICT ON UPDATE CASCADE,
    ADD CONSTRAINT fk_reservation_destination
        FOREIGN KEY (destinationStopId) REFERENCES Stop(stopId) ON DELETE RESTRICT ON UPDATE CASCADE;
