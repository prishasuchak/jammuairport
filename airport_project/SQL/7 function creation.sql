USE jammu_airport_db;

DELIMITER //

-- 1. Calculate Passenger Age
CREATE FUNCTION getPassengerAge(birthdate DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(YEAR, birthdate, CURDATE());
END //

-- 2. Calculate Flight Duration (in minutes)
CREATE FUNCTION getFlightDuration(depart DATETIME, arrive DATETIME)
RETURNS INT
DETERMINISTIC
BEGIN
    RETURN TIMESTAMPDIFF(MINUTE, depart, arrive);
END //

-- 3. Check Seat Availability for a Flight
CREATE FUNCTION checkSeatAvailability(flightID INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE capacity INT;
    DECLARE booked INT;
    SELECT a.Capacity INTO capacity
    FROM Flight f
        JOIN Aircraft a ON f.AircraftID = a.AircraftID
    WHERE f.FlightID = flightID;
    SELECT COUNT(*) INTO booked FROM Ticket WHERE FlightID = flightID AND Status != 'Cancelled';
    RETURN capacity - booked;
END //

-- 4. Calculate Baggage Fee for Excess Weight
-- (Assumes 15kg free, 500 rupees per extra kg)
CREATE FUNCTION calculateBaggageFee(weight DECIMAL(5,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    IF weight <= 15 THEN
        RETURN 0;
    ELSE
        RETURN (weight - 15) * 500;
    END IF;
END //

DELIMITER ;
