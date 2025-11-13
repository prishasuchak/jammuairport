USE jammu_airport_db;

-- VIEW 1: Flight Schedule - real-time flight info
CREATE OR REPLACE VIEW v_FlightSchedule AS
SELECT 
    f.FlightNumber,
    a.AirlineName,
    dept.City AS DepartureCity,
    arr.City AS ArrivalCity,
    f.DepartureTime,
    f.ArrivalTime,
    f.Status,
    g.GateNumber,
    t.TerminalName,
    CONCAT(TIMESTAMPDIFF(HOUR, f.DepartureTime, f.ArrivalTime), 'h ', 
           MOD(TIMESTAMPDIFF(MINUTE, f.DepartureTime, f.ArrivalTime), 60), 'm') AS Duration
FROM Flight f
JOIN Airline a ON f.AirlineID = a.AirlineID
JOIN Airport dept ON f.DepartureAirportID = dept.AirportID
JOIN Airport arr ON f.ArrivalAirportID = arr.AirportID
LEFT JOIN Gate g ON f.GateID = g.GateID
LEFT JOIN Terminal t ON g.TerminalID = t.TerminalID
ORDER BY f.DepartureTime;

-- VIEW 2: Passenger Manifest - list of passengers per flight
CREATE OR REPLACE VIEW v_PassengerManifest AS
SELECT 
    f.FlightNumber,
    f.DepartureTime,
    CONCAT(p.FirstName, ' ', p.LastName) AS PassengerName,
    p.ContactNumber,
    t.SeatNumber,
    t.FareClass,
    t.Status AS TicketStatus,
    t.BookingReference,
    CASE 
        WHEN bp.Status = 'Boarded' THEN 'Boarded'
        WHEN bp.Status = 'Issued' THEN 'Checked-In'
        ELSE 'Not Checked-In'
    END AS BoardingStatus
FROM Ticket t
JOIN Passenger p ON t.PassengerID = p.PassengerID
JOIN Flight f ON t.FlightID = f.FlightID
LEFT JOIN BoardingPass bp ON t.TicketID = bp.TicketID
WHERE t.Status IN ('Confirmed', 'Checked-In', 'Boarded')
ORDER BY f.DepartureTime, t.SeatNumber;

-- VIEW 3: Gate Assignment - gate allocation status
CREATE OR REPLACE VIEW v_GateAssignment AS
SELECT 
    t.TerminalName,
    g.GateNumber,
    g.Status AS GateStatus,
    f.FlightNumber,
    a.AirlineName,
    f.DepartureTime,
    f.Status AS FlightStatus,
    ac.AircraftType
FROM Gate g
JOIN Terminal t ON g.TerminalID = t.TerminalID
LEFT JOIN Flight f ON g.GateID = f.GateID AND DATE(f.DepartureTime) = CURDATE()
LEFT JOIN Airline a ON f.AirlineID = a.AirlineID
LEFT JOIN Aircraft ac ON f.AircraftID = ac.AircraftID
ORDER BY t.TerminalName, g.GateNumber;

-- VIEW 4: Airport Operations Dashboard - KPIs summary
CREATE OR REPLACE VIEW v_AirportDashboard AS
SELECT 
    (SELECT COUNT(*) FROM Flight WHERE DATE(DepartureTime) = CURDATE()) AS TotalFlightsToday,
    (SELECT COUNT(*) FROM Flight WHERE DATE(DepartureTime) = CURDATE() AND Status = 'Departed') AS DepartedFlights,
    (SELECT COUNT(*) FROM Flight WHERE DATE(DepartureTime) = CURDATE() AND Status = 'Delayed') AS DelayedFlights,
    (SELECT COUNT(*) FROM Ticket WHERE DATE(BookingDate) = CURDATE()) AS BookingsToday,
    (SELECT COUNT(*) FROM Passenger) AS TotalPassengers,
    (SELECT COUNT(*) FROM Employee WHERE Role = 'GroundStaff') AS GroundStaffCount,
    (SELECT COUNT(*) FROM Gate WHERE Status = 'Available') AS AvailableGates;

-- VIEW 5: Airline Performance - Revenue and delay statistics
CREATE OR REPLACE VIEW v_AirlinePerformance AS
SELECT 
    a.AirlineName,
    COUNT(DISTINCT f.FlightID) AS TotalFlights,
    COUNT(DISTINCT t.TicketID) AS TotalBookings,
    SUM(t.Price) AS TotalRevenue,
    AVG(t.Price) AS AvgTicketPrice,
    SUM(CASE WHEN f.Status = 'Delayed' THEN 1 ELSE 0 END) AS DelayedFlights,
    ROUND((SUM(CASE WHEN f.Status = 'Delayed' THEN 1 ELSE 0 END) / COUNT(DISTINCT f.FlightID)) * 100, 2) AS DelayPercentage
FROM Airline a
LEFT JOIN Flight f ON a.AirlineID = f.AirlineID
LEFT JOIN Ticket t ON f.FlightID = t.FlightID AND t.Status != 'Cancelled'
GROUP BY a.AirlineID, a.AirlineName
ORDER BY TotalRevenue DESC;
