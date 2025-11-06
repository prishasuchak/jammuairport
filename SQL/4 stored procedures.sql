USE jammu_airport_db;

DELIMITER //

-- 1. Book Ticket Procedure
CREATE PROCEDURE sp_BookTicket(
    IN p_PassengerID INT,
    IN p_FlightID INT,
    IN p_FareClass VARCHAR(20),
    IN p_Price DECIMAL(10,2),
    OUT p_TicketID INT,
    OUT p_BookingReference VARCHAR(10),
    OUT p_Message VARCHAR(200)
)
BEGIN
    DECLARE v_SeatCount INT;
    DECLARE v_Capacity INT;
    DECLARE v_BookingRef VARCHAR(10);
    DECLARE v_FlightNumber VARCHAR(10);

    SELECT COUNT(*) INTO v_SeatCount
    FROM Ticket
    WHERE FlightID = p_FlightID AND Status != 'Cancelled';

    SELECT a.Capacity INTO v_Capacity
    FROM Flight f
    JOIN Aircraft a ON f.AircraftID = a.AircraftID
    WHERE f.FlightID = p_FlightID;

    IF v_SeatCount >= v_Capacity THEN
        SET p_Message = 'ERROR: Flight is fully booked';
        SET p_TicketID = 0;
        SET p_BookingReference = NULL;
    ELSE
        SET v_BookingRef = CONCAT('JMU', LPAD(FLOOR(RAND() * 999999), 6, '0'));

        INSERT INTO Ticket (BookingReference, PassengerID, FlightID, FareClass, Price, Status)
        VALUES (v_BookingRef, p_PassengerID, p_FlightID, p_FareClass, p_Price, 'Confirmed');

        SET p_TicketID = LAST_INSERT_ID();
        SET p_BookingReference = v_BookingRef;

        SELECT FlightNumber INTO v_FlightNumber FROM Flight WHERE FlightID = p_FlightID;
        SET p_Message = CONCAT('SUCCESS: Booking confirmed! Flight: ', v_FlightNumber, ', Reference: ', v_BookingRef);
    END IF;
END //

-- 2. Check-in Passenger Procedure
CREATE PROCEDURE sp_CheckInPassenger(
    IN p_TicketID INT,
    IN p_SeatNumber VARCHAR(5),
    OUT p_BoardingPassID INT,
    OUT p_Message VARCHAR(200)
)
BEGIN
    DECLARE v_FlightID INT;
    DECLARE v_GateNumber VARCHAR(10);
    DECLARE v_DepartureTime DATETIME;
    DECLARE v_QRCode VARCHAR(100);
    DECLARE v_TicketStatus VARCHAR(20);
    DECLARE v_FlightNumber VARCHAR(10);

    SELECT t.FlightID, g.GateNumber, f.DepartureTime, f.FlightNumber, t.Status
    INTO v_FlightID, v_GateNumber, v_DepartureTime, v_FlightNumber, v_TicketStatus
    FROM Ticket t
    JOIN Flight f ON t.FlightID = f.FlightID
    LEFT JOIN Gate g ON f.GateID = g.GateID
    WHERE t.TicketID = p_TicketID;

    IF v_TicketStatus = 'Checked-In' OR v_TicketStatus = 'Boarded' THEN
        SET p_Message = 'ERROR: Passenger already checked in';
        SET p_BoardingPassID = 0;
    ELSEIF v_DepartureTime < NOW() THEN
        SET p_Message = 'ERROR: Flight has already departed';
        SET p_BoardingPassID = 0;
    ELSE
        UPDATE Ticket
        SET Status = 'Checked-In', SeatNumber = p_SeatNumber
        WHERE TicketID = p_TicketID;

        SET v_QRCode = MD5(CONCAT(p_TicketID, NOW()));

        INSERT INTO BoardingPass (TicketID, GateNumber, SeatNumber, QRCode, Status)
        VALUES (p_TicketID, v_GateNumber, p_SeatNumber, v_QRCode, 'Issued');

        SET p_BoardingPassID = LAST_INSERT_ID();
        SET p_Message = CONCAT('SUCCESS: Check-in complete! Flight: ', v_FlightNumber, ', Seat: ', p_SeatNumber, ', Gate: ', v_GateNumber);
    END IF;
END //

