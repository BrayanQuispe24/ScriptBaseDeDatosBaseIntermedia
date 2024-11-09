use master;
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Airport_tickets')
BEGIN 
    PRINT 'La base de datos ya existe, la eliminamos y la volvemos a crear';
	DROP DATABASE Airport_tickets;
	CREATE DATABASE Airport_tickets;
	PRINT 'Creación exitosa'
END 
ELSE 
BEGIN
    PRINT 'La base de datos no existe, Procediendo a crearla';
    CREATE DATABASE Airport_tickets;
	PRINT 'Creación exitosa'
END;
GO

USE Airport_tickets;
GO

BEGIN TRANSACTION;
BEGIN TRY
 IF OBJECT_ID('Time') IS NULL
 BEGIN 
     CREATE TABLE Time(
       date DATE PRIMARY KEY NOT NULL,
       day INT NOT NULL,
       month INT NOT NULL,
       year INT NOT NULL,
       quarter VARCHAR(2) NOT NULL,
       weekday VARCHAR(10) NOT NULL,
       month_name VARCHAR(10) NOT NULL
); 
 END ;

IF OBJECT_ID('Customer_Type') IS NULL
BEGIN
    CREATE TABLE Customer_Type(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_type NVARCHAR(100),
        NIT INT,
        CHECK(NIT > 0), 
        CHECK(LEN(name_type) > 0),
        CONSTRAINT CK_NIT_Customer_Type CHECK(NIT >= 1000000) 
    );
END

IF OBJECT_ID('Customer') IS NULL
BEGIN
    CREATE TABLE Customer(
        id INT IDENTITY(1,1) PRIMARY KEY,
        first_name NVARCHAR(100),
        last_name NVARCHAR(100),
        phone_number NVARCHAR(20),
        email NVARCHAR(100),
		nationality NVARCHAR(100),
        customer_type_id INT,
        CHECK(LEN(first_name) > 0),
        CHECK(LEN(last_name) > 0),
        CHECK(LEN(phone_number) >= 8),
        CHECK(email LIKE '%_@__%.__%'), 
        FOREIGN KEY(customer_type_id) REFERENCES Customer_Type(id)
    );
    
    IF NOT EXISTS(SELECT * FROM sys.indexes WHERE name = 'idx_customer_type_id' AND object_id = OBJECT_ID('Customer'))
    BEGIN
        CREATE INDEX idx_customer_type_id ON Customer(customer_type_id);
    END
END



IF OBJECT_ID('Types_of_Luggages') IS NULL
BEGIN
    CREATE TABLE Types_of_Luggages(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_type NVARCHAR(100),
        description NVARCHAR(255),
        tariff INT,
        CHECK(tariff >= 0),
        CHECK(LEN(name_type) > 0), 
        CONSTRAINT CK_tariff_positive CHECK(tariff >= 0) 
    );
END

IF OBJECT_ID('Status_Ticket') IS NULL
BEGIN
    CREATE TABLE Status_Ticket(
        id INT IDENTITY(1,1) PRIMARY KEY,
        status_name NVARCHAR(100),
        CHECK(LEN(status_name) > 0), 
        CONSTRAINT CK_status_name CHECK(LEN(status_name) >= 3) 
    );
END

IF OBJECT_ID('Type_Flight') IS NULL
BEGIN
    CREATE TABLE Type_Flight(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_type NVARCHAR(100),
        CHECK(LEN(name_type) > 0), 
        CONSTRAINT CK_name_type_Type_Flight CHECK(LEN(name_type) >= 3) 
    );
END

IF OBJECT_ID('Status_Flight') IS NULL
BEGIN
    CREATE TABLE Status_Flight(
        id INT IDENTITY(1,1) PRIMARY KEY,
        status_name NVARCHAR(100),
        CHECK(LEN(status_name) > 0), 
        CONSTRAINT CK_status_name_Status_Flight CHECK(LEN(status_name) >= 3) 
    );
END

