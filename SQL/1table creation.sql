USE jammu_airport_db;

-- TABLE 1: AIRLINE
CREATE TABLE Airline (
    AirlineID INT AUTO_INCREMENT PRIMARY KEY,
    AirlineName VARCHAR(100) NOT NULL UNIQUE,
    ContactNumber VARCHAR(15),
    HeadquarterLocation VARCHAR(100),
    IATA_Code CHAR(2) NOT NULL UNIQUE,
    ICAO_Code CHAR(3) UNIQUE,
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- TABLE 2: AIRPORT
CREATE TABLE Airport (
    AirportID INT AUTO_INCREMENT PRIMARY KEY,
    AirportCode CHAR(3) NOT NULL UNIQUE,
    AirportName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL,
    State VARCHAR(50),
    Country VARCHAR(50) DEFAULT 'India',
    IATA_Code CHAR(3) NOT NULL UNIQUE,
    ICAO_Code CHAR(4) UNIQUE,
    INDEX idx_airport_code (AirportCode)
) ENGINE=InnoDB;

-- TABLE 3: PASSENGER
CREATE TABLE Passenger (
    PassengerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    AadharNumber CHAR(12) UNIQUE,
    PassportNumber VARCHAR(20) UNIQUE,
    DateOfBirth DATE,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL,
    Nationality VARCHAR(50) DEFAULT 'Indian',
    CreatedDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_passenger_contact (ContactNumber),
    INDEX idx_passenger_aadhar (AadharNumber)
) ENGINE=InnoDB;

-- TABLE 4: AIRCRAFT
CREATE TABLE Aircraft (
    AircraftID INT AUTO_INCREMENT PRIMARY KEY,
    AircraftType VARCHAR(50) NOT NULL,
    RegistrationNumber VARCHAR(20) NOT NULL UNIQUE,
    Manufacturer VARCHAR(50),
    Capacity INT NOT NULL CHECK (Capacity > 0),
    ManufactureDate DATE,
    LastMaintenanceDate DATE,
    Status ENUM('Active', 'Maintenance', 'Retired') DEFAULT 'Active',
    AirlineID INT,
    FOREIGN KEY (AirlineID) REFERENCES Airline(AirlineID) ON DELETE SET NULL,
    INDEX idx_aircraft_status (Status)
) ENGINE=InnoDB;

-- TABLE 5: TERMINAL
CREATE TABLE Terminal (
    TerminalID INT AUTO_INCREMENT PRIMARY KEY,
    TerminalName VARCHAR(20) NOT NULL UNIQUE,
    Capacity INT NOT NULL CHECK (Capacity > 0),
    Facilities TEXT,
    Status ENUM('Operational', 'Under Maintenance', 'Closed') DEFAULT 'Operational'
) ENGINE=InnoDB;

-- TABLE 6: GATE
CREATE TABLE Gate (
    GateID INT AUTO_INCREMENT PRIMARY KEY,
    GateNumber VARCHAR(10) NOT NULL,
    TerminalID INT NOT NULL,
    Capacity INT DEFAULT 200,
    Status ENUM('Available', 'Occupied', 'Maintenance') DEFAULT 'Available',
    FOREIGN KEY (TerminalID) REFERENCES Terminal(TerminalID) ON DELETE CASCADE,
    UNIQUE KEY unique_gate (GateNumber, TerminalID),
    INDEX idx_gate_status (Status)
) ENGINE=InnoDB;

-- TABLE 7: FLIGHT
CREATE TABLE Flight (
    FlightID INT AUTO_INCREMENT PRIMARY KEY,
    FlightNumber VARCHAR(10) NOT NULL,
    DepartureAirportID INT NOT NULL,
    ArrivalAirportID INT NOT NULL,
    DepartureTime DATETIME NOT NULL,
    ArrivalTime DATETIME NOT NULL,
    Status ENUM('Scheduled', 'Boarding', 'Departed', 'Arrived', 'Delayed', 'Cancelled') DEFAULT 'Scheduled',
    GateID INT,
    AirlineID INT NOT NULL,
    AircraftID INT,
    FOREIGN KEY (DepartureAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (ArrivalAirportID) REFERENCES Airport(AirportID),
    FOREIGN KEY (GateID) REFERENCES Gate(GateID) ON DELETE SET NULL,
    FOREIGN KEY (AirlineID) REFERENCES Airline(AirlineID) ON DELETE CASCADE,
    FOREIGN KEY (AircraftID) REFERENCES Aircraft(AircraftID) ON DELETE SET NULL,
    CHECK (DepartureAirportID != ArrivalAirportID),
    CHECK (DepartureTime < ArrivalTime),
    INDEX idx_flight_number (FlightNumber),
    INDEX idx_flight_departure (DepartureTime),
    INDEX idx_flight_status (Status)
) ENGINE=InnoDB;

-- TABLE 8: TICKET
CREATE TABLE Ticket (
    TicketID INT AUTO_INCREMENT PRIMARY KEY,
    BookingReference VARCHAR(10) NOT NULL UNIQUE,
    PassengerID INT NOT NULL,
    FlightID INT NOT NULL,
    BookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    SeatNumber VARCHAR(5),
    FareClass ENUM('Economy', 'Business', 'First') DEFAULT 'Economy',
    Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0),
    Status ENUM('Confirmed', 'Cancelled', 'Checked-In', 'Boarded') DEFAULT 'Confirmed',
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID) ON DELETE CASCADE,
    INDEX idx_ticket_booking (BookingReference),
    INDEX idx_ticket_status (Status)
) ENGINE=InnoDB;

