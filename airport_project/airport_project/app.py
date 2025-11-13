from flask import Flask, render_template, request, redirect, session, url_for, flash
import mysql.connector
from werkzeug.security import generate_password_hash, check_password_hash
from random import randint

app = Flask(__name__)
app.secret_key = "airport_secret_2025"

def get_db_connection():
    return mysql.connector.connect(
        host='localhost',
        user='root',
        password='Mahee@0411',
        database='jammu_airport_db'
    )

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    error = None
    if request.method == 'POST':
        data = request.form
        username = data['username']
        password = generate_password_hash(data['password'])
        firstname = data['firstname']
        lastname = data['lastname']
        contact = data['contact']
        email = data['email']
        aadhar = data['aadhar']
        passport = data['passport']
        dob = data['dob']
        gender = data['gender']
        nationality = data['nationality']
        conn = get_db_connection()
        cursor = conn.cursor()
        try:
            cursor.execute("""
                INSERT INTO Passenger (Username, Password, FirstName, LastName, ContactNumber, Email, AadharNumber, PassportNumber, DateOfBirth, Gender, Nationality)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
            """, (username, password, firstname, lastname, contact, email, aadhar, passport, dob, gender, nationality))
            conn.commit()
            flash("Sign up successful! Please log in.", "success")
            return redirect(url_for('login'))
        except mysql.connector.Error as e:
            error = "Username, Aadhar, or Contact may already exist. Error: " + str(e)
        finally:
            cursor.close()
            conn.close()
    return render_template('signup.html', error=error)

@app.route('/', methods=['GET', 'POST'])
@app.route('/login', methods=['GET', 'POST'])
def login():
    error = None
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        user_type = request.form['user_type']
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        if user_type == "passenger":
            cursor.execute("SELECT * FROM Passenger WHERE Username=%s", (username,))
            user = cursor.fetchone()
            if user and check_password_hash(user['Password'], password):
                session['role'] = 'passenger'
                session['passenger_id'] = user['PassengerID']
                session['username'] = username
                return redirect(url_for('passenger_dashboard'))
            else:
                error = "Invalid passenger credentials."
        elif user_type == "admin":
            cursor.execute("SELECT * FROM Employee WHERE Username=%s AND Role='Admin'", (username,))
            user = cursor.fetchone()
            if user and user['Password'] == password:
                session['role'] = 'admin'
                session['employee_id'] = user['EmployeeID']
                session['username'] = username
                return redirect(url_for('admin_dashboard'))
            else:
                error = "Invalid admin credentials."
        cursor.close()
        conn.close()
    return render_template('login.html', error=error)

@app.route('/passenger')
def passenger_dashboard():
    if session.get('role') != 'passenger':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    passenger_id = session['passenger_id']
    cursor.execute("""
        SELECT t.TicketID, t.BookingReference, t.FareClass, t.Price, t.Status, f.FlightNumber, f.DepartureTime, f.ArrivalTime
        FROM Ticket t
        JOIN Flight f ON t.FlightID = f.FlightID
        WHERE t.PassengerID = %s
        ORDER BY t.BookingDate DESC
    """, (passenger_id,))
    tickets = cursor.fetchall()
    # Show all flights where status is scheduled (dynamic from DB)
    cursor.execute("""
        SELECT f.FlightID, f.FlightNumber, a1.AirportName as Departure, a2.AirportName as Arrival, f.BasePrice
        FROM Flight f
        JOIN Airport a1 ON f.DepartureAirportID = a1.AirportID
        JOIN Airport a2 ON f.ArrivalAirportID = a2.AirportID
        WHERE f.Status='Scheduled'
    """)
    flights = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('passenger_dashboard.html', tickets=tickets, flights=flights)

@app.route('/passenger/book', methods=['POST'])
def passenger_book_ticket():
    if session.get('role') != 'passenger':
        return redirect(url_for('login'))
    flight_id = request.form['flight_id']
    fare_class = request.form['fare_class']
    passenger_id = session['passenger_id']
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT BasePrice FROM Flight WHERE FlightID=%s", (flight_id,))
    flight = cursor.fetchone()
    if not flight:
        cursor.close()
        conn.close()
        flash("Flight not found.", "danger")
        return redirect(url_for('passenger_dashboard'))
    base_price = flight['BasePrice']
    multiplier = 1.0 if fare_class=="Economy" else (1.7 if fare_class=="Business" else 2.5)
    price = int(float(base_price) * multiplier)

    booking_ref = 'JMU' + str(randint(100000, 999999))
    cursor.execute("""
        INSERT INTO Ticket (BookingReference, PassengerID, FlightID, FareClass, Price, Status)
        VALUES (%s,%s,%s,%s,%s,'Confirmed')
    """, (booking_ref, passenger_id, flight_id, fare_class, price))
    conn.commit()
    cursor.close()
    conn.close()
    flash("Booking successful!", "success")
    return redirect(url_for('passenger_dashboard'))