IF OBJECT_ID('Compensation_Detail') IS NULL
BEGIN
    CREATE TABLE Compensation_Detail(
        id INT IDENTITY(1,1) PRIMARY KEY,
        compensation_type NVARCHAR(100),
        compensation_amount DECIMAL(10, 2),
        issue_by INT,
        issue_date DATE,
        expiration_date DATE,
        CHECK(compensation_amount >= 0), 
        CHECK(issue_by > 0),
        CHECK(LEN(compensation_type) > 0), 
        CHECK(issue_date <= GETDATE()), 
        CHECK(expiration_date >= issue_date), 
        CONSTRAINT CK_compensation_amount_positive CHECK(compensation_amount >= 0)
    );
END

IF OBJECT_ID('Gate_Status') IS NULL
BEGIN
    CREATE TABLE Gate_Status(
        id INT IDENTITY(1,1) PRIMARY KEY,
        status_name NVARCHAR(100),
        CHECK(LEN(status_name) > 0), 
        CONSTRAINT CK_status_name_Gate_Status CHECK(LEN(status_name) >= 3) 
    );
END

IF OBJECT_ID('Currency') IS NULL
BEGIN
    CREATE TABLE Currency(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(50),
        exchange_rate DECIMAL(10, 4),
        CHECK(exchange_rate > 0), 
        CHECK(LEN(name) > 0), 
        CONSTRAINT CK_exchange_rate_positive CHECK(exchange_rate > 0) 
    );
END

IF OBJECT_ID('Booking_Status') IS NULL
BEGIN
    CREATE TABLE Booking_Status(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_status NVARCHAR(100),
        CHECK(LEN(name_status) > 0), 
        CONSTRAINT CK_name_status_Booking_Status CHECK(LEN(name_status) >= 3) 
    );
END

IF OBJECT_ID('Ticket_Category') IS NULL
BEGIN
    CREATE TABLE Ticket_Category (
        id INT IDENTITY(1,1) PRIMARY KEY,
        category_name NVARCHAR(100),
        CHECK(LEN(category_name) > 0), 
        CONSTRAINT CK_category_name_Ticket_Category CHECK(LEN(category_name) >= 3) 
    );
END

IF OBJECT_ID('Penalty_Cancellation') IS NULL
BEGIN
    CREATE TABLE Penalty_Cancellation (
        id INT IDENTITY(1,1) PRIMARY KEY,
        cancellation_type NVARCHAR(100),
        amount INT,
        CHECK(LEN(cancellation_type) > 0), 
        CHECK(amount >= 0),
        CONSTRAINT CK_cancellation_type_Penalty_Cancellation CHECK(LEN(cancellation_type) >= 3) 
    );
END

IF OBJECT_ID('Category') IS NULL
BEGIN
    CREATE TABLE Category (
        id INT IDENTITY(1,1) PRIMARY KEY,
        category_name NVARCHAR(100),
        description_category NVARCHAR(255),
        CHECK(LEN(category_name) > 0), 
        CHECK(LEN(description_category) > 0),
        CONSTRAINT CK_category_name_Category CHECK(LEN(category_name) >= 3), 
        CONSTRAINT CK_description_category_Category CHECK(LEN(description_category) >= 10)
    );
END

IF OBJECT_ID('Payment_Status') IS NULL
BEGIN
    CREATE TABLE Payment_Status (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_status NVARCHAR(100),
        CHECK(LEN(name_status) > 0),
        CONSTRAINT CK_name_status_Payment_Status CHECK(LEN(name_status) >= 3) 
    );
END

IF OBJECT_ID('Rol_Tripulante') IS NULL
BEGIN
    CREATE TABLE Rol_Tripulante (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_rol NVARCHAR(100),
        CHECK(LEN(name_rol) > 0),
        CONSTRAINT CK_name_rol_Rol_Tripulante CHECK(LEN(name_rol) >= 3) 
    );
END

IF OBJECT_ID('Type_Document') IS NULL
BEGIN
    CREATE TABLE Type_Document (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_document NVARCHAR(100),
        CHECK(LEN(name_document) > 0), 
        CONSTRAINT CK_name_document_Type_Document CHECK(LEN(name_document) >= 3) 
    );
END

