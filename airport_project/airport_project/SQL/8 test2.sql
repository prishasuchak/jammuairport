USE jammu_airport_db;

-- 1. Add a new passenger (not previously used)
INSERT INTO Passenger (FirstName, LastName, ContactNumber, Email, AadharNumber, DateOfBirth, Gender, Nationality)
VALUES ('Atharva', 'Mehra', '9550095500', 'atharva.mehra@test.com', '987654321777', '1998-02-20', 'Male', 'Indian');

-- 2. Add a new aircraft (if needed)
INSERT INTO Aircraft (AircraftType, RegistrationNumber, Manufacturer, Capacity, ManufactureDate, LastMaintenanceDate, Status, AirlineID)
VALUES ('Boeing 737-900', 'VT-ATV', 'Boeing', 200, '2020-11-11', '2025-09-01', 'Active', 1);

-- 3. Add a new flight route (with unique number and schedule)
INSERT INTO Flight (FlightNumber, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status, GateID, AirlineID, AircraftID)
VALUES ('AI777', 1, 3, '2025-10-25 08:00:00', '2025-10-25 11:00:00', 'Scheduled', 2, 1, LAST_INSERT_ID());

-- 4. Book a ticket for the new passenger on the new flight
-- Find new PassengerID (assumes autoincrement/last insert)
SET @newPassengerID = LAST_INSERT_ID();

-- Most recent FlightID:
SELECT FlightID INTO @newFlightID FROM Flight WHERE FlightNumber='AI777';

CALL sp_BookTicket(@newPassengerID, @newFlightID, 'Economy', 5400.00, @ticketID, @bookingRef, @bookingMsg);
SELECT @bookingMsg AS TicketBookingResult;

-- 5. Check-in new ticket with a new seat number
CALL sp_CheckInPassenger(@ticketID, '19F', @boardingPassID, @checkinMsg);
SELECT @checkinMsg AS PassengerCheckInResult;

-- 6. Register baggage with a new, unique tag number
INSERT INTO Baggage (TagNumber, Weight, Status, LastScanLocation, PassengerID, FlightID)
VALUES ('BAGX777', 16.5, 'Checked-In', 'Check-In Counter C2', @newPassengerID, @newFlightID);

-- 7. Update baggage status to demonstrate tracking
CALL sp_UpdateBaggageStatus('BAGX777', 'In-Transit', 'Security Conveyor', @baggageMsg);
SELECT @baggageMsg AS BaggageTrackingResult;

-- 8. Insert security check for this passenger
INSERT INTO SecurityCheck (PassengerID, CheckpointName, SecurityPersonnelID, Status, Notes)
VALUES (@newPassengerID, 'Gate 2 Security', 2, 'Cleared', 'Routine scan');

-- 9. Add a payment for this ticket
INSERT INTO Payment (TicketID, PaymentMethod, Amount, TransactionID, Status)
VALUES (@ticketID, 'Debit Card', 5400.00, 'TXNTEST777', 'Success');

-- 10. Query views to see the new passenger's journey reflected
SELECT * FROM v_PassengerManifest WHERE PassengerName LIKE '%Atharva%';
SELECT * FROM v_FlightSchedule WHERE FlightNumber='AI777';
SELECT * FROM v_GateAssignment;
SELECT * FROM v_AirportDashboard;
SELECT * FROM v_AirlinePerformance;

-- 11. See latest audit log entries!
SELECT * FROM AuditLog ORDER BY ChangeTime DESC LIMIT 10;

-- 12. Use functions for custom analysis
SELECT getPassengerAge('1998-02-20') AS AtharvaAge;
SELECT checkSeatAvailability(@newFlightID) AS SeatsRemaining;
SELECT calculateBaggageFee(16.5) AS ExcessBaggageFee;
