USE master;
GO

-- Crear base de datos
CREATE DATABASE Airport;
GO
/*select * from Flight*/
-- Usar la base de datos creada
USE Airport;

-- Crear tabla de la dimensión Airplane
CREATE TABLE Airplane(
    id_airplane INT PRIMARY KEY NOT NULL,
    registration_number INT NULL,
    description_plane NVARCHAR(100) NULL,
    seat_amount_airplane INT NULL
);

-- Crear tabla de la dimensión Destination
CREATE TABLE Destination(
    id_destination INT PRIMARY KEY NOT NULL,
    airport_name NVARCHAR(100),
    city_name NVARCHAR(100),
    country_name NVARCHAR(100)
);

-- Crear tabla de la dimensión Time
CREATE TABLE Time(
    date DATE PRIMARY KEY NOT NULL,
    day INT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    quarter VARCHAR(2) NOT NULL,
    weekday VARCHAR(10) NOT NULL,
    month_name VARCHAR(10) NOT NULL
);

-- Crear tabla de la dimensión Type_flight
CREATE TABLE Type_flight(
    id_type_flight INT PRIMARY KEY NOT NULL,
    type_name_flight NVARCHAR(100)
);

-- Crear tabla de la dimensión Airline
CREATE TABLE Airline(
    id_airline INT PRIMARY KEY NOT NULL,
    airline_name NVARCHAR(100)
);
CREATE TABLE Status_flight(
   id_status_flight INT PRIMARY KEY NOT NULL,
   flight_status_name NVARCHAR(100)
);
--VAMOS A IMPLEMENTAR LA DIMENSION TIPO DE TICKETS
CREATE TABLE Ticket_category(
   id INT NOT NULL PRIMARY KEY,
   category_name NVARCHAR(100)
);

-- Crear tabla de hechos Flight
CREATE TABLE Fact_Flight(
    id INT IDENTITY(1,1) PRIMARY KEY,
    flight_date DATE,
    type_flight_id INT,
    destination_id INT,
    airline_id INT,
    Airplane_id INT,
	status_flight_id INT,
	amount_tickets INT NULL,
	amount_seat INT,
	amount_seat_free INT,
	amount_seat_not_free INT,
	--airport_name NVARCHAR(100),
	--status_flight NVARCHAR(100),
	--airplane_description NVARCHAR(100),
	--airline_name NVARCHAR(100),
	--type_flight_name NVARCHAR(100),
	FOREIGN KEY (status_flight_id) REFERENCES Status_flight(id_status_flight),
    FOREIGN KEY (airline_id) REFERENCES Airline(id_airline),
    FOREIGN KEY (flight_date) REFERENCES Time(date),
    FOREIGN KEY (Airplane_id) REFERENCES Airplane(id_airplane),
    FOREIGN KEY (destination_id) REFERENCES Destination(id_destination),
    FOREIGN KEY (type_flight_id) REFERENCES Type_flight(id_type_flight)
);
/*
Aqui vamos a adicionar el hecho maletas 
*/
CREATE TABLE flight_dim(
id_flight INT PRIMARY KEY NOT NULL,
flight_type_name NVARCHAR(100),
flight_date DATE ,
ariplane_registration_number INT,
ariplane_status NVARCHAR(100),
airplane_description NVARCHAR(100),
airline_name NVARCHAR(100),
);
CREATE TABLE Currency(
id_currency INT PRIMARY KEY NOT NULL,
currency_name NVARCHAR(50),
exchange_rate DECIMAL(10,4)
);
CREATE TABLE Customer(
id_customer INT PRIMARY KEY NOT NULL,
type_name_customer NVARCHAR(100),
nacionality NVARCHAR(100)
);