IF OBJECT_ID('Category_Assignment') IS NULL
BEGIN
    CREATE TABLE Category_Assignment (
        id INT IDENTITY(1,1) PRIMARY KEY,
        assignment_date DATE,
		status VARCHAR(100),
        category_id INT,
        customer_id INT,
        FOREIGN KEY (category_id) REFERENCES Category(id),
        FOREIGN KEY (customer_id) REFERENCES Customer(id),
        CHECK(assignment_date <= GETDATE()), 
        CONSTRAINT CK_category_id_Category_Assignment CHECK(category_id > 0), 
        CONSTRAINT CK_customer_id_Category_Assignment CHECK(customer_id > 0) 
    );
END

IF OBJECT_ID('Frequent_Flyer_Card') IS NULL
BEGIN
    CREATE TABLE Frequent_Flyer_Card (
        id INT IDENTITY(1,1) PRIMARY KEY,
        milles INT,
        Meal_code INT,
        customer_id INT,
        FOREIGN KEY (customer_id) REFERENCES Customer(id),
        CHECK(milles >= 0), 
        CHECK(Meal_code >= 0), 
        CONSTRAINT CK_customer_id_Frequent_Flyer_Card CHECK(customer_id > 0) 
    );
END

IF OBJECT_ID('Gate_Assignment_Status') IS NULL
BEGIN
    CREATE TABLE Gate_Assignment_Status (
        id INT IDENTITY(1,1) PRIMARY KEY,
        date_Assignment DATE,
        Gate_Status_id INT,
        FOREIGN KEY (Gate_Status_id) REFERENCES Gate_Status(id),
        CHECK(date_Assignment <= GETDATE()), 
        CONSTRAINT CK_Gate_Status_id_Gate_Assignment_Status CHECK(Gate_Status_id > 0) 
    );
END

IF OBJECT_ID('Airline') IS NULL
BEGIN
    CREATE TABLE Airline (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100),
        email NVARCHAR(100),
        code_iata INT,
        CHECK(LEN(name) > 0), 
        CHECK(code_iata > 0), 
        CHECK(email LIKE '%_@__%.__%')
    );
END

IF OBJECT_ID('Country') IS NULL
BEGIN
    CREATE TABLE Country (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100),
        CONSTRAINT CK_name_Country CHECK(LEN(name) > 0) 
    );
END

IF OBJECT_ID('City') IS NULL
BEGIN
    CREATE TABLE City (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100),
        country_id INT,
        FOREIGN KEY (country_id) REFERENCES Country(id),
        CONSTRAINT CK_country_id_City CHECK(country_id > 0), 
        CONSTRAINT CK_name_City CHECK(LEN(name) > 0) 
    );
END

IF OBJECT_ID('Airport') IS NULL
BEGIN
    CREATE TABLE Airport (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_airport NVARCHAR(100),
        city_id INT,
        FOREIGN KEY (city_id) REFERENCES City(id),
        CHECK(LEN(name_airport) > 0), 
        CONSTRAINT CK_city_id_Airport CHECK(city_id > 0),
        CONSTRAINT CK_name_airport_Airport CHECK(LEN(name_airport) >= 3) 
    );
END

IF OBJECT_ID('Flight_Number') IS NULL
BEGIN
    CREATE TABLE Flight_Number (
        id INT IDENTITY(1,1) PRIMARY KEY,
        departure_time DATETIME,
        description_flight NVARCHAR(100),
        airport_start_id INT,
        airport_goal_id INT,
        FOREIGN KEY (airport_start_id) REFERENCES Airport(id),
        FOREIGN KEY (airport_goal_id) REFERENCES Airport(id),
        CHECK(departure_time >= GETDATE()), 
        CHECK(LEN(description_flight) > 0), 
        CONSTRAINT CK_airport_ids_Flight_Number CHECK(airport_start_id <> airport_goal_id) 
    );
END
IF OBJECT_ID('Plane_Model') IS NULL
BEGIN
    CREATE TABLE Plane_Model (
        id INT IDENTITY(1,1) PRIMARY KEY,
        description NVARCHAR(100),
		seat_amount INT,
        graphic NVARCHAR(100),
        CHECK(LEN(description) > 0), 
        CHECK(LEN(graphic) > 0),
		CHECK(LEN(seat_amount) > 0)
    );