-- 3. Update Baggage Status Procedure
CREATE PROCEDURE sp_UpdateBaggageStatus(
    IN p_TagNumber VARCHAR(20),
    IN p_NewStatus VARCHAR(20),
    IN p_ScanLocation VARCHAR(100),
    OUT p_Message VARCHAR(200)
)
BEGIN
    DECLARE v_BaggageExists INT;

    SELECT COUNT(*) INTO v_BaggageExists
    FROM Baggage
    WHERE TagNumber = p_TagNumber;

    IF v_BaggageExists = 0 THEN
        SET p_Message = CONCAT('ERROR: Baggage tag ', p_TagNumber, ' not found');
    ELSE
        UPDATE Baggage
        SET Status = p_NewStatus,
            LastScanTime = NOW(),
            LastScanLocation = p_ScanLocation
        WHERE TagNumber = p_TagNumber;

        SET p_Message = CONCAT('SUCCESS: Baggage ', p_TagNumber, ' updated to ', p_NewStatus, ' at ', p_ScanLocation);
    END IF;
END //

-- 4. Update Flight Status Procedure
CREATE PROCEDURE sp_UpdateFlightStatus(
    IN p_FlightNumber VARCHAR(10),
    IN p_NewStatus VARCHAR(20),
    OUT p_Message VARCHAR(200)
)
BEGIN
    DECLARE v_FlightExists INT;
    DECLARE v_PassengerCount INT;

    SELECT COUNT(*) INTO v_FlightExists
    FROM Flight
    WHERE FlightNumber = p_FlightNumber;

    IF v_FlightExists = 0 THEN
        SET p_Message = CONCAT('ERROR: Flight ', p_FlightNumber, ' not found');
    ELSE
        UPDATE Flight
        SET Status = p_NewStatus
        WHERE FlightNumber = p_FlightNumber;

        SELECT COUNT(*) INTO v_PassengerCount
        FROM Ticket t
        JOIN Flight f ON t.FlightID = f.FlightID
        WHERE f.FlightNumber = p_FlightNumber AND t.Status != 'Cancelled';

        SET p_Message = CONCAT('SUCCESS: Flight ', p_FlightNumber, ' status updated to ', p_NewStatus, '. Affected passengers: ', v_PassengerCount);
    END IF;
END //

-- 5. Generate Daily Report Procedure
CREATE PROCEDURE sp_GenerateDailyReport(
    IN p_ReportDate DATE
)
BEGIN
    SELECT
        'DAILY AIRPORT OPERATIONS REPORT' AS ReportTitle,
        p_ReportDate AS ReportDate;

    -- Flights Summary
    SELECT
        'FLIGHTS SUMMARY' AS Section,
        COUNT(*) AS TotalFlights,
        SUM(CASE WHEN Status = 'Departed' THEN 1 ELSE 0 END) AS DepartedFlights,
        SUM(CASE WHEN Status = 'Arrived' THEN 1 ELSE 0 END) AS ArrivedFlights,
        SUM(CASE WHEN Status = 'Delayed' THEN 1 ELSE 0 END) AS DelayedFlights,
        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledFlights
    FROM Flight
    WHERE DATE(DepartureTime) = p_ReportDate;

    -- Bookings Summary
    SELECT
        'BOOKINGS SUMMARY' AS Section,
        COUNT(*) AS TotalBookings,
        SUM(Price) AS TotalRevenue,
        AVG(Price) AS AvgTicketPrice,
        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancellations
    FROM Ticket
    WHERE DATE(BookingDate) = p_ReportDate;

    -- Airline Performance
    SELECT
        'AIRLINE PERFORMANCE' AS Section,
        a.AirlineName,sp_BookTicket
        COUNT(DISTINCT f.FlightID) AS Flights,
        COUNT(DISTINCT t.TicketID) AS Bookings,
        SUM(t.Price) AS Revenue
    FROM Airline a
    LEFT JOIN Flight f ON a.AirlineID = f.AirlineID AND DATE(f.DepartureTime) = p_ReportDate
    LEFT JOIN Ticket t ON f.FlightID = t.FlightID AND t.Status != 'Cancelled'
    GROUP BY a.AirlineID, a.AirlineName
    ORDER BY Revenue DESC;
END //

DELIMITER ;
