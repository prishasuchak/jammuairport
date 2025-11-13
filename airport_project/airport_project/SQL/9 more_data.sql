USE jammu_airport_db;

-- Airlines
INSERT INTO Airline (AirlineName, ContactNumber, HeadquarterLocation, IATA_Code, ICAO_Code) VALUES
('Jet Airways', '022-12345678', 'Mumbai', '9W', 'JAI'),
('AirAsia India', '080-23456789', 'Bengaluru', 'I5', 'IAA'),
('Alliance Air', '011-34567890', 'Delhi', '9I', 'AIW');

-- Airports
INSERT INTO Airport (AirportCode, AirportName, City, State, Country, IATA_Code, ICAO_Code) VALUES
('CCU', 'Netaji Subhash Chandra Bose International Airport', 'Kolkata', 'West Bengal', 'India', 'CCU', 'VECC'),
('HYD', 'Rajiv Gandhi International Airport', 'Hyderabad', 'Telangana', 'India', 'HYD', 'VOHS'),
('PNQ', 'Pune Airport', 'Pune', 'Maharashtra', 'India', 'PNQ', 'VAPO');

-- Passengers
INSERT INTO Passenger (FirstName, LastName, ContactNumber, Email, AadharNumber, PassportNumber, DateOfBirth, Gender, Nationality) VALUES
('Harsh', 'Kapoor', '9876543210', 'harsh.kapoor@example.com', '555566667777', 'P7654321', '1987-05-15', 'Male', 'Indian'),
('Sonal', 'Mehta', '9876543211', 'sonal.mehta@example.com', '555566668888', 'P7654322', '1992-03-25', 'Female', 'Indian'),
('Devansh', 'Malhotra', '9876543212', 'devansh.malhotra@example.com', '555566669999', 'P7654323', '1980-10-05', 'Male', 'Indian'),
('Nisha', 'Gupta', '9876543213', 'nisha.gupta@example.com', '555566660000', 'P7654324', '1995-08-12', 'Female', 'Indian'),
('Reyansh', 'Sharma', '9876543214', 'reyansh.sharma@example.com', '555566661111', 'P7654325', '1999-01-30', 'Male', 'Indian');

-- Aircrafts
INSERT INTO Aircraft (AircraftType, RegistrationNumber, Manufacturer, Capacity, ManufactureDate, LastMaintenanceDate, Status, AirlineID) VALUES
('Boeing 777', 'VT-JW1', 'Boeing', 300, '2012-04-12', '2025-07-10', 'Active', 1),
('Airbus A320', 'VT-AA1', 'Airbus', 180, '2015-08-19', '2025-06-20', 'Active', 2),
('Bombardier Dash 8', 'VT-AL1', 'Bombardier', 70, '2017-12-01', '2025-05-02', 'Active', 3);

-- Terminals
INSERT INTO Terminal (TerminalName, Capacity, Facilities, Status) VALUES
('Terminal A', 3500, 'Shops, Lounges, Restaurants', 'Operational'),
('Terminal B', 2500, 'WiFi, Restrooms, Lounge', 'Operational'),
('Terminal C', 1500, 'VIP Lounge, Transit Hotel', 'Under Maintenance');

-- Gates
INSERT INTO Gate (GateNumber, TerminalID, Capacity, Status) VALUES
('A1', 1, 250, 'Available'),
('A2', 1, 250, 'Occupied'),
('B1', 2, 200, 'Available'),
('B2', 2, 200, 'Maintenance'),
('C1', 3, 150, 'Closed');

-- Flights
INSERT INTO Flight (FlightNumber, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status, GateID, AirlineID, AircraftID) VALUES
('9W253', 1, 2, '2025-12-01 06:00:00', '2025-12-01 07:30:00', 'Scheduled', 1, 1, 1),
('I5270', 2, 3, '2025-12-01 09:45:00', '2025-12-01 11:15:00', 'Delayed', 3, 2, 2),
('9I702', 3, 1, '2025-12-01 14:00:00', '2025-12-01 15:30:00', 'Boarding', 5, 3, 3);