CREATE TABLE Payment_method(
id INT PRIMARY KEY NOT NULL,
method_name NVARCHAR(255)
);
--vamos a crear la dimension roles 
CREATE TABLE roles(
id_rol INT PRIMARY KEY NOT NULL,
name_rol NVARCHAR(100)
);
--creamos la dimension estado de reserva 
CREATE TABLE status_booking(
   id INT NOT NULL PRIMARY KEY,
   name_status NVARCHAR(100)
);

/*Hacemos la tabla de hechos*/

CREATE TABLE Fact_Payment(
 payment_id INT NOT NULL PRIMARY KEY IDENTITY(1,1),
 customer_id INT NOT NULL,
 payment_method_id INT NOT NULL,
 currency_id INT,
 flight_dim_id INT,
 time_id DATE,
 destination_id INT,
 total_amount INT,
 FOREIGN KEY(customer_id) REFERENCES Customer(id_customer),
 FOREIGN KEY(payment_method_id) REFERENCES Payment_method(id),
 FOREIGN KEY(currency_id) REFERENCES Currency(id_currency),
 FOREIGN KEY(flight_dim_id) REFERENCES flight_dim(id_flight),
 FOREIGN KEY(time_id) REFERENCES Time(date),
 FOREIGN KEY(destination_id) REFERENCES Destination(id_destination)
); 
-- falta copiar el hecho Reservas 

CREATE TABLE Fact_Booking(
    id INT IDENTITY(1,1) PRIMARY KEY,
	time_id DATE NOT NULL,
	destination_id INT NOT NULL,
    customer_id INT NOT NULL,
    airline_id INT NOT NULL,
	payment_method_id INT NOT NULL,
	id_status int not null,
	total_amount INT,
    FOREIGN KEY(id_status) REFERENCES status_booking(id),
	FOREIGN KEY(time_id) REFERENCES Time(date),
    FOREIGN KEY (destination_id) REFERENCES Destination(id_destination),
	FOREIGN KEY(customer_id) REFERENCES Customer(id_customer),
    FOREIGN KEY (airline_id) REFERENCES Airline(id_airline),
	FOREIGN KEY(payment_method_id) REFERENCES Payment_method(id)
);

--Vamos a implementar el hecho Maletas 
CREATE TABLE Fact_Luggage(
id_luggage INT NOT NULL PRIMARY KEY,--PRIMARY KEY
id_Ticket_category INT NOT NULL,
id_flight INT NOT NULL,
id_destination INT NOT NULL,
id_time DATE NOT NULL,
weight_of_pieces DECIMAL(5,2) NOT NULL,
amount_luggages INT NOT NULL,
total_rate INT NOT NULL,
status_luggage NVARCHAR(50),--esto agrege
FOREIGN KEY(id_Ticket_category) REFERENCES Ticket_category(id),
FOREIGN KEY(id_flight) REFERENCES flight_dim(id_flight),
FOREIGN KEY(id_destination) REFERENCES Destination(id_destination),
FOREIGN KEY(id_time) REFERENCES Time(date)
);
--vamos a crear el hecho asignacion de tripulantes 
CREATE TABLE Fact_asignacion_tripulantes(
id_asignacion_tripulante INT NOT NULL PRIMARY KEY,
id_time DATE NOT NULL,
id_rol INT NOT NULL,
id_flight INT NOT NULL,
id_airline INT NOT NULL,
id_airplane INT NOT NULL,
id_destination INT NOT NULL,
hours_amount INT NOT NULL,
FOREIGN KEY(id_time)REFERENCES Time(date),
FOREIGN KEY(id_rol)REFERENCES roles(id_rol),
FOREIGN KEY(id_flight)REFERENCES flight_dim(id_flight),
FOREIGN KEY(id_airplane)REFERENCES Airplane(id_airplane),
FOREIGN KEY(id_destination)REFERENCES Destination(id_destination),
FOREIGN KEY(id_airline) REFERENCES Airline(id_airline)
);

/*ALTER TABLE Fact_Luggage
ADD status_luggage NVARCHAR(50);*/
drop table Fact_Luggage