-- TABLE 9: BAGGAGE
CREATE TABLE Baggage (
    BaggageID INT AUTO_INCREMENT PRIMARY KEY,
    TagNumber VARCHAR(20) NOT NULL UNIQUE,
    Weight DECIMAL(5, 2) NOT NULL CHECK (Weight > 0 AND Weight <= 50),
    Status ENUM('Checked-In', 'In-Transit', 'Loaded', 'Arrived', 'Claimed', 'Lost') DEFAULT 'Checked-In',
    LastScanTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastScanLocation VARCHAR(100),
    PassengerID INT NOT NULL,
    FlightID INT NOT NULL,
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
    FOREIGN KEY (FlightID) REFERENCES Flight(FlightID) ON DELETE CASCADE,
    INDEX idx_baggage_tag (TagNumber),
    INDEX idx_baggage_status (Status)
) ENGINE=InnoDB;

-- TABLE 10: EMPLOYEE
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    ContactNumber VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    Role ENUM('Pilot', 'FlightAttendant', 'GroundStaff', 'SecurityPersonnel', 'Manager') NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL CHECK (Salary > 0),
    HireDate DATE NOT NULL,
    ShiftTimings VARCHAR(50),
    INDEX idx_employee_role (Role)
) ENGINE=InnoDB;

-- TABLE 11: CHECK-IN COUNTER
CREATE TABLE CheckInCounter (
    CounterID INT AUTO_INCREMENT PRIMARY KEY,
    CounterNumber VARCHAR(10) NOT NULL,
    TerminalID INT NOT NULL,
    Status ENUM('Open', 'Closed') DEFAULT 'Closed',
    AirlineID INT,
    FOREIGN KEY (TerminalID) REFERENCES Terminal(TerminalID) ON DELETE CASCADE,
    FOREIGN KEY (AirlineID) REFERENCES Airline(AirlineID) ON DELETE SET NULL,
    UNIQUE KEY unique_counter (CounterNumber, TerminalID)
) ENGINE=InnoDB;

-- TABLE 12: BOARDING PASS
CREATE TABLE BoardingPass (
    BoardingPassID INT AUTO_INCREMENT PRIMARY KEY,
    TicketID INT NOT NULL UNIQUE,
    BoardingTime DATETIME,
    GateNumber VARCHAR(10),
    SeatNumber VARCHAR(5),
    QRCode VARCHAR(100) UNIQUE,
    Status ENUM('Issued', 'Boarded', 'Expired') DEFAULT 'Issued',
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE CASCADE
) ENGINE=InnoDB;

-- TABLE 13: SECURITY CHECK
CREATE TABLE SecurityCheck (
    CheckID INT AUTO_INCREMENT PRIMARY KEY,
    PassengerID INT NOT NULL,
    CheckpointName VARCHAR(50) NOT NULL,
    CheckTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    SecurityPersonnelID INT,
    Status ENUM('Cleared', 'Flagged', 'Denied') DEFAULT 'Cleared',
    Notes TEXT,
    FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE,
    FOREIGN KEY (SecurityPersonnelID) REFERENCES Employee(EmployeeID) ON DELETE SET NULL,
    INDEX idx_security_time (CheckTime)
) ENGINE=InnoDB;

-- TABLE 14: PAYMENT
CREATE TABLE Payment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    TicketID INT NOT NULL,
    PaymentMethod ENUM('Credit Card', 'Debit Card', 'UPI', 'Net Banking', 'Cash') NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL CHECK (Amount > 0),
    TransactionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    TransactionID VARCHAR(50) UNIQUE,
    Status ENUM('Success', 'Failed', 'Pending', 'Refunded') DEFAULT 'Success',
    FOREIGN KEY (TicketID) REFERENCES Ticket(TicketID) ON DELETE CASCADE,
    INDEX idx_payment_status (Status)
) ENGINE=InnoDB;

-- TABLE 15: AUDIT LOG
CREATE TABLE AuditLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    TableName VARCHAR(50) NOT NULL,
    Operation ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    RecordID INT NOT NULL,
    OldValue TEXT,
    NewValue TEXT,
    ChangedBy VARCHAR(50),
    ChangeTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_audit_table (TableName),
    INDEX idx_audit_time (ChangeTime)
) ENGINE=InnoDB;