@app.route('/admin')
def admin_dashboard():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    return render_template('admin_dashboard.html')

@app.route('/admin/flights')
def manage_flights():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT f.*, a1.AirportName as Departure, a2.AirportName as Arrival
        FROM Flight f
        JOIN Airport a1 ON f.DepartureAirportID=a1.AirportID
        JOIN Airport a2 ON f.ArrivalAirportID=a2.AirportID
    """)
    flights = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('manage_flights.html', flights=flights)

@app.route('/admin/flights/add', methods=['GET','POST'])
def add_flight():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    if request.method == "POST":
        data = request.form
        cursor.execute("""
            INSERT INTO Flight (FlightNumber, DepartureAirportID, ArrivalAirportID, DepartureTime, ArrivalTime, Status, AirlineID, BasePrice)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (data['FlightNumber'],data['DepartureAirportID'],data['ArrivalAirportID'],data['DepartureTime'],data['ArrivalTime'],data['Status'],data['AirlineID'],data['BasePrice']))
        conn.commit()
        cursor.close()
        conn.close()
        flash("Flight added!", "success")
        return redirect(url_for('manage_flights'))
    cursor.execute("SELECT * FROM Airport")
    airports = cursor.fetchall()
    cursor.execute("SELECT * FROM Airline")
    airlines = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("add_flight.html", airports=airports, airlines=airlines)