END

IF OBJECT_ID('Airplane') IS NULL
BEGIN
    CREATE TABLE Airplane (
        id INT IDENTITY(1,1) PRIMARY KEY,
        registration_number INT,
        Status NVARCHAR(100),
        plane_model_id INT,
        FOREIGN KEY (plane_model_id) REFERENCES Plane_Model(id),
        CHECK(registration_number > 0), 
        CHECK(LEN(Status) > 0), 
        CONSTRAINT CK_plane_model_id_Airplane CHECK(plane_model_id > 0)
    );
END
IF OBJECT_ID('Flight') IS NULL
BEGIN
    CREATE TABLE Flight (
        id INT IDENTITY(1,1) PRIMARY KEY,
        boarding_time DATETIME,
        flight_date DATE,
        gate NVARCHAR(100),
        check_in_counter INT,
        type_flight_id INT,
        status_flight_id INT,
        flight_number_id INT,
		airplane_id INT,
		FOREIGN KEY (airplane_id) REFERENCES Airplane(id),
        FOREIGN KEY (flight_number_id) REFERENCES Flight_Number(id),
        FOREIGN KEY (status_flight_id) REFERENCES Status_Flight(id),
        FOREIGN KEY (type_flight_id) REFERENCES Type_Flight(id),
        CHECK(boarding_time >= GETDATE()), 
        CHECK(flight_date >= GETDATE()), 
        CHECK(LEN(gate) > 0), 
        CHECK(check_in_counter > 0),
        CONSTRAINT CK_flight_number_id_Flight CHECK(flight_number_id > 0)
    );
END


IF OBJECT_ID('Booking') IS NULL
BEGIN
    CREATE TABLE Booking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        booking_date DATE,
		tickets_cant INT,
        customer_id INT,
        booking_status_id INT,
		flight_id INT,
		FOREIGN KEY (flight_id) REFERENCES Flight(id),
        FOREIGN KEY (customer_id) REFERENCES Customer(id),
        FOREIGN KEY (booking_status_id) REFERENCES Booking_Status(id),
        CHECK(booking_date <= GETDATE()), 
        CONSTRAINT CK_customer_id_Booking CHECK(customer_id > 0),
        CONSTRAINT CK_booking_status_id_Booking CHECK(booking_status_id > 0)
    );
END

/*IF OBJECT_ID('Booking_Flight') IS NULL
BEGIN

    CREATE TABLE Booking_Flight (
        booking_id INT,
        flight_id INT,
        FOREIGN KEY (booking_id) REFERENCES Booking(id),
        FOREIGN KEY (flight_id) REFERENCES Flight(id),
        PRIMARY KEY (booking_id, flight_id)
    );
END
*/
IF OBJECT_ID('Ticket') IS NULL
BEGIN
    CREATE TABLE Ticket (
        id INT IDENTITY(1,1) PRIMARY KEY,
        number INT,
        ticketing_code INT,
        ticket_category_id INT,
        status_ticket_id INT,
		booking_id INT,
        FOREIGN KEY (status_ticket_id) REFERENCES Status_Ticket(id),
        FOREIGN KEY (ticket_category_id) REFERENCES Ticket_Category(id),
		FOREIGN KEY (booking_id) REFERENCES Booking(id),
        CHECK(number > 0), 
        CHECK(ticketing_code > 0) 
    );
END

IF OBJECT_ID('Coupon') IS NULL
BEGIN
    CREATE TABLE Coupon (
        id INT IDENTITY(1,1) PRIMARY KEY,
        date_of_redemption DATE,
        class NVARCHAR(100),
        stand_by NVARCHAR(100),
        meal_code INT,
        ticket_id INT,
        flight_id INT,
        FOREIGN KEY (flight_id) REFERENCES Flight(id),
        FOREIGN KEY (ticket_id) REFERENCES Ticket(id),
        CHECK(date_of_redemption <= GETDATE()), 
        CHECK(LEN(stand_by) > 0),
        CHECK(meal_code >= 0) 
    );
END