-- Tickets
INSERT INTO Ticket (BookingReference, PassengerID, FlightID, BookingDate, SeatNumber, FareClass, Price, Status) VALUES
('JMU900001', 1, 1, '2025-11-20 09:00:00', '14A', 'Business', 12000.00, 'Confirmed'),
('JMU900002', 2, 1, '2025-11-21 08:30:00', '14B', 'Economy', 6000.00, 'Cancelled'),
('JMU900003', 3, 2, '2025-11-22 10:15:00', '10C', 'Economy', 6500.00, 'Confirmed'),
('JMU900004', 4, 3, '2025-11-23 11:45:00', '1A', 'First', 15000.00, 'Checked-In'),
('JMU900005', 5, 3, '2025-11-24 12:30:00', '1B', 'Business', 12500.00, 'Boarded');

-- Baggage
INSERT INTO Baggage (TagNumber, Weight, Status, LastScanLocation, PassengerID, FlightID) VALUES
('TAG900001', 25.0, 'Checked-In', 'Counter 5', 1, 1),
('TAG900002', 19.5, 'In-Transit', 'Sorting Zone', 3, 2),
('TAG900003', 30.0, 'Loaded', 'Aircraft Hold', 4, 3),
('TAG900004', 16.0, 'Claimed', 'Baggage Claim', 5, 3);

-- Employees
INSERT INTO Employee (FirstName, LastName, ContactNumber, Email, Role, Salary, HireDate, ShiftTimings) VALUES
('Aakash', 'Verma', '9123400000', 'aakash.verma@example.com', 'Pilot', 95000.00, '2012-06-15', 'Morning'),
('Diya', 'Chopra', '9123400001', 'diya.chopra@example.com', 'FlightAttendant', 48000.00, '2015-08-22', 'Evening'),
('Karan', 'Singh', '9123400002', 'karan.singh@example.com', 'GroundStaff', 35000.00, '2018-03-10', 'Night'),
('Leena', 'Patel', '9123400003', 'leena.patel@example.com', 'SecurityPersonnel', 40000.00, '2019-01-25', 'Morning');

-- CheckIn Counters
INSERT INTO CheckInCounter (CounterNumber, TerminalID, Status, AirlineID) VALUES
('C11', 1, 'Open', 1),
('C12', 2, 'Closed', 2),
('C13', 1, 'Open', 3);

-- Boarding Passes
INSERT INTO BoardingPass (TicketID, BoardingTime, GateNumber, SeatNumber, QRCode, Status) VALUES
((SELECT TicketID FROM Ticket WHERE BookingReference='JMU900001'), '2025-12-01 05:30:00', 'A1', '14A', 'QR900001', 'Issued'),
((SELECT TicketID FROM Ticket WHERE BookingReference='JMU900004'), '2025-12-01 13:30:00', 'C1', '1A', 'QR900002', 'Boarded');

-- Security Checks
INSERT INTO SecurityCheck (PassengerID, CheckpointName, SecurityPersonnelID, Status, Notes) VALUES
(1, 'Gate A Security', 4, 'Cleared', 'No issues'),
(4, 'Gate C Security', 4, 'Flagged', 'Additional scanning required');

-- Payments
INSERT INTO Payment (TicketID, PaymentMethod, Amount, TransactionID, Status) VALUES
((SELECT TicketID FROM Ticket WHERE BookingReference='JMU900001'), 'Credit Card', 12000.00, 'TXN900001', 'Success'),
((SELECT TicketID FROM Ticket WHERE BookingReference='JMU900004'), 'UPI', 15000.00, 'TXN900002', 'Success'),
((SELECT TicketID FROM Ticket WHERE BookingReference='JMU900005'), 'Debit Card', 12500.00, 'TXN900003', 'Failed');
