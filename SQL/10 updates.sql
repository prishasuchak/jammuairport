-- Add username and password fields to Passenger table
ALTER TABLE Passenger
  ADD COLUMN Username VARCHAR(50) UNIQUE,
  ADD COLUMN Password VARCHAR(255);

-- Employee table must include username/password and role
ALTER TABLE Employee
  ADD COLUMN Username VARCHAR(50) UNIQUE,
  ADD COLUMN Password VARCHAR(255),
  MODIFY Role ENUM('Admin', 'Staff', 'Pilot', 'FlightAttendant', 'GroundStaff', 'SecurityPersonnel', 'Manager') NOT NULL;

-- For demo, add base price to flights
ALTER TABLE Flight
  ADD COLUMN BasePrice DECIMAL(10,2) DEFAULT 4000.00;

-- Passwords: use "admin123" for admin, "staff123" for staff (will be hashed in app)
INSERT INTO Employee (FirstName, LastName, ContactNumber, Email, Role, Salary, HireDate, Username, Password)
VALUES
  ('System', 'Administrator', '9000000000', 'admin@airport.com', 'Admin', 150000, CURDATE(), 'adminuser', ''),
  ('Sunil', 'Staffmember', '9111111111', 'staff@airport.com', 'Staff', 60000, CURDATE(), 'staffuser', '');