@app.route('/admin/flights/delete/<int:flight_id>')
def delete_flight(flight_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Flight WHERE FlightID=%s", (flight_id,))
    conn.commit()
    cursor.close()
    conn.close()
    flash("Flight deleted.", "danger")
    return redirect(url_for('manage_flights'))

@app.route('/admin/flights/edit/<int:flight_id>', methods=['GET', 'POST'])
def edit_flight(flight_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if request.method == 'POST':
        data = request.form
        cursor.execute("""
            UPDATE Flight
            SET BasePrice=%s, Status=%s, DepartureTime=%s, ArrivalTime=%s
            WHERE FlightID=%s
        """, (
            data['BasePrice'],
            data['Status'],
            data['DepartureTime'],
            data['ArrivalTime'],
            flight_id
        ))
        conn.commit()
        cursor.close()
        conn.close()
        flash('Flight updated successfully!', 'success')
        return redirect(url_for('manage_flights'))

    # GET request: fetch existing flight data
    cursor.execute("SELECT * FROM Flight WHERE FlightID=%s", (flight_id,))
    flight = cursor.fetchone()
    cursor.close()
    conn.close()
    if flight is None:
        flash('Flight not found.', 'danger')
        return redirect(url_for('manage_flights'))
    return render_template('edit_flight.html', flight=flight)

@app.route('/admin/passengers')
def manage_passengers():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT PassengerID, Username, FirstName, LastName, ContactNumber, Email, AadharNumber, PassportNumber, DateOfBirth, Gender, Nationality
        FROM Passenger
        ORDER BY FirstName ASC
    """)
    passengers = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('manage_passengers.html', passengers=passengers)

@app.route('/admin/passengers/edit/<int:passenger_id>', methods=['GET', 'POST'])
def edit_passenger(passenger_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    if request.method == "POST":
        data = request.form
        cursor.execute("""
            UPDATE Passenger SET FirstName=%s, LastName=%s, ContactNumber=%s, Email=%s,
            AadharNumber=%s, PassportNumber=%s, DateOfBirth=%s, Gender=%s, Nationality=%s
            WHERE PassengerID=%s
        """, (
            data['FirstName'], data['LastName'], data['ContactNumber'], data['Email'],
            data['AadharNumber'], data['PassportNumber'], data['DateOfBirth'],
            data['Gender'], data['Nationality'], passenger_id
        ))
        conn.commit()
        cursor.close()
        conn.close()
        flash('Passenger updated successfully!', 'success')
        return redirect(url_for('manage_passengers'))
    cursor.execute("SELECT * FROM Passenger WHERE PassengerID=%s", (passenger_id,))
    passenger = cursor.fetchone()
    cursor.close()
    conn.close()
    if passenger is None:
        flash('Passenger not found.', 'danger')
        return redirect(url_for('manage_passengers'))
    return render_template('edit_passenger.html', passenger=passenger)

@app.route('/admin/passengers/delete/<int:passenger_id>')
def delete_passenger(passenger_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Passenger WHERE PassengerID=%s", (passenger_id,))
    conn.commit()
    cursor.close()
    conn.close()
    flash('Passenger deleted successfully.', 'danger')
    return redirect(url_for('manage_passengers'))



@app.route('/admin/employees')
def manage_employees():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT EmployeeID, Username, FirstName, LastName, ContactNumber, Email, Role, Salary, HireDate
        FROM Employee
        ORDER BY FirstName ASC
    """)
    employees = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('manage_employees.html', employees=employees)


@app.route('/admin/employees/delete/<int:employee_id>')
def delete_employee(employee_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Employee WHERE EmployeeID=%s", (employee_id,))
    conn.commit()
    cursor.close()
    conn.close()
    flash('Employee deleted successfully.', 'danger')
    return redirect(url_for('manage_employees'))

@app.route('/admin/employees/edit/<int:employee_id>', methods=['GET', 'POST'])
def edit_employee(employee_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if request.method == "POST":
        data = request.form
        cursor.execute("""
            UPDATE Employee SET FirstName=%s, LastName=%s, ContactNumber=%s, Email=%s,
            Role=%s, Salary=%s, HireDate=%s
            WHERE EmployeeID=%s
        """, (
            data['FirstName'], data['LastName'], data['ContactNumber'], data['Email'],
            data['Role'], data['Salary'], data['HireDate'], employee_id
        ))
        conn.commit()
        cursor.close()
        conn.close()
        flash('Employee updated successfully!', 'success')
        return redirect(url_for('manage_employees'))
    
    cursor.execute("SELECT * FROM Employee WHERE EmployeeID=%s", (employee_id,))
    employee = cursor.fetchone()
    cursor.close()
    conn.close()
    
    if employee is None:
        flash('Employee not found.', 'danger')
        return redirect(url_for('manage_employees'))
    
    return render_template('edit_employee.html', employee=employee)


@app.route('/admin/baggage')
def manage_baggage():
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("""
        SELECT b.BaggageID, p.FirstName, p.LastName, b.FlightID, b.Weight
        FROM Baggage b
        JOIN Passenger p ON b.PassengerID = p.PassengerID
        ORDER BY b.BaggageID DESC
    """)
    baggage_list = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('manage_baggage.html', baggage=baggage_list)

@app.route('/admin/baggage/delete/<int:baggage_id>')
def delete_baggage(baggage_id):
    if session.get('role') != 'admin':
        return redirect(url_for('login'))
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("DELETE FROM Baggage WHERE BaggageID=%s", (baggage_id,))
    conn.commit()
    cursor.close()
    conn.close()
    flash('Baggage entry deleted.', 'danger')
    return redirect(url_for('manage_baggage'))

@app.route('/admin/reports')
def reports():
    return render_template('reports.html')

@app.route('/admin/reports/flight-schedule')
def report_flight_schedule():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM v_FlightSchedule")
    flights = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("report_flight_schedule.html", flights=flights)

@app.route('/admin/reports/passenger-manifest')
def report_passenger_manifest():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM v_PassengerManifest")
    manifest = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("report_passenger_manifest.html", manifest=manifest)

@app.route('/admin/reports/gate-assignment')
def report_gate_assignment():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM v_GateAssignment")
    gates = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("report_gate_assignment.html", gates=gates)

@app.route('/admin/reports/dashboard')
def report_airport_dashboard():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM v_AirportDashboard")
    dashboard = cursor.fetchone()
    cursor.close()
    conn.close()
    return render_template("report_airport_dashboard.html", dashboard=dashboard)

@app.route('/admin/reports/airline-performance')
def report_airline_performance():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM v_AirlinePerformance")
    performance = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template("report_airline_performance.html", performance=performance)


@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('login'))

if __name__ == '__main__':
    app.run(debug=True, port=5001)
