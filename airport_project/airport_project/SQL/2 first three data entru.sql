USE jammu_airport_db;

-- AIRLINES
INSERT INTO Airline (AirlineName, ContactNumber, HeadquarterLocation, IATA_Code, ICAO_Code) VALUES
('Air India', '1860-233-1407', 'New Delhi', 'AI', 'AIC'),
('IndiGo', '0124-617-8888', 'Gurgaon', '6E', 'IGO'),
('SpiceJet', '0987-180-3333', 'Gurgaon', 'SG', 'SEJ');

-- AIRPORTS
INSERT INTO Airport (AirportCode, AirportName, City, State, Country, IATA_Code, ICAO_Code) VALUES
('IXJ', 'Jammu Airport', 'Jammu', 'Jammu and Kashmir', 'India', 'IXJ', 'VIJU'),
('DEL', 'Indira Gandhi International Airport', 'New Delhi', 'Delhi', 'India', 'DEL', 'VIDP'),
('BOM', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'Maharashtra', 'India', 'BOM', 'VABB');

-- TERMINALS
INSERT INTO Terminal (TerminalName, Capacity, Facilities, Status) VALUES
('Terminal 1', 500, 'Food Court, Shops, Lounges', 'Operational'),
('Terminal 2', 300, 'VIP Lounge, Duty Free', 'Operational'),
('Terminal 3', 250, 'Cafeteria, Waiting Halls', 'Operational');

-- GATES
INSERT INTO Gate (GateNumber, TerminalID, Capacity, Status) VALUES
('1A', 1, 180, 'Available'),
('1B', 1, 180, 'Available'),
('1C', 1, 200, 'Available');

-- AIRCRAFT
INSERT INTO Aircraft (AircraftType, RegistrationNumber, Manufacturer, Capacity, ManufactureDate, LastMaintenanceDate, Status, AirlineID) VALUES
('Airbus A320', 'VT-KIR01', 'Airbus', 180, '2018-03-15', '2025-09-10', 'Active', 1),
('Boeing 737-800', 'VT-MAH02', 'Boeing', 189, '2017-11-10', '2025-09-05', 'Active', 2),
('ATR 72', 'VT-PRI03', 'ATR', 70, '2016-06-05', '2025-08-20', 'Active', 3);

-- PASSENGERS
INSERT INTO Passenger (FirstName, LastName, ContactNumber, Email, AadharNumber, DateOfBirth, Gender) VALUES
('Kiran', 'Sehrawat', '9123456780', 'kiran.sehrawat@email.com', '123456789012', '1990-05-15', 'Male'),
('Mahee', 'Agarwal', '9123456781', 'mahee.agarwal@email.com', '234567890123', '1988-08-22', 'Female'),
('Prisha', 'Suchak', '9123456782', 'prisha.suchak@email.com', '345678901234', '1992-11-30', 'Female');

-- EMPLOYEES
INSERT INTO Employee (FirstName, LastName, ContactNumber, Email, Role, Salary, HireDate, ShiftTimings) VALUES
('Kiran', 'Sehrawat', '9876543210', 'kiran.sehrawat@airport.com', 'Manager', 85000.00, '2015-06-01', 'Day Shift'),
('Mahee', 'Agarwal', '9876543211', 'mahee.agarwal@airport.com', 'GroundStaff', 35000.00, '2018-03-15', 'Morning Shift'),
('Prisha', 'Suchak', '9876543212', 'prisha.suchak@airport.com', 'SecurityPersonnel', 32000.00, '2019-07-20', 'Night Shift');

-- FLIGHTS
INSERT INTO Flight (FlightNumber, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status, GateID, AirlineID, AircraftID) VALUES
('AI101', 1, 2, '2025-10-22 06:00:00', '2025-10-22 08:00:00', 'Scheduled', 1, 1, 1),
('6E205', 1, 3, '2025-10-22 09:30:00', '2025-10-22 11:30:00', 'Scheduled', 2, 2, 2),
('SG303', 2, 1, '2025-10-22 12:00:00', '2025-10-22 14:00:00', 'Scheduled', 3, 3, 3);

-- TICKETS
INSERT INTO Ticket (BookingReference, PassengerID, FlightID, BookingDate, SeatNumber, FareClass, Price, Status) VALUES
('JMU000001', 1, 1, '2025-09-20 10:00:00', '12A', 'Economy', 3000.00, 'Confirmed'),
('JMU000002', 2, 2, '2025-09-21 11:30:00', '1B', 'Business', 7000.00, 'Confirmed'),
('JMU000003', 3, 3, '2025-09-22 09:45:00', '10C', 'Economy', 3000.00, 'Confirmed');

-- BAGGAGE
INSERT INTO Baggage (TagNumber, Weight, Status, LastScanLocation, PassengerID, FlightID) VALUES
('BAG10001', 18.5, 'Checked-In', 'Check-in Counter 1A', 1, 1),
('BAG10002', 21.0, 'Checked-In', 'Check-in Counter 1B', 2, 2),
('BAG10003', 15.0, 'Checked-In', 'Check-in Counter 3C', 3, 3);

-- CHECK-IN COUNTERS
INSERT INTO CheckInCounter (CounterNumber, TerminalID, Status, AirlineID) VALUES
('C1', 1, 'Open', 1),
('C2', 1, 'Open', 2),
('C3', 1, 'Closed', 3);

-- BOARDING PASS
INSERT INTO BoardingPass (TicketID, BoardingTime, GateNumber, SeatNumber, QRCode, Status) VALUES
(1, '2025-10-22 05:45:00', '1', '12A', 'QR001001', 'Issued'),
(2, '2025-10-22 09:15:00', '2', '1B', 'QR001002', 'Issued'),
(3, '2025-10-22 11:45:00', '3', '10C', 'QR001003', 'Issued');

-- SECURITY CHECK
INSERT INTO SecurityCheck (PassengerID, CheckpointName, CheckTime, SecurityPersonnelID, Status, Notes) VALUES
(1, 'Gate 1 Security', '2025-10-22 05:30:00', 3, 'Cleared', 'No issues'),
(2, 'Gate 2 Security', '2025-10-22 08:45:00', 1, 'Cleared', 'Routine check'),
(3, 'Gate 3 Security', '2025-10-22 11:00:00', 2, 'Flagged', 'Additional scan required');

-- PAYMENT
INSERT INTO Payment (TicketID, PaymentMethod, Amount, TransactionID, Status) VALUES
(1, 'Credit Card', 3000.00, 'TXN10001', 'Success'),
(2, 'UPI', 7000.00, 'TXN10002', 'Success'),
(3, 'Net Banking', 3000.00, 'TXN10003', 'Pending');

-- AUDIT LOG
INSERT INTO AuditLog (TableName, Operation, RecordID, OldValue, NewValue, ChangedBy) VALUES
('Ticket', 'INSERT', 1, NULL, 'Booking created for PassengerID 1', 'Kiran'),
('Ticket', 'INSERT', 2, NULL, 'Booking created for PassengerID 2', 'Mahee'),
('Ticket', 'INSERT', 3, NULL, 'Booking created for PassengerID 3', 'Prisha');
