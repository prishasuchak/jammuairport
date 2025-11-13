USE jammu_airport_db;

-- Book tickets
CALL sp_BookTicket(1, 1, 'Economy', 3500.00, @ticketID1, @bookingRef1, @message1);
SELECT @message1;

-- Check-in passenger
CALL sp_CheckInPassenger(@ticketID1, '12A', @boardingPassID1, @checkinMessage1);
SELECT @checkinMessage1;

-- Update baggage status
CALL sp_UpdateBaggageStatus('BAG001', 'In-Transit', 'Sorting Area', @baggageMsg);
SELECT @baggageMsg;

-- Log security check
INSERT INTO SecurityCheck (PassengerID, CheckpointName, SecurityPersonnelID, Status, Notes)
VALUES (1, 'Gate 1', 2, 'Cleared', 'No issues');

-- Insert payment
INSERT INTO Payment (TicketID, PaymentMethod, Amount, TransactionID, Status)
VALUES (@ticketID1, 'Credit Card', 3500.00, 'TXN001', 'Success');

-- Update flight status
CALL sp_UpdateFlightStatus('AI101', 'Boarding', @flightStatusMsg);
SELECT @flightStatusMsg;

-- Query views
SELECT * FROM v_FlightSchedule;
SELECT * FROM v_PassengerManifest;

-- Check audit log
SELECT * FROM AuditLog ORDER BY ChangeTime DESC LIMIT 10;