IF OBJECT_ID('Gate') IS NULL
BEGIN
    CREATE TABLE Gate (
        id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        location NVARCHAR(100) NOT NULL,
        gate_assignment_status_id INT,
        airport_id INT,
        FOREIGN KEY (gate_assignment_status_id) REFERENCES Gate_Assignment_Status(id),
        FOREIGN KEY (airport_id) REFERENCES Airport(id),
        CONSTRAINT chk_name CHECK(LEN(name) > 0),
        CONSTRAINT chk_location CHECK(LEN(location) > 0)
    );
END

IF OBJECT_ID('Gate_Assignment') IS NULL
BEGIN
    CREATE TABLE Gate_Assignment (
        id INT IDENTITY(1,1) PRIMARY KEY,
        assignment_date DATE NOT NULL,
        gate_id INT NOT NULL,
        flight_id INT NOT NULL,
        FOREIGN KEY (flight_id) REFERENCES Flight(id),
        FOREIGN KEY (gate_id) REFERENCES Gate(id),
        CONSTRAINT chk_assignment_date CHECK(assignment_date <= GETDATE())
    );
END

IF OBJECT_ID('Type_Person') IS NULL
BEGIN
    CREATE TABLE Type_Person(
        id INT IDENTITY(1,1) PRIMARY KEY,
        name_type NVARCHAR(100),
        CHECK(LEN(name_type) > 0),
        CONSTRAINT CK_unique_name_type CHECK(LEN(name_type) > 1) 
    );
END

IF OBJECT_ID('Person') IS NULL
BEGIN
    CREATE TABLE Person (
        id INT IDENTITY(1,1) PRIMARY KEY,
        first_name NVARCHAR(100) NOT NULL,
        last_name NVARCHAR(100) NOT NULL,
        phone_number NVARCHAR(100) NOT NULL,
		nacionality NVARCHAR(100) NOT NULL,
        email NVARCHAR(100) NOT NULL,
        type_person_id INT,
        pasajero_id INT,
        tripulante_id INT,
       -- CONSTRAINT FK_Person_Tripulante FOREIGN KEY (tripulante_id) REFERENCES Tripulante(id),
        CONSTRAINT FK_Person_Type_Person FOREIGN KEY (type_person_id) REFERENCES Type_Person(id),
       -- CONSTRAINT FK_Person_Pasajero FOREIGN KEY (pasajero_id) REFERENCES Pasajero(id),
        CONSTRAINT chk_first_name CHECK (LEN(first_name) > 0),
        CONSTRAINT chk_last_name CHECK (LEN(last_name) > 0),
        CONSTRAINT chk_phone_number CHECK (LEN(phone_number) > 0),
		CONSTRAINT chk_nacionality CHECK (LEN(nacionality) > 0),
        CONSTRAINT chk_email CHECK (LEN(email) > 0 AND email LIKE '%_@__%.__%')
    );

    
END

IF OBJECT_ID('Pasajero') IS NULL
BEGIN
    CREATE TABLE Pasajero (
        id INT IDENTITY(1,1) PRIMARY KEY,
        genero NVARCHAR(100) NOT NULL,
		id_person INT NOT NULL,
        CONSTRAINT chk_genero CHECK(LEN(genero) > 0),
		FOREIGN KEY (id_person) REFERENCES Person (id)
    );
END

IF OBJECT_ID('Tripulante') IS NULL
BEGIN
    CREATE TABLE Tripulante (
        id INT IDENTITY(1,1) PRIMARY KEY,
        codido_tripulante INT NOT NULL,
		id_person INT NOT NULL,
        CONSTRAINT chk_codido_tripulante CHECK(codido_tripulante > 0),
	    FOREIGN KEY (id_person) REFERENCES Person (id)
    );
END

IF OBJECT_ID('Asignacion_Tripulantes') IS NULL
BEGIN
    CREATE TABLE Asignacion_Tripulantes (
        id INT IDENTITY(1,1) PRIMARY KEY,
		hours_amount INT NOT NULL,
        assignment_date DATE NOT NULL,
        rol_tripulante_id INT NOT NULL,
        tripulante_id INT NOT NULL,
        flight_id INT NOT NULL,
        FOREIGN KEY (rol_tripulante_id) REFERENCES Rol_Tripulante(id),
        FOREIGN KEY (tripulante_id) REFERENCES Tripulante(id),
        FOREIGN KEY (flight_id) REFERENCES Flight(id),
    );
