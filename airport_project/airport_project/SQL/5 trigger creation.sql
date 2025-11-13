USE jammu_airport_db;

DELIMITER //

-- 1. After Ticket Booking - Log booking
CREATE TRIGGER trg_AfterTicketBooking
AFTER INSERT ON Ticket
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, RecordID, NewValue, ChangedBy)
    VALUES ('Ticket', 'INSERT', NEW.TicketID, 
            CONCAT('Passenger: ', NEW.PassengerID, ', Flight: ', NEW.FlightID, ', Ref: ', NEW.BookingReference),
            USER());
END //

-- 2. Prevent Flight Deletion if passengers booked
CREATE TRIGGER trg_BeforeFlightDelete
BEFORE DELETE ON Flight
FOR EACH ROW
BEGIN
    DECLARE v_PassengerCount INT;
    SELECT COUNT(*) INTO v_PassengerCount
    FROM Ticket
    WHERE FlightID = OLD.FlightID AND Status IN ('Confirmed', 'Checked-In', 'Boarded');
    IF v_PassengerCount > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Cannot delete flight with confirmed passengers. Cancel bookings first.';
    END IF;
END //

-- 3. After Baggage Status Update - Log changes
CREATE TRIGGER trg_AfterBaggageUpdate
AFTER UPDATE ON Baggage
FOR EACH ROW
BEGIN
    IF OLD.Status != NEW.Status THEN
        INSERT INTO AuditLog (TableName, Operation, RecordID, OldValue, NewValue, ChangedBy)
        VALUES ('Baggage', 'UPDATE', NEW.BaggageID, 
                CONCAT('Status: ', OLD.Status, ', Location: ', OLD.LastScanLocation),
                CONCAT('Status: ', NEW.Status, ', Location: ', NEW.LastScanLocation),
                USER());
    END IF;
END //

-- 4. After Boarding Pass Update - Update Ticket Status
CREATE TRIGGER trg_AfterBoardingScan
AFTER UPDATE ON BoardingPass
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Issued' AND NEW.Status = 'Boarded' THEN
        UPDATE Ticket
        SET Status = 'Boarded'
        WHERE TicketID = NEW.TicketID;

        INSERT INTO AuditLog (TableName, Operation, RecordID, NewValue, ChangedBy)
        VALUES ('BoardingPass', 'UPDATE', NEW.BoardingPassID,
                CONCAT('Passenger boarded - Ticket: ', NEW.TicketID, ', Gate: ', NEW.GateNumber),
                USER());
    END IF;
END //

-- 5. After Payment Insert - Log Payment
CREATE TRIGGER trg_AfterPayment
AFTER INSERT ON Payment
FOR EACH ROW
BEGIN
    INSERT INTO AuditLog (TableName, Operation, RecordID, NewValue, ChangedBy)
    VALUES ('Payment', 'INSERT', NEW.PaymentID,
            CONCAT('Ticket: ', NEW.TicketID, ', Method: ', NEW.PaymentMethod, ', Amount: ', NEW.Amount, ', Status: ', NEW.Status),
            USER());
END //

DELIMITER ;