END

IF OBJECT_ID('Document') IS NULL
BEGIN
    CREATE TABLE Document (
        id INT IDENTITY(1,1) PRIMARY KEY,
        issue_date DATE NOT NULL,
        due_date DATE NOT NULL,
        document_number INT NOT NULL,
        expiration_date DATE NOT NULL,
        type_document_id INT,
        person_id INT,
        country_id INT,
        FOREIGN KEY (country_id) REFERENCES Country(id),
        FOREIGN KEY (person_id) REFERENCES Person(id),
        FOREIGN KEY (type_document_id) REFERENCES Type_Document(id),
        CONSTRAINT chk_issue_date CHECK(issue_date <= GETDATE()),
        CONSTRAINT chk_due_date CHECK(due_date >= issue_date),
        CONSTRAINT chk_document_number CHECK(document_number > 0)
    );
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_document_country_id' AND object_id = OBJECT_ID('Document'))
    BEGIN
        CREATE INDEX idx_document_country_id ON Document(country_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_document_person_id' AND object_id = OBJECT_ID('Document'))
    BEGIN
        CREATE INDEX idx_document_person_id ON Document(person_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_document_type_document_id' AND object_id = OBJECT_ID('Document'))
    BEGIN
        CREATE INDEX idx_document_type_document_id ON Document(type_document_id);
    END
END




IF OBJECT_ID('Credit_Card') IS NULL
BEGIN
    CREATE TABLE Credit_Card (
        id INT IDENTITY(1,1) PRIMARY KEY,
        card_number NVARCHAR(50),
        cardholder_name NVARCHAR(100),
        expiration_date DATE,
        cvv NVARCHAR(50),
        CONSTRAINT chk_card_number CHECK (LEN(card_number) > 0 AND LEN(card_number) <= 16), 
        CONSTRAINT chk_cardholder_name CHECK (LEN(cardholder_name) > 0), 
        CONSTRAINT chk_expiration_date CHECK (expiration_date > GETDATE()), 
        CONSTRAINT chk_cvv CHECK (LEN(cvv) = 3) 
    );
END

IF OBJECT_ID('Transferencia_Bancaria') IS NULL
BEGIN
    CREATE TABLE Transferencia_Bancaria (
        id INT IDENTITY(1,1) PRIMARY KEY,
        account_number NVARCHAR(50),
        bank_number INT,
        iban NVARCHAR(34),
        swift_code NVARCHAR(50),
        CONSTRAINT chk_account_number CHECK (LEN(account_number) > 0 AND LEN(account_number) <= 34),  
        CONSTRAINT chk_bank_number CHECK (bank_number > 0),  
        CONSTRAINT chk_iban CHECK (LEN(iban) <= 34 AND iban > 0),  
        CONSTRAINT chk_swift_code CHECK (LEN(swift_code) > 0 AND LEN(swift_code) <= 11)  
    );
END

IF OBJECT_ID('Cash') IS NULL
BEGIN
    CREATE TABLE Cash (
        id  INT PRIMARY KEY
    );
END

IF OBJECT_ID('Method_Type') IS NULL
BEGIN
    CREATE TABLE Method_Type (
        id INT IDENTITY(1,1) PRIMARY KEY,
        method_name NVARCHAR(255),
        CONSTRAINT chk_method_name CHECK (LEN(method_name) > 0) 
    );
END

IF OBJECT_ID('Payment_Method') IS NULL
BEGIN
    CREATE TABLE Payment_Method (
        id INT IDENTITY(1,1) PRIMARY KEY,
        description NVARCHAR(255),
        method_type_id INT,
        FOREIGN KEY (method_type_id) REFERENCES Method_Type(id),
        CONSTRAINT chk_description CHECK (LEN(description) > 0) 
    );
END

IF OBJECT_ID('Payment') IS NULL
BEGIN
    CREATE TABLE Payment (
        id INT IDENTITY(1,1) PRIMARY KEY,
        date_payment DATE,
        amount INT,
        payment_status_id INT,
        booking_id INT,
        payment_method_id INT,
		--currency_id INT,
		--FOREIGN KEY (currency_id) REFERENCES Payment_Method(id),
        FOREIGN KEY (booking_id) REFERENCES Booking(id),
        FOREIGN KEY (payment_method_id) REFERENCES Payment_Method(id),
        FOREIGN KEY (booking_id) REFERENCES Booking(id),
        FOREIGN KEY (payment_status_id) REFERENCES Payment_Status(id),
        CONSTRAINT chk_date_payment CHECK (date_payment <= GETDATE()),  
        CONSTRAINT chk_amount CHECK (amount > 0)  
    );
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_booking_id' AND object_id = OBJECT_ID('Payment'))
    BEGIN
        CREATE INDEX idx_booking_id ON Payment(booking_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_payment_method_id' AND object_id = OBJECT_ID('Payment'))
    BEGIN
        CREATE INDEX idx_payment_method_id ON Payment(payment_method_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_payment_status_id' AND object_id = OBJECT_ID('Payment'))
    BEGIN
        CREATE INDEX idx_payment_status_id ON Payment(payment_status_id);
    END
END

IF OBJECT_ID('Currency_Assignment') IS NULL
BEGIN
    CREATE TABLE Currency_Assignment (
        id INT IDENTITY(1,1) PRIMARY KEY,
        assignment_date DATE,
        currency_id INT,
        payment_id INT,
        FOREIGN KEY (payment_id) REFERENCES Payment(id),
        FOREIGN KEY (currency_id) REFERENCES Currency(id),
    );
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_payment_id_currency' AND object_id = OBJECT_ID('Currency_Assignment'))
    BEGIN
        CREATE INDEX idx_payment_id_currency ON Currency_Assignment(payment_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_currency_id' AND object_id = OBJECT_ID('Currency_Assignment'))
    BEGIN
        CREATE INDEX idx_currency_id ON Currency_Assignment(currency_id);
    END
END


IF OBJECT_ID('Cancellation_Booking') IS NULL
BEGIN
    CREATE TABLE Cancellation_Booking (
        id INT IDENTITY(1,1) PRIMARY KEY,
        cancellation_date DATE,
        cancellation_reason NVARCHAR(255),
        penalty_cancellation_id INT,
        booking_id INT,
        CONSTRAINT FK_Cancellation_Booking_Booking FOREIGN KEY (booking_id) REFERENCES Booking(id),
        CONSTRAINT FK_Cancellation_Booking_Penalty FOREIGN KEY (penalty_cancellation_id) REFERENCES Penalty_Cancellation(id),
        CHECK (cancellation_date <= GETDATE()),  
        CHECK (LEN(cancellation_reason) > 0)  
    );
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_booking_id_cancellation' AND object_id = OBJECT_ID('Cancellation_Booking'))
    BEGIN
        CREATE INDEX idx_booking_id_cancellation ON Cancellation_Booking(booking_id);
    END
    IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_penalty_cancellation_id' AND object_id = OBJECT_ID('Cancellation_Booking'))
    BEGIN
        CREATE INDEX idx_penalty_cancellation_id ON Cancellation_Booking(penalty_cancellation_id);
    END
END

IF OBJECT_ID('Status_Seat') IS NULL
BEGIN
    CREATE TABLE Status_Seat(
        id INT IDENTITY(1,1) PRIMARY KEY,
        status_name NVARCHAR(100),
        CONSTRAINT CK_status_name_Status_Seat CHECK(LEN(status_name) > 0) 
    );
END

IF OBJECT_ID('Seat') IS NULL
BEGIN
    CREATE TABLE Seat (
        id INT IDENTITY(1,1) PRIMARY KEY,
        size NVARCHAR(255),
        number INT,
        plane_model_id INT,
		status_seat_id INT,
		FOREIGN KEY (status_seat_id) REFERENCES Status_Seat(id),
        CONSTRAINT FK_Seat_Plane_Model FOREIGN KEY (plane_model_id) REFERENCES Plane_Model(id),
        CHECK (number > 0)
    );
END

IF OBJECT_ID('Pieces_of_Luggage') IS NULL
BEGIN
    CREATE TABLE Pieces_of_Luggage (
        id INT IDENTITY(1,1) PRIMARY KEY,
        weight_of_pieces DECIMAL(5, 2),
        amount_luggages INT,
        total_rate INT,
        coupon_id INT,
        CONSTRAINT FK_Pieces_of_Luggage_Coupon FOREIGN KEY (coupon_id) REFERENCES Coupon(id),
        CHECK (weight_of_pieces >= 0),
        CHECK (amount_luggages >= 0),
        CHECK (total_rate >= 0)
    );
END

IF OBJECT_ID('Check_In_Luggage') IS NULL
BEGIN
    CREATE TABLE Check_In_Luggage (
        id INT IDENTITY(1,1) PRIMARY KEY,
        checking_date DATE,
        status NVARCHAR(50),
        pieces_of_luggage_id INT,
        CONSTRAINT FK_Check_In_Luggage_Pieces_of_Luggage FOREIGN KEY (pieces_of_luggage_id) REFERENCES Pieces_of_Luggage(id),
        CHECK (checking_date <= GETDATE())
    );
END

IF OBJECT_ID('Airline_Assignment') IS NULL
BEGIN
    CREATE TABLE Airline_Assignment (
        id INT IDENTITY(1,1) PRIMARY KEY,
        assignment_date DATE,
        description NVARCHAR(255),
        flight_id INT,
        airline_id INT,
        CONSTRAINT FK_Airline_Assignment_Flight_Number FOREIGN KEY (flight_id) REFERENCES Flight(id),
        CONSTRAINT FK_Airline_Assignment_Airline FOREIGN KEY (airline_id) REFERENCES Airline(id),
        CHECK (assignment_date <= GETDATE())
    );
END

IF OBJECT_ID('Document_Submission') IS NULL
BEGIN
    CREATE TABLE Document_Submission (
        id INT IDENTITY(1,1) PRIMARY KEY,
        assignment_date DATE,
        person_id INT,
        ticket_id INT,
        document_id INT,
        CONSTRAINT FK_Document_Submission_Person FOREIGN KEY (person_id) REFERENCES Person(id),
        CONSTRAINT FK_Document_Submission_Ticket FOREIGN KEY (ticket_id) REFERENCES Ticket(id),
        CONSTRAINT FK_Document_Submission_Document FOREIGN KEY (document_id) REFERENCES Document(id),
        CHECK (assignment_date <= GETDATE())
    );
END

IF OBJECT_ID('Luggage') IS NULL
BEGIN
    CREATE TABLE Luggage (
        id INT IDENTITY(1,1) PRIMARY KEY,
        dimensions NVARCHAR(100),
        weight DECIMAL(5, 2),
        pieces_of_luggage_id INT,
        type_of_luggages_id INT,
        CONSTRAINT FK_Luggage_Pieces_of_Luggage FOREIGN KEY (pieces_of_luggage_id) REFERENCES Pieces_of_Luggage(id),
        CONSTRAINT FK_Luggage_Types_of_Luggages FOREIGN KEY (type_of_luggages_id) REFERENCES Types_of_Luggages(id),
        CHECK (weight >= 0)
    );
END

IF OBJECT_ID('Flight_Cancellation') IS NULL
BEGIN
    CREATE TABLE Flight_Cancellation (
        id INT IDENTITY(1,1) PRIMARY KEY,
        cancellation_time DATETIME,
        cancellation_reason NVARCHAR(255),
        responsible_party NVARCHAR(255),
        flight_number INT,
        compensation_detail INT,
        CONSTRAINT FK_Flight_Cancellation_Flight_Number FOREIGN KEY (flight_number) REFERENCES Flight_Number(id),
        CONSTRAINT FK_Flight_Cancellation_Compensation_Detail FOREIGN KEY (compensation_detail) REFERENCES Compensation_Detail(id),
        CHECK (cancellation_time <= GETDATE())
    );
END


    PRINT 'Operacion exitosa';
    COMMIT TRANSACTION;
END TRY

BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al crear tablas: ' + ERROR_MESSAGE();
END CATCH;
GO