USE Airport_tickets;
GO
CREATE PROCEDURE PopulateTimeDimension
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartDate DATE = '2020-01-01';  -- Fecha de inicio
    DECLARE @EndDate DATE = '2030-12-31';    -- Fecha de fin
    DECLARE @CurrentDate DATE = @StartDate;

    -- Borrar los registros existentes (opcional)
    DELETE FROM Time;

    WHILE @CurrentDate <= @EndDate
    BEGIN
        INSERT INTO Time (date, day, month, year, quarter, weekday, month_name)
        VALUES (
            @CurrentDate,
            DAY(@CurrentDate),
            MONTH(@CurrentDate),
            YEAR(@CurrentDate),
            'Q' + CAST(DATEPART(QUARTER, @CurrentDate) AS VARCHAR(1)),
            DATENAME(WEEKDAY, @CurrentDate),
            DATENAME(MONTH, @CurrentDate)
        );

        SET @CurrentDate = DATEADD(DAY, 1, @CurrentDate);  -- Incrementar la fecha
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC PopulateTimeDimension;

    PRINT 'CORRECTO: PopulateTimeDimension';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCustomerType: ' + ERROR_MESSAGE();
END CATCH
GO
GO

CREATE PROCEDURE InsertRandomCustomerType
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RandomNIT INT;

    -- Tabla temporal para tipos de clientes comunes en un aeropuerto
    DECLARE @CustomerTypes TABLE (NameType NVARCHAR(100), NIT INT);

    -- Insertar tipos de clientes y NITs comunes
    INSERT INTO @CustomerTypes (NameType, NIT)
    VALUES 
        ('Passenger', 1000000 + ABS(CHECKSUM(NEWID())) % 999000000), 
        ('Airline Staff', 1000000 + ABS(CHECKSUM(NEWID())) % 999000000), 
        ('Vendor', 1000000 + ABS(CHECKSUM(NEWID())) % 999000000), 
        ('Maintenance Crew', 1000000 + ABS(CHECKSUM(NEWID())) % 999000000), 
        ('Security Personnel', 1000000 + ABS(CHECKSUM(NEWID())) % 999000000);

    -- Insertar los registros en la tabla Customer_Type
    INSERT INTO Customer_Type (name_type, NIT)
    SELECT NameType, NIT 
    FROM @CustomerTypes;
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCustomerType;

    PRINT 'CORRECTO: InsertRandomCustomerType';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCustomerType: ' + ERROR_MESSAGE();
END CATCH
GO


CREATE PROCEDURE InsertRandomCustomers
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomFirstName NVARCHAR(100);
    DECLARE @RandomLastName NVARCHAR(100);
    DECLARE @RandomPhoneNumber BIGINT;
    DECLARE @RandomEmail NVARCHAR(100);
    DECLARE @RandomCustomerTypeID INT;
    DECLARE @RandomNationality NVARCHAR(100);

    -- Tablas temporales para nombres, apellidos y nacionalidades
    DECLARE @FirstNames TABLE (FirstName NVARCHAR(100));
    DECLARE @LastNames TABLE (LastName NVARCHAR(100));
    DECLARE @Nationalities TABLE (Nationality NVARCHAR(100));

    -- Insertar nombres comunes
    INSERT INTO @FirstNames (FirstName)
    VALUES 
        ('John'), ('Jane'), ('Michael'), ('Emily'), ('David'), 
        ('Sarah'), ('Chris'), ('Jessica'), ('Daniel'), ('Laura'),
        ('Matthew'), ('Sophia'), ('James'), ('Olivia'), ('Ryan'),
        ('Ashley'), ('Andrew'), ('Megan'), ('Joshua'), ('Lauren'),
        ('Brandon'), ('Brianna'), ('Jacob'), ('Natalie'), ('Tyler'),
        ('Hannah'), ('Zachary'), ('Brittany'), ('Samuel'), ('Victoria');

    -- Insertar apellidos comunes
    INSERT INTO @LastNames (LastName)
    VALUES 
        ('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'), 
        ('Garcia'), ('Miller'), ('Davis'), ('Rodriguez'), ('Martinez'),
        ('Hernandez'), ('Lopez'), ('Gonzalez'), ('Wilson'), ('Anderson'),
        ('Thomas'), ('Taylor'), ('Moore'), ('Jackson'), ('Martin'),
        ('Lee'), ('Perez'), ('Thompson'), ('White'), ('Harris'),
        ('Sanchez'), ('Clark'), ('Ramirez'), ('Lewis'), ('Robinson');

    -- Insertar nacionalidades comunes
    INSERT INTO @Nationalities (Nationality)
    VALUES 
        ('American'), ('British'), ('Canadian'), ('Australian'), ('German'),
        ('Argentinian'), ('Bolivian'), ('Brazilian'), ('Chilean'), ('Colombian'),
        ('Ecuadorian'), ('Paraguayan'), ('Peruvian'), ('Uruguayan'), ('Venezuelan'),
        ('Chinese'), ('Japanese'), ('South Korean'), ('Russian'), ('Spanish');

    -- Obtener todos los IDs de tipos de clientes
    DECLARE @CustomerTypeIDs TABLE (CustomerTypeID INT);
    INSERT INTO @CustomerTypeIDs (CustomerTypeID)
    SELECT id FROM Customer_Type;

    WHILE @i <= 100
    BEGIN
        -- Seleccionar un nombre y apellido aleatorio
        SELECT TOP 1 @RandomFirstName = FirstName FROM @FirstNames ORDER BY NEWID();
        SELECT TOP 1 @RandomLastName = LastName FROM @LastNames ORDER BY NEWID();
        SELECT TOP 1 @RandomNationality = Nationality FROM @Nationalities ORDER BY NEWID();

        -- Generar un número de teléfono y correo electrónico aleatorio
        SET @RandomPhoneNumber = CAST(60000000 + ABS(CHECKSUM(NEWID())) % 90000000 AS BIGINT);
        SET @RandomEmail = LOWER(@RandomFirstName) + '.' + LOWER(@RandomLastName) + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS NVARCHAR(100)) + '@example.com';

        -- Seleccionar un CustomerTypeID aleatorio de la tabla Customer_Type
        SELECT TOP 1 @RandomCustomerTypeID = CustomerTypeID FROM @CustomerTypeIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Customer (first_name, last_name, phone_number, email, customer_type_id, nationality)
        VALUES (@RandomFirstName, @RandomLastName, @RandomPhoneNumber, @RandomEmail, @RandomCustomerTypeID, @RandomNationality);

        SET @i = @i + 1;
    END
END;



GO
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCustomers;

    PRINT 'CORRECTO: InsertRandomCustomers';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCustomers: ' + ERROR_MESSAGE();
END CATCH


GO

CREATE PROCEDURE InsertRandomTypesOfLuggages
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomTariff INT;

    -- Tabla temporal para tipos de equipajes comunes con sus descripciones
    DECLARE @Types TABLE (NameType NVARCHAR(100), Description NVARCHAR(255));

    -- Insertar tipos de equipajes comunes con sus descripciones
    INSERT INTO @Types (NameType, Description)
    VALUES 
        ('Carry-On', 'Small bag for cabin'),
        ('Checked', 'Large bag for hold'),
        ('Oversized', 'Extra large item'),
        ('Fragile', 'Handle with care'),
        ('Sports Equipment', 'Special sports gear');

    -- Insertar cada tipo de equipaje con una tarifa aleatoria
    INSERT INTO Types_of_Luggages (name_type, description, tariff)
    SELECT 
        NameType,
        Description,
        ABS(CHECKSUM(NEWID())) % 100 + 10 -- Generar tarifa aleatoria entre 10 y 109
    FROM @Types;
END

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTypesOfLuggages;

    PRINT 'CORRECTO: InsertRandomTypesOfLuggages';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTypesOfLuggages: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomStatusTicket
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para estados de tickets comunes
    DECLARE @StatusNames TABLE (StatusName NVARCHAR(100));

    -- Insertar estados de tickets comunes en la tabla temporal
    INSERT INTO @StatusNames (StatusName)
    VALUES ('Booked'), ('Checked-In'), ('Cancelled'), ('Boarded'), ('Completed');

    -- Insertar cada estado de ticket en la tabla Status_Ticket solo una vez
    INSERT INTO Status_Ticket (status_name)
    SELECT StatusName FROM @StatusNames;
END

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomStatusTicket;

    PRINT 'CORRECTO: InsertRandomStatusTicket';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomStatusTicket: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomTypeFlight
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para tipos de vuelos comunes
    DECLARE @NameTypes TABLE (NameType NVARCHAR(100));

    -- Insertar tipos de vuelos comunes en la tabla temporal
    INSERT INTO @NameTypes (NameType)
    VALUES ('Domestic'), ('International'), ('Charter'), ('Cargo'), ('Private');

    -- Insertar cada tipo de vuelo en la tabla Type_Flight solo una vez
    INSERT INTO Type_Flight (name_type)
    SELECT NameType FROM @NameTypes;
END

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTypeFlight;

    PRINT 'CORRECTO: InsertRandomTypeFlight';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTypeFlight: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomStatusFlight
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para estados de vuelo comunes
    DECLARE @StatusNames TABLE (StatusName NVARCHAR(100));

    -- Insertar estados de vuelo comunes en la tabla temporal
    INSERT INTO @StatusNames (StatusName)
    VALUES ('Scheduled'), ('Delayed'), ('Cancelled'), ('Boarding'), ('Departed'), ('Arrived');

    -- Insertar cada estado de vuelo en la tabla Status_Flight solo una vez
    INSERT INTO Status_Flight (status_name)
    SELECT StatusName FROM @StatusNames;
END

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomStatusFlight;

    PRINT 'CORRECTO: InsertRandomStatusFlight';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomStatusFlight: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomCompensationDetail
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomCompensationType NVARCHAR(100);
    DECLARE @RandomCompensationAmount NVARCHAR(100);
    DECLARE @RandomIssueBy BIGINT;
    DECLARE @RandomIssueDate DATE;
    DECLARE @RandomExpirationDate DATE;

    -- Tablas temporales para tipos de compensación comunes
    DECLARE @CompensationTypes TABLE (CompensationType NVARCHAR(100));

    -- Insertar tipos de compensación comunes
    INSERT INTO @CompensationTypes (CompensationType)
    VALUES ('Refund'), ('Voucher'), ('Discount'), ('Upgrade'), ('Miles');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un tipo de compensación aleatorio
        SELECT TOP 1 @RandomCompensationType = CompensationType FROM @CompensationTypes ORDER BY NEWID();

        -- Generar una cantidad de compensación aleatoria
        SET @RandomCompensationAmount = CAST(ABS(CHECKSUM(NEWID())) % 1000 AS NVARCHAR(100)) + '.00';

        -- Generar un ID de emisor aleatorio
        SET @RandomIssueBy = ABS(CHECKSUM(NEWID())) % 100 + 1;

        -- Generar fechas aleatorias
        SET @RandomIssueDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());
        SET @RandomExpirationDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 + 365, @RandomIssueDate);

        -- Insertar el registro en la tabla
        INSERT INTO Compensation_Detail (compensation_type, compensation_amount, issue_by, issue_date, expiration_date)
        VALUES (@RandomCompensationType, @RandomCompensationAmount, @RandomIssueBy, @RandomIssueDate, @RandomExpirationDate);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCompensationDetail;

    PRINT 'CORRECTO: InsertRandomCompensationDetail';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCompensationDetail: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomGateStatus
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomStatusName NVARCHAR(100);

    -- Tablas temporales para estados de puerta comunes
    DECLARE @StatusNames TABLE (StatusName NVARCHAR(100));

    -- Insertar estados de puerta comunes
    INSERT INTO @StatusNames (StatusName)
    VALUES ('Open'), ('Closed'), ('Boarding'), ('Maintenance'), ('Delayed');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un estado de puerta aleatorio
        SELECT TOP 1 @RandomStatusName = StatusName FROM @StatusNames ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Gate_Status (status_name)
        VALUES (@RandomStatusName);

        SET @i = @i + 1;
    END
END
GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomGateStatus;

    PRINT 'CORRECTO: InsertRandomGateStatus';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomGateStatus: ' + ERROR_MESSAGE();
END CATCH

GO
GO

CREATE PROCEDURE InsertRandomCurrency
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomName NVARCHAR(50);
    DECLARE @RandomExchangeRate DECIMAL(10, 4);

    -- Tabla temporal para nombres de monedas comunes
    DECLARE @CurrencyNames TABLE (Name NVARCHAR(50));

    -- Insertar nombres de monedas comunes
    INSERT INTO @CurrencyNames (Name)
    VALUES ('USD'), ('EUR'), ('JPY'), ('GBP'), ('AUD');

    DECLARE CurrencyCursor CURSOR FOR
        SELECT Name FROM @CurrencyNames;

    OPEN CurrencyCursor;

    FETCH NEXT FROM CurrencyCursor INTO @RandomName;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si la moneda ya existe
        IF NOT EXISTS (SELECT 1 FROM Currency WHERE name = @RandomName)
        BEGIN
            -- Generar una tasa de cambio aleatoria
            SET @RandomExchangeRate = CAST(ABS(CHECKSUM(NEWID())) % 10000 AS DECIMAL(10, 4)) / 100;

            -- Insertar el registro en la tabla
            INSERT INTO Currency (name, exchange_rate)
            VALUES (@RandomName, @RandomExchangeRate);
        END

        FETCH NEXT FROM CurrencyCursor INTO @RandomName;
    END

    CLOSE CurrencyCursor;
    DEALLOCATE CurrencyCursor;
END
GO

GO



BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCurrency;

    PRINT 'CORRECTO: InsertRandomCurrency';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCurrency: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomBookingStatus
AS
BEGIN
    SET NOCOUNT ON;

    -- Tabla temporal para estados de reserva comunes
    DECLARE @StatusNames TABLE (NameStatus NVARCHAR(100));

    -- Insertar estados de reserva comunes en la tabla temporal
    INSERT INTO @StatusNames (NameStatus)
    VALUES ('Confirmed'), ('Pending'), ('Cancelled'), ('Checked-In'), ('Completed');

    -- Insertar cada estado de reserva en la tabla Booking_Status solo una vez
    INSERT INTO Booking_Status (name_status)
    SELECT NameStatus FROM @StatusNames;
END

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomBookingStatus;

    PRINT 'CORRECTO: InsertRandomBookingStatus';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomBookingStatus: ' + ERROR_MESSAGE();
END CATCH

GO

--drop procedure InsertRandomTicketCategory
CREATE PROCEDURE InsertUniqueTicketCategories
AS
BEGIN
    SET NOCOUNT ON;

    -- Solo insertar las categorías una vez
    IF NOT EXISTS (SELECT 1 FROM Ticket_Category)
    BEGIN
        INSERT INTO Ticket_Category (category_name)
        VALUES ('Economy'), ('Business'), ('First Class'), ('Premium Economy'), ('Standby');
    END
END
GO

GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertUniqueTicketCategories;

    PRINT 'CORRECTO: InsertRandomTicketCategory';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTicketCategory: ' + ERROR_MESSAGE();
END CATCH

GO


CREATE PROCEDURE InsertRandomPenaltyCancellation
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomCancellationType NVARCHAR(100);
    DECLARE @RandomAmount BIGINT;

    -- Tablas temporales para tipos de cancelación comunes
    DECLARE @CancellationTypes TABLE (CancellationType NVARCHAR(100));

    -- Insertar tipos de cancelación comunes
    INSERT INTO @CancellationTypes (CancellationType)
    VALUES ('No Show'), ('Late Cancellation'), ('Change Fee'), ('Refund Fee'), ('Rebooking Fee');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un tipo de cancelación aleatoria
        SELECT TOP 1 @RandomCancellationType = CancellationType FROM @CancellationTypes ORDER BY NEWID();

        -- Generar una cantidad aleatoria
        SET @RandomAmount = ABS(CHECKSUM(NEWID())) % 500 + 50;

        -- Insertar el registro en la tabla
        INSERT INTO Penalty_Cancellation (cancellation_type, amount)
        VALUES (@RandomCancellationType, @RandomAmount);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPenaltyCancellation;

    PRINT 'CORRECTO: InsertRandomPenaltyCancellation';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPenaltyCancellation: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomCategory
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RandomDescription NVARCHAR(255);

    -- Tabla temporal para categorías y descripciones comunes
    DECLARE @CategoryData TABLE (CategoryName NVARCHAR(100), Description NVARCHAR(255));

    -- Insertar categorías y descripciones comunes
    INSERT INTO @CategoryData (CategoryName, Description)
    VALUES 
        ('VIP', 'Very Important Person'), 
        ('Regular', 'Standard category'), 
        ('Discount', 'Discounted tickets'), 
        ('Group', 'Group booking'), 
        ('Corporate', 'Corporate clients');

    -- Insertar los registros en la tabla Category
    INSERT INTO Category (category_name, description_category)
    SELECT CategoryName, Description 
    FROM @CategoryData;
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCategory;

    PRINT 'CORRECTO: InsertRandomCategory';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCategory: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomPaymentStatus
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomNameStatus NVARCHAR(100);

    -- Tablas temporales para estados de pago comunes
    DECLARE @StatusNames TABLE (NameStatus NVARCHAR(100));

    -- Insertar estados de pago comunes
    INSERT INTO @StatusNames (NameStatus)
    VALUES ('Paid'), ('Pending'), ('Failed'), ('Refunded'), ('Cancelled');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un estado de pago aleatorio
        SELECT TOP 1 @RandomNameStatus = NameStatus FROM @StatusNames ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Payment_Status (name_status)
        VALUES (@RandomNameStatus);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPaymentStatus;

    PRINT 'CORRECTO: InsertRandomPaymentStatus';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPaymentStatus: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomTypeDocument
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomNameDocument NVARCHAR(100);

    -- Tablas temporales para tipos de documentos comunes
    DECLARE @DocumentNames TABLE (NameDocument NVARCHAR(100));

    -- Insertar tipos de documentos comunes
    INSERT INTO @DocumentNames (NameDocument)
    VALUES ('Passport'), ('ID Card'), ('Driver License'), ('Visa'), ('Boarding Pass');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un tipo de documento aleatorio
        SELECT TOP 1 @RandomNameDocument = NameDocument FROM @DocumentNames ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Type_Document (name_document)
        VALUES (@RandomNameDocument);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTypeDocument;

    PRINT 'CORRECTO: InsertRandomTypeDocument';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTypeDocument: ' + ERROR_MESSAGE();
END CATCH

GO


CREATE PROCEDURE InsertRandomCategoryAssignment
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomAssignmentDate DATE;
    DECLARE @RandomCategoryID BIGINT;
    DECLARE @RandomCustomerID BIGINT;

    -- Obtener todos los IDs de categorías y clientes
    DECLARE @CategoryIDs TABLE (CategoryID BIGINT);
    DECLARE @CustomerIDs TABLE (CustomerID BIGINT);
    INSERT INTO @CategoryIDs (CategoryID)
    SELECT id FROM Category;
    INSERT INTO @CustomerIDs (CustomerID)
    SELECT id FROM Customer;

    -- Asegurar que cada cliente tenga al menos una asignación de categoría
    DECLARE @CustomerCount INT;
    SELECT @CustomerCount = COUNT(*) FROM @CustomerIDs;

    WHILE @i <= @CustomerCount
    BEGIN
        -- Seleccionar un ID de cliente secuencialmente
        SELECT @RandomCustomerID = CustomerID FROM @CustomerIDs WHERE CustomerID = @i;

        -- Asegurar una única asignación de categoría activa por cliente
        DECLARE @FirstCategoryID BIGINT;
        SELECT TOP 1 @FirstCategoryID = CategoryID FROM @CategoryIDs ORDER BY NEWID();

        -- Insertar el registro con estado 'Activa'
        SET @RandomAssignmentDate = DATEADD(DAY, - ABS(CHECKSUM(NEWID())) % 365, GETDATE());
        INSERT INTO Category_Assignment (assignment_date, status, category_id, customer_id)
        VALUES (@RandomAssignmentDate, 'Activa', @FirstCategoryID, @RandomCustomerID);

        -- Asignar de 1 a 3 categorías adicionales sin duplicados y con estado 'Inactiva'
        DECLARE @j INT = 1;
        DECLARE @NumCategories INT = ABS(CHECKSUM(NEWID())) % 3 + 1;

        WHILE @j <= @NumCategories
        BEGIN
            -- Generar una fecha de asignación aleatoria
            SET @RandomAssignmentDate = DATEADD(DAY, - ABS(CHECKSUM(NEWID())) % 365, GETDATE());

            -- Seleccionar un ID aleatorio de categoría que no sea ya asignada
            SELECT TOP 1 @RandomCategoryID = CategoryID FROM @CategoryIDs
            WHERE CategoryID NOT IN (
                SELECT category_id FROM Category_Assignment WHERE customer_id = @RandomCustomerID
            )
            ORDER BY NEWID();

            -- Insertar el registro con estado 'Inactiva'
            INSERT INTO Category_Assignment (assignment_date, status, category_id, customer_id)
            VALUES (@RandomAssignmentDate, 'Inactiva', @RandomCategoryID, @RandomCustomerID);

            SET @j = @j + 1;
        END

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCategoryAssignment;

    PRINT 'CORRECTO: InsertRandomCategoryAssignment';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCategoryAssignment: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomFrequentFlyerCard
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomMiles BIGINT;
    DECLARE @RandomMealCode BIGINT;
    DECLARE @RandomCustomerID BIGINT;

    -- Obtener todos los IDs de clientes válidos
    DECLARE @CustomerIDs TABLE (CustomerID BIGINT);
    INSERT INTO @CustomerIDs (CustomerID)
    SELECT id FROM Customer;

    WHILE @i <= 50
    BEGIN
        -- Generar millas y código de comida aleatorios
        SET @RandomMiles = ABS(CHECKSUM(NEWID())) % 100000 + 1000;
        SET @RandomMealCode = ABS(CHECKSUM(NEWID())) % 10 + 1;

        -- Seleccionar un ID de cliente aleatorio de los IDs válidos
        SELECT TOP 1 @RandomCustomerID = CustomerID FROM @CustomerIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Frequent_Flyer_Card (milles, Meal_code, customer_id)
        VALUES (@RandomMiles, @RandomMealCode, @RandomCustomerID);

        SET @i = @i + 1;
    END
END
GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomFrequentFlyerCard;

    PRINT 'CORRECTO: InsertRandomFrequentFlyerCard';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomFrequentFlyerCard: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomGateAssignmentStatus
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomDateAssignment DATE;
    DECLARE @RandomGateStatusID BIGINT;

    WHILE @i <= 50
    BEGIN
        -- Generar una fecha de asignación aleatoria
        SET @RandomDateAssignment = DATEADD(DAY, - ABS(CHECKSUM(NEWID())) % 365, GETDATE());

        -- Generar un ID de estado de puerta aleatorio
        SET @RandomGateStatusID = ABS(CHECKSUM(NEWID())) % 50 + 1;

        -- Insertar el registro en la tabla
        INSERT INTO Gate_Assignment_Status (date_Assignment, Gate_Status_id)
        VALUES (@RandomDateAssignment, @RandomGateStatusID);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomGateAssignmentStatus;

    PRINT 'CORRECTO: InsertRandomGateAssignmentStatus';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomGateAssignmentStatus: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomAirline
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomName NVARCHAR(100);
    DECLARE @RandomCodeIATA BIGINT;
	DECLARE @RandomEmail NVARCHAR(100);

    -- Tablas temporales para nombres de aerolíneas comunes
    DECLARE @AirlineNames TABLE (Name NVARCHAR(100));

    -- Insertar nombres de aerolíneas comunes
    INSERT INTO @AirlineNames (Name)
    VALUES ('American Airlines'), ('Delta Air Lines'), ('United Airlines'), ('Southwest Airlines'), ('JetBlue Airways');

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un nombre de aerolínea aleatorio
        SELECT TOP 1 @RandomName = Name FROM @AirlineNames ORDER BY NEWID();

        -- Generar un código IATA aleatorio
        SET @RandomCodeIATA = ABS(CHECKSUM(NEWID())) % 1000;
		-- Generar un email aleatorio
		SET @RandomEmail = LOWER(@RandomName) + CAST(ABS(CHECKSUM(NEWID())) % 1000 AS NVARCHAR(100)) + '@example.com';

        -- Insertar el registro en la tabla
        INSERT INTO Airline (name, email, code_iata)
        VALUES (@RandomName, @RandomEmail, @RandomCodeIATA);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomAirline;

    PRINT 'CORRECTO: InsertRandomAirline';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomAirline: ' + ERROR_MESSAGE();
END CATCH

GO

CREATE PROCEDURE InsertRandomCountry
    @NumberOfRecords INT = 50 -- Ajusta según necesidad
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @NameCountry NVARCHAR(100);
    DECLARE @Countries TABLE (Name NVARCHAR(100));

    -- Insertar una lista de países comunes
    INSERT INTO @Countries (Name)
    VALUES 
        ('Argentina'), ('Brasil'), ('Canadá'), ('Dinamarca'), ('España'),
        ('Francia'), ('Alemania'), ('Hungría'), ('India'), ('Japón'),
        ('México'), ('Noruega'), ('Perú'), ('Rusia'), ('Suecia'),
        ('Turquía'), ('Uruguay'), ('Venezuela'), ('China'), ('Estados Unidos');

    WHILE @i <= @NumberOfRecords
    BEGIN
        -- Seleccionar un país aleatorio
        SELECT TOP 1 @NameCountry = Name FROM @Countries ORDER BY NEWID();
        -- Insertar el registro
        INSERT INTO Country (name)
        VALUES (@NameCountry);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCountry;

    -- Verificar el estado de la transacción
    IF XACT_STATE() = 1 -- 1 significa que la transacción es válida
    BEGIN
        RAISERROR('CORRECTO: InsertRandomCountry', 0, 1) WITH NOWAIT;
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        RAISERROR('Transacción inválida, haciendo rollback', 0, 1) WITH NOWAIT;
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 -- Si es -1 o 1, la transacción debe hacer rollback
    BEGIN
        ROLLBACK TRANSACTION;
    END
    
    -- Mostrar mensaje de error detallado
    DECLARE @ErrorMessage NVARCHAR(4000);
    SET @ErrorMessage = ERROR_MESSAGE();
    RAISERROR('Error al ejecutar los procedimientos InsertRandomCountry: %s', 16, 1, @ErrorMessage) WITH NOWAIT;
END CATCH;

GO


CREATE PROCEDURE InsertRandomCity
    @NumberOfRecords INT = 50 -- Ajusta según necesidad
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @NameCity NVARCHAR(100);
    DECLARE @RandomCountryID INT;
    DECLARE @Cities TABLE (Name NVARCHAR(100));

    -- Insertar una lista de ciudades comunes
    INSERT INTO @Cities (Name)
    VALUES 
        ('Buenos Aires'), ('São Paulo'), ('Toronto'), ('Copenhague'), ('Madrid'),
        ('París'), ('Berlín'), ('Budapest'), ('Mumbai'), ('Tokio'),
        ('Ciudad de México'), ('Oslo'), ('Lima'), ('Moscú'), ('Estocolmo'),
        ('Estambul'), ('Montevideo'), ('Caracas'), ('Beijing'), ('Nueva York');

    WHILE @i <= @NumberOfRecords
    BEGIN
        -- Seleccionar una ciudad aleatoria
        SELECT TOP 1 @NameCity = Name FROM @Cities ORDER BY NEWID();
        -- Seleccionar un país aleatorio existente
        SELECT TOP 1 @RandomCountryID = id FROM Country ORDER BY NEWID();

        -- Insertar el registro
        INSERT INTO City (name, country_id)
        VALUES (@NameCity, @RandomCountryID);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCity

    PRINT 'CORRECTO: InsertRandomCity';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCity: ' + ERROR_MESSAGE();
END CATCH;

GO

CREATE PROCEDURE InsertRandomAirport
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomNameAirport NVARCHAR(100);
    DECLARE @RandomCityID BIGINT;

    -- Tablas temporales para nombres de aeropuertos comunes
    DECLARE @AirportNames TABLE (NameAirport NVARCHAR(100));

    -- Insertar nombres de aeropuertos comunes
    INSERT INTO @AirportNames (NameAirport)
    VALUES ('John F. Kennedy International Airport'), ('Los Angeles International Airport'), ('Chicago Hare International Airport'), ('Dallas/Fort Worth International Airport'), ('Denver International Airport');

 
    DECLARE @CityIDs TABLE (CityID BIGINT);
    INSERT INTO @CityIDs (CityID)
    SELECT id FROM City;

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un nombre de aeropuerto aleatorio
        SELECT TOP 1 @RandomNameAirport = NameAirport FROM @AirportNames ORDER BY NEWID();

        -- Seleccionar un ID de ciudad aleatorio de los IDs válidos
        SELECT TOP 1 @RandomCityID = CityID FROM @CityIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Airport (name_airport, city_id)
        VALUES (@RandomNameAirport, @RandomCityID);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomAirport;

    PRINT 'CORRECTO: InsertRandomAirport';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomAirport: ' + ERROR_MESSAGE();
END CATCH

GO
--drop procedure InsertRandomFlightNumber
CREATE PROCEDURE InsertRandomFlightNumber
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomDepartureTime DATETIME;
    DECLARE @RandomDescriptionFlight NVARCHAR(100);
    DECLARE @RandomAirportStartID BIGINT;
    DECLARE @RandomAirportGoalID BIGINT;

    -- Tablas temporales para descripciones de vuelos comunes
    DECLARE @FlightDescriptions TABLE (DescriptionFlight NVARCHAR(100));
    INSERT INTO @FlightDescriptions (DescriptionFlight)
    VALUES ('Flight to New York'), ('Flight to Los Angeles'), ('Flight to Chicago'), ('Flight to Dallas'), ('Flight to Denver');

    -- Obtener todos los IDs de aeropuertos válidos
    DECLARE @AirportIDs TABLE (AirportID BIGINT);
    INSERT INTO @AirportIDs (AirportID)
    SELECT id FROM Airport;

    WHILE @i <= 300
    BEGIN
        -- Generar una hora de salida aleatoria
        SET @RandomDepartureTime = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 1440, GETDATE());
        -- Seleccionar una descripción de vuelo aleatoria
        SELECT TOP 1 @RandomDescriptionFlight = DescriptionFlight FROM @FlightDescriptions ORDER BY NEWID();

        -- Seleccionar IDs de aeropuertos de inicio y destino aleatorios, asegurando que sean diferentes
        SELECT TOP 1 @RandomAirportStartID = AirportID FROM @AirportIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomAirportGoalID = AirportID FROM @AirportIDs ORDER BY NEWID();
        
        WHILE @RandomAirportStartID = @RandomAirportGoalID
        BEGIN
            SELECT TOP 1 @RandomAirportGoalID = AirportID FROM @AirportIDs ORDER BY NEWID();
        END

        -- Insertar el registro en la tabla Flight_Number
        INSERT INTO Flight_Number (departure_time, description_flight, airport_start_id, airport_goal_id)
        VALUES (@RandomDepartureTime, @RandomDescriptionFlight, @RandomAirportStartID, @RandomAirportGoalID);

        SET @i = @i + 1;
    END
END;


GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomFlightNumber;

    PRINT 'CORRECTO: InsertRandomFlightNumber';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomFlightNumber: ' + ERROR_MESSAGE();
END CATCH

GO
-- Procedimiento para insertar datos en Plane_Model
CREATE PROCEDURE InsertRandomPlaneModel
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomDescription NVARCHAR(100);
    DECLARE @RandomGraphic NVARCHAR(100);
    DECLARE @RandomSeatAmount INT;

    -- Tablas temporales para descripciones y gráficos comunes de modelos de avión
    DECLARE @PlaneModelDescriptions TABLE (Description NVARCHAR(100), Graphic NVARCHAR(100), SeatAmount INT);

    -- Insertar descripciones, gráficos y cantidad de asientos comunes
    INSERT INTO @PlaneModelDescriptions (Description, Graphic, SeatAmount)
    VALUES 
        ('Boeing 737', '737.png', 160),
        ('Airbus A320', 'A320.png', 150),
        ('Boeing 787', '787.png', 250),
        ('Airbus A380', 'A380.png', 555),
        ('Embraer E190', 'E190.png', 100);

    WHILE @i <= 50
    BEGIN
        -- Seleccionar una descripción, gráfico y cantidad de asientos aleatorio
        SELECT TOP 1 @RandomDescription = Description, @RandomGraphic = Graphic, @RandomSeatAmount = SeatAmount 
        FROM @PlaneModelDescriptions ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Plane_Model (description, seat_amount, graphic)
        VALUES (@RandomDescription, @RandomSeatAmount, @RandomGraphic);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPlaneModel;

    PRINT 'CORRECTO: InsertRandomPlaneModel';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPlaneModel: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomAirplane
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomRegistrationNumber BIGINT;
    DECLARE @RandomStatus NVARCHAR(100);
    DECLARE @RandomPlaneModelID BIGINT;

    -- Tablas temporales para estados comunes de aviones
    DECLARE @AirplaneStatuses TABLE (Status NVARCHAR(100));

    -- Insertar estados comunes
    INSERT INTO @AirplaneStatuses (Status)
    VALUES ('Active'), ('Maintenance'), ('Retired'), ('Stored');

    -- Obtener todos los IDs de modelos de avión válidos
    DECLARE @PlaneModelIDs TABLE (PlaneModelID BIGINT);
    INSERT INTO @PlaneModelIDs (PlaneModelID)
    SELECT id FROM Plane_Model;

    WHILE @i <= 50
    BEGIN
        -- Generar un número de registro aleatorio
        SET @RandomRegistrationNumber = ABS(CHECKSUM(NEWID())) % 100000 + 1000;

        -- Seleccionar un estado aleatorio
        SELECT TOP 1 @RandomStatus = Status FROM @AirplaneStatuses ORDER BY NEWID();

        -- Seleccionar un ID de modelo de avión aleatorio de los IDs válidos
        SELECT TOP 1 @RandomPlaneModelID = PlaneModelID FROM @PlaneModelIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Airplane (registration_number, Status, plane_model_id)
        VALUES (@RandomRegistrationNumber, @RandomStatus, @RandomPlaneModelID);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomAirplane;

    PRINT 'CORRECTO: InsertRandomAirplane';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomAirplane: ' + ERROR_MESSAGE();
END CATCH

GO
-- Procedimiento para insertar datos en Flight
--drop procedure InsertRandomFlight
CREATE PROCEDURE InsertRandomFlight
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomBoardingTime DATETIME;
    DECLARE @RandomFlightDate DATE;
    DECLARE @RandomGate NVARCHAR(100);
    DECLARE @RandomCheckInCounter INT;
    DECLARE @RandomTypeFlightID INT;
    DECLARE @RandomStatusFlightID INT;
    DECLARE @RandomFlightNumberID INT; 
    DECLARE @RandomAirplaneID INT; 

    -- Tablas temporales para nombres de puertas comunes
    DECLARE @GateNames TABLE (Gate NVARCHAR(100));
    INSERT INTO @GateNames (Gate)
    VALUES ('A1'), ('B2'), ('C3'), ('D4'), ('E5');

    -- Obtener todos los IDs de vuelos, tipos de vuelo, estados de vuelo y aviones válidos
    DECLARE @FlightNumberIDs TABLE (FlightNumberID INT);
    DECLARE @TypeFlightIDs TABLE (TypeFlightID INT);
    DECLARE @StatusFlightIDs TABLE (StatusFlightID INT);
    DECLARE @AirplaneIDs TABLE (AirplaneID INT);

    INSERT INTO @FlightNumberIDs (FlightNumberID)
    SELECT id FROM Flight_Number;

    INSERT INTO @TypeFlightIDs (TypeFlightID)
    SELECT id FROM Type_Flight;

    INSERT INTO @StatusFlightIDs (StatusFlightID)
    SELECT id FROM Status_Flight;

    INSERT INTO @AirplaneIDs (AirplaneID)
    SELECT id FROM Airplane;

    WHILE @i <= 2000
    BEGIN
        -- Generar una fecha de vuelo aleatoria en el futuro
        SET @RandomFlightDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365 + 1, CAST(GETDATE() AS DATE));
        
        -- Generar una hora de embarque aleatoria en el futuro (misma fecha de vuelo)
        SET @RandomBoardingTime = DATEADD(MINUTE, ABS(CHECKSUM(NEWID())) % 1440, CAST(@RandomFlightDate AS DATETIME));

        -- Seleccionar un nombre de puerta aleatorio
        SELECT TOP 1 @RandomGate = Gate FROM @GateNames ORDER BY NEWID();
        
        -- Generar un número de mostrador de check-in aleatorio
        SET @RandomCheckInCounter = ABS(CHECKSUM(NEWID())) % 100 + 1;

        -- Seleccionar IDs de vuelo, tipo de vuelo, estado de vuelo y avión aleatorios de los IDs válidos
        SELECT TOP 1 @RandomFlightNumberID = FlightNumberID FROM @FlightNumberIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomTypeFlightID = TypeFlightID FROM @TypeFlightIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomStatusFlightID = StatusFlightID FROM @StatusFlightIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomAirplaneID = AirplaneID FROM @AirplaneIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla Flight
        INSERT INTO Flight (boarding_time, flight_date, gate, check_in_counter, type_flight_id, status_flight_id, flight_number_id, airplane_id)
        VALUES (@RandomBoardingTime, @RandomFlightDate, @RandomGate, @RandomCheckInCounter, @RandomTypeFlightID, @RandomStatusFlightID, @RandomFlightNumberID, @RandomAirplaneID);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomFlight;

    PRINT 'CORRECTO: InsertRandomFlight';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomFlight: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomBooking
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @RandomBookingDate DATE;
    DECLARE @RandomCustomerID BIGINT;
    DECLARE @RandomBookingStatusID BIGINT;
    DECLARE @RandomTicketsCant INT;
    DECLARE @FlightID BIGINT;

    -- Obtener todos los IDs válidos de clientes, estados de reserva y vuelos
    DECLARE @CustomerIDs TABLE (CustomerID BIGINT);
    DECLARE @BookingStatusIDs TABLE (BookingStatusID BIGINT);
    DECLARE @FlightIDs TABLE (FlightID BIGINT);

    INSERT INTO @CustomerIDs (CustomerID)
    SELECT id FROM Customer;

    INSERT INTO @BookingStatusIDs (BookingStatusID)
    SELECT id FROM Booking_Status;

    INSERT INTO @FlightIDs (FlightID)
    SELECT id FROM Flight;

    -- Iterar por cada vuelo y generar 5 reservas por vuelo
    DECLARE FlightCursor CURSOR FOR SELECT FlightID FROM @FlightIDs;
    OPEN FlightCursor;

    FETCH NEXT FROM FlightCursor INTO @FlightID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @i INT = 1;

        WHILE @i <= 5
        BEGIN
            -- Generar una fecha de reserva aleatoria
            SET @RandomBookingDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());

            -- Seleccionar IDs aleatorios de clientes y estados de reserva
            SELECT TOP 1 @RandomCustomerID = CustomerID FROM @CustomerIDs ORDER BY NEWID();
            SELECT TOP 1 @RandomBookingStatusID = BookingStatusID FROM @BookingStatusIDs ORDER BY NEWID();

            -- Generar una cantidad aleatoria de tickets entre 3 y 10
            SET @RandomTicketsCant = ABS(CHECKSUM(NEWID())) % 8 + 3;

            -- Insertar el registro en la tabla de reservas con el ID del vuelo
            INSERT INTO Booking (booking_date, customer_id, booking_status_id, tickets_cant, flight_id)
            VALUES (@RandomBookingDate, @RandomCustomerID, @RandomBookingStatusID, @RandomTicketsCant, @FlightID);

            SET @i = @i + 1;
        END;

        FETCH NEXT FROM FlightCursor INTO @FlightID;
    END;

    CLOSE FlightCursor;
    DEALLOCATE FlightCursor;
END;


GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomBooking;

    PRINT 'CORRECTO: InsertRandomBooking';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomBooking: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomTicket
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookingID INT;
    DECLARE @TicketsCant INT;
    DECLARE @RandomNumber BIGINT;
    DECLARE @RandomTicketingCode BIGINT;
    DECLARE @RandomTicketCategoryID INT;
    DECLARE @RandomStatusTicketID INT;

    -- Obtener todos los IDs válidos de categorías de tickets y estados de tickets
    DECLARE @TicketCategoryIDs TABLE (TicketCategoryID INT);
    DECLARE @StatusTicketIDs TABLE (StatusTicketID INT);

    -- Insertar los IDs de categorías de tickets y estados de tickets en las tablas temporales
    INSERT INTO @TicketCategoryIDs (TicketCategoryID)
    SELECT id FROM Ticket_Category;

    INSERT INTO @StatusTicketIDs (StatusTicketID)
    SELECT id FROM Status_Ticket;

    -- Obtener todos los bookings y sus cantidades de tickets
    DECLARE @Bookings CURSOR;
    SET @Bookings = CURSOR FOR
    SELECT id, tickets_cant FROM Booking;

    OPEN @Bookings;
    FETCH NEXT FROM @Bookings INTO @BookingID, @TicketsCant;

    -- Recorrer cada reserva y generar la cantidad de tickets correspondiente
    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @i INT = 1;

        -- Insertar la cantidad de tickets especificada en tickets_cant para cada reserva
        WHILE @i <= @TicketsCant
        BEGIN
            -- Generar un número de ticket y código de ticketing aleatorios
            SET @RandomNumber = ABS(CHECKSUM(NEWID())) % 1000000000;

            -- Generar un código de ticketing dentro del rango permitido
            SET @RandomTicketingCode = ABS(CHECKSUM(NEWID())) % 1000000;
            IF @RandomTicketingCode < 100000 -- Asegúrate de que el código esté en el rango permitido
            BEGIN
                SET @RandomTicketingCode = @RandomTicketingCode + 100000;
            END

            -- Seleccionar IDs aleatorios de categorías de tickets y estados de tickets
            SELECT TOP 1 @RandomTicketCategoryID = TicketCategoryID FROM @TicketCategoryIDs ORDER BY NEWID();
            SELECT TOP 1 @RandomStatusTicketID = StatusTicketID FROM @StatusTicketIDs ORDER BY NEWID();

            -- Insertar el ticket en la tabla Ticket
            INSERT INTO Ticket (number, ticketing_code, ticket_category_id, status_ticket_id, booking_id)
            VALUES (@RandomNumber, @RandomTicketingCode, @RandomTicketCategoryID, @RandomStatusTicketID, @BookingID);

            SET @i = @i + 1;
        END

        -- Obtener el siguiente registro de la tabla Booking
        FETCH NEXT FROM @Bookings INTO @BookingID, @TicketsCant;
    END

    -- Cerrar y liberar el cursor
    CLOSE @Bookings;
    DEALLOCATE @Bookings;
END

go
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTicket;

    PRINT 'CORRECTO: InsertRandomTicket';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTicket: ' + ERROR_MESSAGE();
END CATCH

GO
--drop procedure InsertRandomCoupon

CREATE PROCEDURE InsertRandomCoupon
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomDateOfRedemption DATE;
    DECLARE @RandomClass NVARCHAR(100);
    DECLARE @RandomStandBy NVARCHAR(100);
    DECLARE @RandomMealCode INT;

    -- Tablas temporales para clases y estados de stand-by comunes
    DECLARE @Classes TABLE (Class NVARCHAR(100));
    DECLARE @StandBys TABLE (StandBy NVARCHAR(100));
    INSERT INTO @Classes (Class)
    VALUES ('Economy'), ('Business'), ('First Class');
    INSERT INTO @StandBys (StandBy)
    VALUES ('Yes'), ('No');

    -- Generar e insertar todos los cupones en una sola operación
    INSERT INTO Coupon (date_of_redemption, class, stand_by, meal_code, ticket_id, flight_id)
    SELECT
        DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE()) AS date_of_redemption,
        (SELECT TOP 1 Class FROM @Classes ORDER BY NEWID()) AS class,
        (SELECT TOP 1 StandBy FROM @StandBys ORDER BY NEWID()) AS stand_by,
        ABS(CHECKSUM(NEWID())) % 1000 AS meal_code,
        t.id AS ticket_id,           -- Referencia a ticket_id correctamente
        b.flight_id                  -- Referencia a flight_id correctamente
    FROM Ticket t
    JOIN Booking b ON t.booking_id = b.id
    ORDER BY t.id;  -- Asegura que se inserten los cupones en el orden de los tickets
END


go

BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomCoupon;

    PRINT 'CORRECTO: InsertRandomCoupon';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCoupon: ' + ERROR_MESSAGE();
END CATCH
GO



CREATE PROCEDURE InsertRandomBookingFlight
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomBookingID INT;
    DECLARE @RandomFlightID INT;

    -- Obtener todos los IDs válidos de reservas y vuelos
    DECLARE @BookingIDs TABLE (BookingID INT);
    DECLARE @FlightIDs TABLE (FlightID INT);

    INSERT INTO @BookingIDs (BookingID)
    SELECT id FROM Booking;

    INSERT INTO @FlightIDs (FlightID)
    SELECT id FROM Flight;

    -- Almacenar las combinaciones insertadas
    DECLARE @InsertedCombinations TABLE (BookingID INT, FlightID INT);

    DECLARE @TotalBookings INT = (SELECT COUNT(*) FROM @BookingIDs);
    DECLARE @TotalFlights INT = (SELECT COUNT(*) FROM @FlightIDs);
    DECLARE @i INT = 1;

    -- Intentar insertar 5 relaciones únicas por cada reserva
    WHILE @i <= (@TotalBookings * 5)
    BEGIN
        -- Seleccionar un ID aleatorio de reservas y un ID aleatorio de vuelos
        SELECT TOP 1 @RandomBookingID = BookingID FROM @BookingIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomFlightID = FlightID FROM @FlightIDs ORDER BY NEWID();

        -- Comprobar si la combinación ya ha sido insertada
        IF NOT EXISTS (
            SELECT 1 FROM @InsertedCombinations 
            WHERE BookingID = @RandomBookingID AND FlightID = @RandomFlightID
        )
        BEGIN
            -- Insertar la combinación en la tabla intermedia
            INSERT INTO Booking_Flight (booking_id, flight_id)
            VALUES (@RandomBookingID, @RandomFlightID);
            
            -- Almacenar la combinación insertada
            INSERT INTO @InsertedCombinations (BookingID, FlightID)
            VALUES (@RandomBookingID, @RandomFlightID);
        END

        SET @i = @i + 1;
    END
END;



GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomBookingFlight;

    PRINT 'CORRECTO: InsertRandomBookingFlight';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomBookingFlight: ' + ERROR_MESSAGE();
END CATCH

GO


CREATE PROCEDURE InsertRandomGate
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomName NVARCHAR(100);
    DECLARE @RandomLocation NVARCHAR(100);
    DECLARE @RandomGateAssignmentStatusID BIGINT;
    DECLARE @RandomAirportID BIGINT;

    -- Tablas temporales para nombres y ubicaciones comunes de puertas
    DECLARE @GateNames TABLE (Name NVARCHAR(100));
    DECLARE @GateLocations TABLE (Location NVARCHAR(100));

    -- Insertar nombres y ubicaciones comunes
    INSERT INTO @GateNames (Name)
    VALUES ('Gate A1'), ('Gate B2'), ('Gate C3'), ('Gate D4'), ('Gate E5');
    INSERT INTO @GateLocations (Location)
    VALUES ('North Terminal'), ('South Terminal'), ('East Terminal'), ('West Terminal'), ('Central Terminal');

    -- Obtener todos los IDs válidos de estados de asignación de puertas y aeropuertos
    DECLARE @GateAssignmentStatusIDs TABLE (GateAssignmentStatusID BIGINT);
    DECLARE @AirportIDs TABLE (AirportID BIGINT);
    INSERT INTO @GateAssignmentStatusIDs (GateAssignmentStatusID)
    SELECT id FROM Gate_Assignment_Status;
    INSERT INTO @AirportIDs (AirportID)
    SELECT id FROM Airport;

    WHILE @i <= 50
    BEGIN
        -- Seleccionar un nombre y ubicación aleatoria
        SELECT TOP 1 @RandomName = Name FROM @GateNames ORDER BY NEWID();
        SELECT TOP 1 @RandomLocation = Location FROM @GateLocations ORDER BY NEWID();

        -- Seleccionar IDs aleatorios de estados de asignación de puertas y aeropuertos
        SELECT TOP 1 @RandomGateAssignmentStatusID = GateAssignmentStatusID FROM @GateAssignmentStatusIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomAirportID = AirportID FROM @AirportIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Gate (name, location, gate_assignment_status_id, airport_id)
        VALUES (@RandomName, @RandomLocation, @RandomGateAssignmentStatusID, @RandomAirportID);

        SET @i = @i + 1;
    END
END
GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomGate;

    PRINT 'CORRECTO: InsertRandomGate';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomGate: ' + ERROR_MESSAGE();
END CATCH
go
--modificado
CREATE PROCEDURE InsertRandomTypePerson
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar solo los dos tipos de personas en la tabla
    INSERT INTO Type_Person (name_type)
    VALUES ('Passenger'), ('employee');
END
GO

go
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTypePerson;

    PRINT 'CORRECTO: InsertRandomTypePerson';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTypePerson: ' + ERROR_MESSAGE();
END CATCH
go
-- Procedimiento para insertar datos en Person
--drop procedure InsertRandomPerson
CREATE PROCEDURE InsertRandomPerson
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @RandomFirstName NVARCHAR(100);
    DECLARE @RandomLastName NVARCHAR(100);
    DECLARE @RandomPhoneNumber NVARCHAR(100);
    DECLARE @RandomEmail NVARCHAR(100);
    DECLARE @RandomNationality NVARCHAR(100);
    DECLARE @RandomTypePersonID BIGINT;
    DECLARE @RandomPasajeroID BIGINT;
    DECLARE @RandomTripulanteID BIGINT;

    -- Tablas temporales para nombres, apellidos y nacionalidades comunes
    DECLARE @FirstNames TABLE (FirstName NVARCHAR(100));
    DECLARE @LastNames TABLE (LastName NVARCHAR(100));
    DECLARE @Nationalities TABLE (Nationality NVARCHAR(100));

    -- Insertar nombres, apellidos y nacionalidades comunes
    -- Insertar 300 nombres comunes
INSERT INTO @FirstNames (FirstName)
VALUES 
    ('John'), ('Jane'), ('Michael'), ('Emily'), ('David'), ('Sarah'), ('James'), ('Anna'), ('Robert'), ('Olivia'), 
    ('Daniel'), ('Sophia'), ('William'), ('Mia'), ('Joseph'), ('Isabella'), ('Matthew'), ('Emma'), ('Andrew'), ('Charlotte'),
    ('Joshua'), ('Amelia'), ('Christopher'), ('Harper'), ('Benjamin'), ('Evelyn'), ('Alexander'), ('Abigail'), ('Samuel'), 
    ('Ava'), ('Jacob'), ('Lily'), ('Ryan'), ('Grace'), ('Nathan'), ('Victoria'), ('Anthony'), ('Madison'), ('Jonathan'), 
    ('Ella'), ('Justin'), ('Scarlett'), ('Tyler'), ('Zoey'), ('Ethan'), ('Aria'), ('Nicholas'), ('Nora'), ('Christian'), 
    ('Hazel'), ('Brandon'), ('Penelope'), ('Jason'), ('Aurora'), ('Logan'), ('Camila'), ('Gabriel'), ('Stella'), ('Connor'), 
    ('Lucy'), ('Dylan'), ('Hannah'), ('Zachary'), ('Ellie'), ('Isaac'), ('Paisley'), ('Owen'), ('Savannah'), ('Henry'), 
    ('Audrey'), ('Aaron'), ('Brooklyn'), ('Lucas'), ('Bella'), ('Adrian'), ('Riley'), ('Charles'), ('Ruby'), ('Austin'), 
    ('Alice'), ('Jordan'), ('Serenity'), ('Cameron'), ('Layla'), ('Thomas'), ('Caroline'), ('Caleb'), ('Aubrey'), ('Jack'), 
    ('Mila'), ('Sean'), ('Violet'), ('Jake'), ('Peyton'), ('Nathaniel'), ('Ariana'), ('Chase'), ('Claire'), ('Elijah'), 
    ('Lillian'), ('Isaiah'), ('Samantha'), ('Cole'), ('Genesis'), ('Blake'), ('Natalie'), ('Carson'), ('Elena'), ('Hunter'), 
    ('Autumn'), ('Mason'), ('Everly'), ('Jaxon'), ('Aurora'), ('Bryan'), ('Naomi'), ('Max'), ('Cora'), ('Vincent'), ('Willow'),
    ('Grant'), ('Zoey'), ('Oscar'), ('Maya'), ('Leo'), ('Sadie'), ('Micah'), ('Josephine'), ('Harrison'), ('Isabelle'), 
    ('Jude'), ('Delilah'), ('Beckett'), ('Elise'), ('Elliot'), ('Emery'), ('Sebastian'), ('Maria'), ('Jasper'), ('Margaret'),
    ('Tristan'), ('Josie'), ('Aidan'), ('Brielle'), ('Miles'), ('Adeline'), ('Grayson'), ('Ruth'), ('Axel'), ('Lydia'),
    ('Xavier'), ('Madeline'), ('Bentley'), ('Vivian'), ('Sawyer'), ('Ivy'), ('Gavin'), ('Brynlee'), ('Brody'), ('Adalyn'),
    ('Declan'), ('Arya'), ('Rowan'), ('Raelynn'), ('Jaden'), ('Bailey'), ('Tucker'), ('Isla'), ('Wesley'), ('Emerson'),
    ('Silas'), ('Iris'), ('Kayden'), ('Eden'), ('Damian'), ('Jocelyn'), ('Ryder'), ('Ember'), ('Landon'), ('River'),
    ('Braxton'), ('Sawyer'), ('Preston'), ('June'), ('Evan'), ('Sloane'), ('Griffin'), ('Remi'), ('Kai'), ('Blake'),
    ('Bentlee'), ('Wren'), ('Colt'), ('Dakota'), ('Maddox'), ('Ashlyn'), ('Jace'), ('Nova'), ('Ronin'), ('Rosalie'), 
    ('Kyler'), ('Scarlett'), ('Bodie'), ('Ayla'), ('Emmett'), ('Adriana'), ('Gage'), ('Ariella'), ('Holden'), ('Daphne'), 
    ('Finn'), ('Brooklynn'), ('Gunner'), ('Selena'), ('Ronan'), ('Haven'), ('Reid'), ('Ainsley'), ('Simon'), ('Aspen'),
    ('Troy'), ('Lexi'), ('Andre'), ('Avianna'), ('Gideon'), ('Blair'), ('Trenton'), ('Holly'), ('Emmanuel'), ('Journey'),
    ('Santiago'), ('Addisyn'), ('Zane'), ('Skye'), ('Alec'), ('Cecilia'), ('Kian'), ('Gracie'), ('Malachi'), ('Madilynn'),
    ('Barrett'), ('Lena'), ('Jayce'), ('Scarlette'), ('Jensen'), ('Allie'), ('Niko'), ('Everleigh'), ('Armando'), ('Mackenzie');

-- Insertar 500 apellidos comunes
INSERT INTO @LastNames (LastName)
VALUES 
    ('Smith'), ('Johnson'), ('Williams'), ('Brown'), ('Jones'), ('Garcia'), ('Martinez'), ('Taylor'), ('Anderson'), ('Thomas'), 
    ('Jackson'), ('White'), ('Harris'), ('Clark'), ('Lewis'), ('Robinson'), ('Walker'), ('Perez'), ('Hall'), ('Young'),
    ('Allen'), ('Sanchez'), ('Wright'), ('King'), ('Scott'), ('Green'), ('Baker'), ('Adams'), ('Nelson'), ('Carter'),
    ('Mitchell'), ('Perez'), ('Roberts'), ('Turner'), ('Phillips'), ('Campbell'), ('Parker'), ('Evans'), ('Edwards'), 
    ('Collins'), ('Stewart'), ('Morris'), ('Morales'), ('Murphy'), ('Cook'), ('Rogers'), ('Gutierrez'), ('Ortiz'), 
    ('Morgan'), ('Cooper'), ('Peterson'), ('Bailey'), ('Reed'), ('Kelly'), ('Howard'), ('Ramos'), ('Kim'), ('Cox'),
    ('Ward'), ('Richardson'), ('Watson'), ('Brooks'), ('Chavez'), ('Wood'), ('James'), ('Bennett'), ('Gray'), ('Mendoza'),
    ('Ruiz'), ('Hughes'), ('Price'), ('Alvarez'), ('Castillo'), ('Sanders'), ('Patel'), ('Myers'), ('Long'), ('Ross'),
    ('Foster'), ('Jimenez'), ('Powell'), ('Jenkins'), ('Perry'), ('Russell'), ('Sullivan'), ('Bell'), ('Coleman'), 
    ('Butler'), ('Henderson'), ('Barnes'), ('Gonzales'), ('Fisher'), ('Vasquez'), ('Simmons'), ('Romero'), ('Jordan'), 
    ('Patterson'), ('Alexander'), ('Hamilton'), ('Graham'), ('Reynolds'), ('Griffin'), ('Wallace'), ('Moreno'), 
    ('West'), ('Cole'), ('Hayes'), ('Bryant'), ('Herrera'), ('Gibson'), ('Ellis'), ('Tran'), ('Medina'), ('Aguilar'),
    ('Stevens'), ('Murray'), ('Ford'), ('Castro'), ('Marshall'), ('Owens'), ('Harrison'), ('Fernandez'), ('McDonald'), 
    ('Woods'), ('Washington'), ('Kennedy'), ('Wells'), ('Vargas'), ('Henry'), ('Chen'), ('Freeman'), ('Webb'), ('Tucker'),
    ('Guzman'), ('Burns'), ('Crawford'), ('Olson'), ('Simpson'), ('Porter'), ('Hunter'), ('Gordon'), ('Mendez'), ('Silva'),
    ('Shaw'), ('Snyder'), ('Mason'), ('Dixon'), ('Munoz'), ('Hunt'), ('Hicks'), ('Holmes'), ('Palmer'), ('Wagner'), 
    ('Black'), ('Robertson'), ('Boyd'), ('Rose'), ('Stone'), ('Salazar'), ('Fox'), ('Warren'), ('Mills'), ('Meyer'),
    ('Rice'), ('Schmidt'), ('Garza'), ('Daniels'), ('Ferguson'), ('Nichols'), ('Stephens'), ('Soto'), ('Weaver'), 
    ('Ryan'), ('Gardner'), ('Payne'), ('Grant'), ('Dunn'), ('Kelley'), ('Spencer'), ('Hawkins'), ('Arnold'), 
    ('Pierce'), ('Vazquez'), ('Hansen'), ('Peters'), ('Santos'), ('Hart'), ('Bradley'), ('Knight'), ('Elliott'), 
    ('Cunningham'), ('Duncan'), ('Armstrong'), ('Hudson'), ('Carroll'), ('Lane'), ('Riley'), ('Andrews'), ('Alvarado'), 
    ('Ray'), ('Delgado'), ('Berry'), ('Perkins'), ('Hoffman'), ('Johnston'), ('Matthews'), ('Peña'), ('Richards'), 
    ('Contreras'), ('Willis'), ('Carpenter'), ('Lawrence'), ('Sandoval'), ('Guerrero'), ('George'), ('Chapman'), 
    ('Rios'), ('Estrada'), ('Ortega'), ('Watkins'), ('Greene'), ('Nunez'), ('Wheeler'), ('Valdez'), ('Harper'),
    ('Burke'), ('Larson'), ('Santiago'), ('Maldonado'), ('Morrison'), ('Franklin'), ('Carlson'), ('Austin'), 
    ('Dominguez'), ('Carrillo'), ('Rose'), ('Castaneda'), ('Luna'), ('Owens'), ('Shannon'), ('Park'), ('Blake'), 
    ('Morton'), ('Wang'), ('Wheeler'), ('Pruitt'), ('McIntosh'), ('Erickson'), ('Sharp'), ('Bowen'), ('Bush'), 
    ('Burch'), ('Frank'), ('Booth'), ('Keller'), ('Montoya'), ('Graves'), ('Copeland'), ('Poole'), ('Vaughn'), 
    ('Horton'), ('Farmer'), ('Stokes'), ('Blanchard'), ('Becker'), ('Schroeder'), ('Mann'), ('Lawson'), ('Valencia'), 
    ('Franco'), ('Brooks'), ('Crane'), ('Bowers'), ('Whitney'), ('Baxter'), ('Foley'), ('Reilly'), ('Holder'), ('Chan');

-- Puedes continuar agregando más nombres y apellidos de la misma manera

    INSERT INTO @Nationalities (Nationality)
    VALUES 
        ('American'), ('British'), ('Canadian'), ('Australian'), ('German'),
        ('Argentinian'), ('Bolivian'), ('Brazilian'), ('Chilean'), ('Colombian'),
        -- agregar más nacionalidades aquí según sea necesario
        ('Chinese'), ('Japanese'), ('South Korean');

    -- Obtener el ID de tipo de persona para 'Passenger' y 'employee'
    DECLARE @PassengerTypePersonID BIGINT = (SELECT id FROM Type_Person WHERE name_type = 'Passenger');
    DECLARE @EmployeeTypePersonID BIGINT = (SELECT id FROM Type_Person WHERE name_type = 'employee');

    -- Obtener todos los IDs válidos de pasajeros y tripulantes
    DECLARE @PasajeroIDs TABLE (PasajeroID BIGINT);
    DECLARE @TripulanteIDs TABLE (TripulanteID BIGINT);
    INSERT INTO @PasajeroIDs (PasajeroID)
    SELECT id FROM Pasajero;
    INSERT INTO @TripulanteIDs (TripulanteID)
    SELECT id FROM Tripulante;

    -- Inserción de 1500 pasajeros sin nombres repetidos
    WHILE @i <= 1500
    BEGIN
        -- Seleccionar un nombre, apellido y nacionalidad aleatorios
        SELECT TOP 1 @RandomFirstName = FirstName FROM @FirstNames ORDER BY NEWID();
        SELECT TOP 1 @RandomLastName = LastName FROM @LastNames ORDER BY NEWID();
        SELECT TOP 1 @RandomNationality = Nationality FROM @Nationalities ORDER BY NEWID();

        -- Generar un número de teléfono y correo electrónico aleatorio
        SET @RandomPhoneNumber = CAST(ABS(CHECKSUM(NEWID())) % 1000000000 AS NVARCHAR(100));
        SET @RandomEmail = LOWER(@RandomFirstName + '.' + @RandomLastName + '@example.com');

        -- Seleccionar un ID de pasajero aleatorio
        SELECT TOP 1 @RandomPasajeroID = PasajeroID FROM @PasajeroIDs ORDER BY NEWID();

        -- Evitar nombres repetidos
        IF NOT EXISTS (
            SELECT 1 
            FROM Person 
            WHERE first_name = @RandomFirstName AND last_name = @RandomLastName
        )
        BEGIN
            -- Insertar el registro en la tabla con el ID de tipo "Passenger"
            INSERT INTO Person (first_name, last_name, phone_number, email, nacionality, type_person_id, pasajero_id, tripulante_id)
            VALUES (@RandomFirstName, @RandomLastName, @RandomPhoneNumber, @RandomEmail, @RandomNationality, @PassengerTypePersonID, @RandomPasajeroID, NULL);

            SET @i = @i + 1;
        END
    END

    -- Resetear el contador para los empleados
    SET @i = 1;

    -- Inserción de 500 empleados sin nombres repetidos
    WHILE @i <= 500
    BEGIN
        -- Seleccionar un nombre, apellido y nacionalidad aleatorios
        SELECT TOP 1 @RandomFirstName = FirstName FROM @FirstNames ORDER BY NEWID();
        SELECT TOP 1 @RandomLastName = LastName FROM @LastNames ORDER BY NEWID();
        SELECT TOP 1 @RandomNationality = Nationality FROM @Nationalities ORDER BY NEWID();

        -- Generar un número de teléfono y correo electrónico aleatorio
        SET @RandomPhoneNumber = CAST(ABS(CHECKSUM(NEWID())) % 1000000000 AS NVARCHAR(100));
        SET @RandomEmail = LOWER(@RandomFirstName + '.' + @RandomLastName + '@example.com');

        -- Seleccionar un ID de tripulante aleatorio
        SELECT TOP 1 @RandomTripulanteID = TripulanteID FROM @TripulanteIDs ORDER BY NEWID();

        -- Evitar nombres repetidos
        IF NOT EXISTS (
            SELECT 1 
            FROM Person 
            WHERE first_name = @RandomFirstName AND last_name = @RandomLastName
        )
        BEGIN
            -- Insertar el registro en la tabla con el ID de tipo "employee"
            INSERT INTO Person (first_name, last_name, phone_number, email, nacionality, type_person_id, pasajero_id, tripulante_id)
            VALUES (@RandomFirstName, @RandomLastName, @RandomPhoneNumber, @RandomEmail, @RandomNationality, @EmployeeTypePersonID, NULL, @RandomTripulanteID);

            SET @i = @i + 1;
        END
    END
END;
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPerson;

    PRINT 'CORRECTO: InsertRandomPerson';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPerson: ' + ERROR_MESSAGE();
END CATCH
go
GO
--drop procedure InsertRandomPasajero
CREATE PROCEDURE InsertRandomPasajero
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomGenero NVARCHAR(100);
    DECLARE @PersonId INT;

    -- Tablas temporales para géneros comunes
    DECLARE @Generos TABLE (Genero NVARCHAR(100));

    -- Insertar géneros comunes
    INSERT INTO @Generos (Genero)
    VALUES ('Masculino'), ('Femenino'), ('Otro');

    -- Recorrer cada persona de tipo "Passenger"
    DECLARE cur CURSOR FOR
    SELECT id FROM Person WHERE type_person_id = (SELECT id FROM Type_Person WHERE name_type = 'Passenger');

    OPEN cur;
    FETCH NEXT FROM cur INTO @PersonId;

    -- Para cada persona de tipo "Passenger", insertar un registro en Pasajero
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Seleccionar un género aleatorio
        SELECT TOP 1 @RandomGenero = Genero FROM @Generos ORDER BY NEWID();

        -- Insertar el registro en la tabla Pasajero (sin especificar la columna 'id' ya que es una columna Identity)
        INSERT INTO Pasajero (genero, id_person)
        VALUES (@RandomGenero, @PersonId);

        FETCH NEXT FROM cur INTO @PersonId;
    END

    CLOSE cur;
    DEALLOCATE cur;
END

GO


GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPasajero;

    PRINT 'CORRECTO: InsertRandomPasajero';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPasajero: ' + ERROR_MESSAGE();
END CATCH

GO
-- Procedimiento para insertar datos en Tripulante
--drop procedure InsertRandomTripulante
CREATE PROCEDURE InsertRandomTripulante
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PersonId INT;
    DECLARE @CodidoTripulante INT;

    -- Cursor para recorrer todas las personas de tipo "Employee"
    DECLARE cur CURSOR FOR
    SELECT id FROM Person WHERE type_person_id = (SELECT id FROM Type_Person WHERE name_type = 'Employee');

    OPEN cur;
    FETCH NEXT FROM cur INTO @PersonId;

    -- Para cada persona de tipo "Employee", insertar un registro en Tripulante
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar un código de tripulante aleatorio
        SET @CodidoTripulante = ROUND(RAND() * 1000, 0) + 1;  -- Genera un valor aleatorio mayor que 0

        -- Insertar el registro en la tabla Tripulante (sin especificar la columna 'id' ya que es una columna Identity)
        INSERT INTO Tripulante (codido_tripulante, id_person)
        VALUES (@CodidoTripulante, @PersonId);

        FETCH NEXT FROM cur INTO @PersonId;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;

GO


go

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomTripulante;

    PRINT 'CORRECTO: InsertRandomTripulante';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomTripulante: ' + ERROR_MESSAGE();
END CATCH

GO
-------------------------------------------------------------------------------------------------------
--drop procedure InsertRandomRolTripulante
CREATE PROCEDURE InsertRandomRolTripulante
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar roles de tripulantes comunes directamente en la tabla Rol_Tripulante
    INSERT INTO Rol_Tripulante (name_rol)
    VALUES ('Pilot'), 
           ('Co-Pilot'), 
           ('Flight Attendant'), 
           ('Engineer');
END;
GO
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomRolTripulante;

    PRINT 'CORRECTO: InsertRandomRolTripulante';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomRolTripulante: ' + ERROR_MESSAGE();
END CATCH

GO
--drop procedure InsertRandomAsingnacionTripulantes
CREATE PROCEDURE InsertRandomAsignacionTripulantes
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomAssignmentDate DATE;
    DECLARE @RandomRolTripulanteID INT;
    DECLARE @RandomTripulanteID INT;
    DECLARE @RandomFlightID INT;
    DECLARE @RandomHoursAmount INT;

    -- Tablas temporales para obtener IDs válidos
    DECLARE @RolTripulanteIDs TABLE (RolTripulanteID INT);
    DECLARE @TripulanteIDs TABLE (TripulanteID INT);
    DECLARE @FlightIDs TABLE (FlightID INT);

    -- Obtener todos los IDs válidos de roles de tripulantes, tripulantes y vuelos
    INSERT INTO @RolTripulanteIDs (RolTripulanteID)
    SELECT id FROM Rol_Tripulante;
    
    INSERT INTO @TripulanteIDs (TripulanteID)
    SELECT id FROM Tripulante;
    
    INSERT INTO @FlightIDs (FlightID)
    SELECT id FROM Flight;

    -- Recorrer cada vuelo y asignar un tripulante y un rol
    DECLARE cur CURSOR FOR
    SELECT id FROM Flight;

    OPEN cur;
    FETCH NEXT FROM cur INTO @RandomFlightID;

    -- Para cada vuelo, insertar un registro en Asignacion_Tripulantes
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar una fecha de asignación aleatoria
        SET @RandomAssignmentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, GETDATE());

        -- Seleccionar aleatoriamente un rol de tripulante, un tripulante y un vuelo
        SELECT TOP 1 @RandomRolTripulanteID = RolTripulanteID FROM @RolTripulanteIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomTripulanteID = TripulanteID FROM @TripulanteIDs ORDER BY NEWID();

        -- Generar un valor aleatorio para hours_amount (por ejemplo, entre 1 y 12 horas)
        SET @RandomHoursAmount = ABS(CHECKSUM(NEWID())) % 12 + 1;

        -- Insertar el registro en Asignacion_Tripulantes
        INSERT INTO Asignacion_Tripulantes (assignment_date, rol_tripulante_id, tripulante_id, flight_id, hours_amount)
        VALUES (@RandomAssignmentDate, @RandomRolTripulanteID, @RandomTripulanteID, @RandomFlightID, @RandomHoursAmount);

        FETCH NEXT FROM cur INTO @RandomFlightID;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO

GO
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomAsignacionTripulantes;

    PRINT 'CORRECTO: InsertRandomAsingnacionTripulantes';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomAsingnacionTripulantes: ' + ERROR_MESSAGE();
END CATCH


go
CREATE PROCEDURE InsertRandomGateAssignment
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomAssignmentDate DATE;
    DECLARE @RandomGateID BIGINT;
    DECLARE @RandomFlightID BIGINT;

    -- Obtener todos los IDs válidos de puertas, escalas y vuelos
    DECLARE @GateIDs TABLE (GateID BIGINT);
    DECLARE @FlightIDs TABLE (FlightID BIGINT);
    INSERT INTO @GateIDs (GateID)
    SELECT id FROM Gate;
    INSERT INTO @FlightIDs (FlightID)
    SELECT id FROM Flight;

    WHILE @i <= 50
    BEGIN
        -- Generar una fecha de asignación aleatoria
        SET @RandomAssignmentDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());

        -- Seleccionar IDs aleatorios de puertas, escalas y vuelos
        SELECT TOP 1 @RandomGateID = GateID FROM @GateIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomFlightID = FlightID FROM @FlightIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Gate_Assignment (assignment_date, gate_id, flight_id)
        VALUES (@RandomAssignmentDate, @RandomGateID, @RandomFlightID);

        SET @i = @i + 1;
    END
END
GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomGateAssignment;

    PRINT 'CORRECTO: InsertRandomGateAssignment';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomGateAssignment: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomDocument
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomIssueDate DATE;
    DECLARE @RandomDueDate DATE;
    DECLARE @RandomExpirationDate DATE;
    DECLARE @RandomDocumentNumber BIGINT;
    DECLARE @RandomTypeDocumentID BIGINT;
    DECLARE @RandomPersonID BIGINT;
    DECLARE @RandomCountryID BIGINT;

    -- Obtener todos los IDs válidos de tipos de documento, personas y países
    DECLARE @TypeDocumentIDs TABLE (TypeDocumentID BIGINT);
    DECLARE @PersonIDs TABLE (PersonID BIGINT);
    DECLARE @CountryIDs TABLE (CountryID BIGINT);
    INSERT INTO @TypeDocumentIDs (TypeDocumentID)
    SELECT id FROM Type_Document;
    INSERT INTO @PersonIDs (PersonID)
    SELECT id FROM Person;
    INSERT INTO @CountryIDs (CountryID)
    SELECT id FROM Country;

    WHILE @i <= 50
    BEGIN
        -- Generar fechas de emisión, vencimiento y expiración aleatorias
        SET @RandomIssueDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());
        SET @RandomDueDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, @RandomIssueDate);
        SET @RandomExpirationDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, @RandomDueDate);

        -- Generar un número de documento aleatorio
        SET @RandomDocumentNumber = ABS(CHECKSUM(NEWID())) % 1000000000;

        -- Seleccionar IDs aleatorios de tipos de documento, personas y paísesexpiration_date
        SELECT TOP 1 @RandomTypeDocumentID = TypeDocumentID FROM @TypeDocumentIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomPersonID = PersonID FROM @PersonIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomCountryID = CountryID FROM @CountryIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla
        INSERT INTO Document (issue_date, due_date, document_number, expiration_date, type_document_id, person_id, country_id)
        VALUES (@RandomIssueDate, @RandomDueDate, @RandomDocumentNumber, @RandomExpirationDate, @RandomTypeDocumentID, @RandomPersonID, @RandomCountryID);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomDocument;

    PRINT 'CORRECTO: InsertRandomDocument';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomDocument: ' + ERROR_MESSAGE();
END CATCH

GO


-- Procedimiento para insertar datos en Method_Type
CREATE PROCEDURE InsertRandomMethodType
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar los tres métodos de pago directamente
    INSERT INTO Method_Type (method_name)
    VALUES 
        ('Cash'), 
        ('Transferencia Bancaria'), 
        ('Tarjeta de crédito');
END;

GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomMethodType;

    PRINT 'CORRECTO: InsertRandomMethodType';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomMethodType: ' + ERROR_MESSAGE();
END CATCH
GO

CREATE PROCEDURE InsertRandomPaymentMethod
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @method_type_id INT;
    DECLARE @description NVARCHAR(255);
    DECLARE @methodCount INT;

    -- Obtener el número de métodos de pago
    SELECT @methodCount = COUNT(*) FROM Method_Type;

    -- Obtener todos los IDs y nombres de los métodos de pago
    DECLARE @MethodTypes TABLE (id INT, method_name NVARCHAR(255));
    INSERT INTO @MethodTypes (id, method_name)
    SELECT id, method_name FROM Method_Type;

    -- Iterar por cada método de pago y agregar un registro en Payment_Method
    WHILE @i <= @methodCount
    BEGIN
        SELECT @method_type_id = id, @description = method_name 
        FROM @MethodTypes 
        WHERE id = @i;
        
        -- Insertar el registro en la tabla Payment_Method
        INSERT INTO Payment_Method (description, method_type_id)
        VALUES (@description, @method_type_id);
        
        SET @i = @i + 1;
    END
END;


GO

BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPaymentMethod;

    PRINT 'CORRECTO: InsertRandomPaymentMethod';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPaymentMethod: ' + ERROR_MESSAGE();
END CATCH

GO

-- Procedimiento para insertar datos en Payment

CREATE PROCEDURE InsertRandomPayment
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @date_payment DATE;
    DECLARE @amount INT;
    DECLARE @payment_status_id INT;
    DECLARE @booking_id INT;
    DECLARE @payment_method_id INT;

    -- Iterar sobre cada booking_id en la tabla Booking
    DECLARE BookingCursor CURSOR FOR
        SELECT id FROM Booking;

    OPEN BookingCursor;
    FETCH NEXT FROM BookingCursor INTO @booking_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar datos aleatorios para cada pago
        SET @date_payment = DATEADD(DAY, -ROUND(RAND() * 365, 0), GETDATE());
        SET @amount = ROUND(RAND() * 1000, 0) + 1; -- Genera un valor aleatorio mayor que 0
        SELECT TOP 1 @payment_status_id = id FROM Payment_Status ORDER BY NEWID();
        SELECT TOP 1 @payment_method_id = id FROM Payment_Method ORDER BY NEWID();

        -- Insertar el registro en la tabla Payment
        INSERT INTO Payment (date_payment, amount, payment_status_id, booking_id, payment_method_id)
        VALUES (@date_payment, @amount, @payment_status_id, @booking_id, @payment_method_id);

        FETCH NEXT FROM BookingCursor INTO @booking_id;
    END

    CLOSE BookingCursor;
    DEALLOCATE BookingCursor;
END;
GO

GO
BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomPayment;

    PRINT 'CORRECTO: InsertRandomPayment';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPayment'
END CATCH
GO
--modificamos

CREATE PROCEDURE InsertRandomCurrencyAssignment
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomAssignmentDate DATE;
    DECLARE @RandomCurrencyID BIGINT;
    DECLARE @PaymentID BIGINT;

    -- Obtener todos los IDs válidos de monedas
    DECLARE @CurrencyIDs TABLE (CurrencyID BIGINT);
    INSERT INTO @CurrencyIDs (CurrencyID)
    SELECT id FROM Currency;

    -- Cursor para iterar sobre cada registro de Payment
    DECLARE PaymentCursor CURSOR FOR
        SELECT id FROM Payment;

    OPEN PaymentCursor;
    FETCH NEXT FROM PaymentCursor INTO @PaymentID;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar una fecha de asignación aleatoria
        SET @RandomAssignmentDate = DATEADD(DAY, ABS(CHECKSUM(NEWID())) % 365, GETDATE());

        -- Seleccionar un ID aleatorio de moneda
        SELECT TOP 1 @RandomCurrencyID = CurrencyID FROM @CurrencyIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla Currency_Assignment
        INSERT INTO Currency_Assignment (assignment_date, currency_id, payment_id)
        VALUES (@RandomAssignmentDate, @RandomCurrencyID, @PaymentID);

        FETCH NEXT FROM PaymentCursor INTO @PaymentID;
    END

    CLOSE PaymentCursor;
    DEALLOCATE PaymentCursor;
END;
GO

GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCurrencyAssignment;

    PRINT 'CORRECTO: InsertRandomCurrencyAssignment';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCurrencyAssignment: ' + ERROR_MESSAGE();
END CATCH

GO 

CREATE PROCEDURE InsertRandomCancellationBookin
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @i INT = 1;
    DECLARE @RandomCancellationDate DATE;
    DECLARE @RandomCancellationReason NVARCHAR(255);
    DECLARE @RandomPenaltyCancellationID BIGINT;
    DECLARE @RandomBookingID BIGINT;

    -- Tablas temporales para razones de cancelación comunes
    DECLARE @CancellationReasons TABLE (CancellationReason NVARCHAR(255));
    INSERT INTO @CancellationReasons (CancellationReason)
    VALUES ('Weather issues'), ('Personal reasons'), ('Technical problems'), ('Schedule changes');

    -- Obtener todos los IDs válidos de penalizaciones de cancelación y reservas
    DECLARE @PenaltyCancellationIDs TABLE (PenaltyCancellationID BIGINT);
    DECLARE @BookingIDs TABLE (BookingID BIGINT);
    INSERT INTO @PenaltyCancellationIDs (PenaltyCancellationID)
    SELECT id FROM Penalty_Cancellation;
    INSERT INTO @BookingIDs (BookingID)
    SELECT id FROM Booking;

    WHILE @i <= 50
    BEGIN
        -- Generar una fecha de cancelación aleatoria
        SET @RandomCancellationDate = DATEADD(DAY, -ABS(CHECKSUM(NEWID())) % 365, GETDATE());

        -- Seleccionar una razón de cancelación aleatoria
        SELECT TOP 1 @RandomCancellationReason = CancellationReason FROM @CancellationReasons ORDER BY NEWID();

        -- Seleccionar IDs aleatorios de penalizaciones de cancelación y reservas
        SELECT TOP 1 @RandomPenaltyCancellationID = PenaltyCancellationID FROM @PenaltyCancellationIDs ORDER BY NEWID();
        SELECT TOP 1 @RandomBookingID = BookingID FROM @BookingIDs ORDER BY NEWID();

        -- Insertar el registro en la tabla con un ID único
        INSERT INTO Cancellation_Booking (cancellation_date, cancellation_reason, penalty_cancellation_id, booking_id)
        VALUES (@RandomCancellationDate, @RandomCancellationReason, @RandomPenaltyCancellationID, @RandomBookingID);

        SET @i = @i + 1;
    END
END
GO



BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomCancellationBookin;

    PRINT 'CORRECTO: InsertRandomCancellationBookin';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCancellationBookin: ' + ERROR_MESSAGE();
END CATCH

GO
CREATE PROCEDURE InsertRandomStatusSeat
AS
BEGIN
    SET NOCOUNT ON;

    -- Verificar e insertar el estado 'Disponible' si no existe
    IF NOT EXISTS (SELECT 1 FROM Status_Seat WHERE status_name = 'Disponible')
    BEGIN
        INSERT INTO Status_Seat (status_name)
        VALUES ('Disponible');
    END

    -- Verificar e insertar el estado 'No disponible' si no existe
    IF NOT EXISTS (SELECT 1 FROM Status_Seat WHERE status_name = 'No disponible')
    BEGIN
        INSERT INTO Status_Seat (status_name)
        VALUES ('No disponible');
    END
END;
GO


BEGIN TRANSACTION;

BEGIN TRY
    EXEC InsertRandomStatusSeat;

    PRINT 'CORRECTO: InsertRandomStatusSeat';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomStatusSeat: ' + ERROR_MESSAGE();
END CATCH

GO
--este se modifico

CREATE PROCEDURE InsertRandomSeat
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @RandomSize NVARCHAR(255);
    DECLARE @RandomNumber INT;
    DECLARE @RandomPlaneID INT;
    DECLARE @SeatCount INT;
    DECLARE @RandomStatusID INT;

    -- Tablas temporales para tamaños comunes de asientos
    DECLARE @SeatSizes TABLE (Size NVARCHAR(255));
    INSERT INTO @SeatSizes (Size)
    VALUES ('Small'), ('Medium'), ('Large');

    -- Obtener todos los IDs y cantidades de asientos de los modelos de avión
    DECLARE @PlaneIDs TABLE (PlaneID INT, SeatAmount INT);
    INSERT INTO @PlaneIDs (PlaneID, SeatAmount)
    SELECT id, seat_amount FROM Plane_Model;

    -- Obtener todos los IDs válidos de estados de asiento
    DECLARE @StatusSeatIDs TABLE (StatusSeatID INT);
    INSERT INTO @StatusSeatIDs (StatusSeatID)
    SELECT id FROM Status_Seat;

    -- Bucle para recorrer cada modelo de avión
    DECLARE plane_cursor CURSOR FOR
        SELECT PlaneID, SeatAmount FROM @PlaneIDs;

    OPEN plane_cursor;

    FETCH NEXT FROM plane_cursor INTO @RandomPlaneID, @SeatCount;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE @i INT = 1;

        -- Insertar asientos según la cantidad de asientos de cada modelo
        WHILE @i <= @SeatCount
        BEGIN
            -- Seleccionar un tamaño de asiento aleatorio
            SELECT TOP 1 @RandomSize = Size FROM @SeatSizes ORDER BY NEWID();

            -- Generar un número de asiento aleatorio
            SET @RandomNumber = ABS(CHECKSUM(NEWID())) % 100 + 1;

            -- Seleccionar un ID de estado de asiento aleatorio
            SELECT TOP 1 @RandomStatusID = StatusSeatID FROM @StatusSeatIDs ORDER BY NEWID();

            -- Insertar el registro en la tabla Seat con un ID de estado aleatorio
            INSERT INTO Seat (size, number, plane_model_id, status_seat_id)
            VALUES (@RandomSize, @RandomNumber, @RandomPlaneID, @RandomStatusID);

            SET @i = @i + 1;
        END

        FETCH NEXT FROM plane_cursor INTO @RandomPlaneID, @SeatCount;
    END;

    CLOSE plane_cursor;
    DEALLOCATE plane_cursor;
END;



GO

BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomSeat;

    PRINT 'CORRECTO: InsertRandomSeat';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomSeat: ' + ERROR_MESSAGE();
END CATCH

GO

-- Procedimiento para insertar datos en Pieces_of_Luggage 
--drop procedure InsertRandomPiecesOfLuggage
go
CREATE PROCEDURE InsertRandomPiecesOfLuggage 
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @weight_of_pieces DECIMAL(5, 2);
    DECLARE @amount_luggages BIGINT;
    DECLARE @total_rate BIGINT;
    DECLARE @coupon_id INT;

    -- Crear un cursor para recorrer todos los cupones
    DECLARE @CouponCursor CURSOR;
    SET @CouponCursor = CURSOR FOR
    SELECT id FROM Coupon;

    OPEN @CouponCursor;
    FETCH NEXT FROM @CouponCursor INTO @coupon_id;

    -- Recorrer todos los cupones y generar un registro en Pieces_of_Luggage para cada uno
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar valores aleatorios para los campos de Pieces_of_Luggage
        SET @weight_of_pieces = ROUND(RAND() * 50, 2);
        SET @amount_luggages = ROUND(RAND() * 5, 0);
        SET @total_rate = ROUND(RAND() * 1000, 0);

        -- Insertar el registro en Pieces_of_Luggage
        INSERT INTO Pieces_of_Luggage (weight_of_pieces, amount_luggages, total_rate, coupon_id)
        VALUES (@weight_of_pieces, @amount_luggages, @total_rate, @coupon_id);

        -- Obtener el siguiente cupón
        FETCH NEXT FROM @CouponCursor INTO @coupon_id;
    END

    -- Cerrar y liberar el cursor
    CLOSE @CouponCursor;
    DEALLOCATE @CouponCursor;
END;

go
BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomPiecesOfLuggage;

    PRINT 'CORRECTO: InsertRandomPiecesOfLuggage';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomPiecesOfLuggage: ' + ERROR_MESSAGE();
END CATCH
GO

-- Procedimiento para insertar datos en Check_In_Luggage
--este modifique en 11/07/2024
--truncate table Check_In_Luggage
--drop procedure InsertRandomCheckInLuggage
CREATE PROCEDURE InsertRandomCheckInLuggage
AS
BEGIN
    DECLARE @checking_date DATE;
    DECLARE @status NVARCHAR(50);
    DECLARE @pieces_of_luggage_id INT;

    -- Cursor para recorrer cada registro de Pieces_of_Luggage
    DECLARE luggage_cursor CURSOR FOR
    SELECT id FROM Pieces_of_Luggage;

    OPEN luggage_cursor;
    FETCH NEXT FROM luggage_cursor INTO @pieces_of_luggage_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Generar una fecha aleatoria en el último año
        SET @checking_date = DATEADD(DAY, -ROUND(RAND() * 365, 0), GETDATE());

        -- Elegir aleatoriamente entre 'Arrived' y 'Lost'
        SET @status = CASE WHEN RAND() < 0.5 THEN 'Arrived' ELSE 'Lost' END;

        -- Insertar el registro en Check_In_Luggage
        INSERT INTO Check_In_Luggage (checking_date, status, pieces_of_luggage_id)
        VALUES (@checking_date, @status, @pieces_of_luggage_id);

        -- Avanzar al siguiente registro
        FETCH NEXT FROM luggage_cursor INTO @pieces_of_luggage_id;
    END;

    -- Cerrar y liberar el cursor
    CLOSE luggage_cursor;
    DEALLOCATE luggage_cursor;
END;



GO
BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomCheckInLuggage;

    PRINT 'CORRECTO: InsertRandomCheckInLuggage';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomCheckInLuggage: ' + ERROR_MESSAGE();
END CATCH
GO

-- Procedimiento para insertar datos en Airline_Assignment
--drop procedure InsertRandomAirlineAssignment
CREATE PROCEDURE InsertRandomAirlineAssignment
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @assignment_date DATE;
    DECLARE @description NVARCHAR(255);
    DECLARE @flight_id INT;
    DECLARE @airline_id INT;

    -- Crear una tabla temporal para almacenar los vuelos asignados
    CREATE TABLE #AssignedFlights (flight_id INT PRIMARY KEY);

    -- Seleccionar todos los vuelos disponibles
    DECLARE flight_cursor CURSOR FOR
    SELECT id FROM Flight;

    OPEN flight_cursor;

    FETCH NEXT FROM flight_cursor INTO @flight_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Verificar si el vuelo ya ha sido asignado
        IF NOT EXISTS (SELECT 1 FROM #AssignedFlights WHERE flight_id = @flight_id)
        BEGIN
            -- Generar una fecha de asignación aleatoria en el pasado
            SET @assignment_date = DATEADD(DAY, -ROUND(RAND() * 365, 0), GETDATE());

            -- Seleccionar una descripción aleatoria para la asignación
            SET @description = (SELECT TOP 1 descripcion FROM (
                VALUES ('Asignación A'), ('Asignación B'), ('Asignación C'), ('Asignación D'), ('Asignación E')
            ) AS TempDescripciones(descripcion) ORDER BY NEWID());

            -- Seleccionar una aerolínea aleatoria
            SET @airline_id = (SELECT TOP 1 id FROM Airline ORDER BY NEWID());

            -- Insertar el registro en la tabla Airline_Assignment
            INSERT INTO Airline_Assignment (assignment_date, description, flight_id, airline_id)
            VALUES (@assignment_date, @description, @flight_id, @airline_id);

            -- Marcar el vuelo como asignado
            INSERT INTO #AssignedFlights (flight_id) VALUES (@flight_id);
        END

        FETCH NEXT FROM flight_cursor INTO @flight_id;
    END

    CLOSE flight_cursor;
    DEALLOCATE flight_cursor;

    -- Limpiar la tabla temporal
    DROP TABLE #AssignedFlights;
END;



GO 
BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomAirlineAssignment;

    PRINT 'CORRECTO: InsertarRandomAirlineAssignment';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertarRandomAirlineAssignment: ' + ERROR_MESSAGE();
END CATCH

GO

-- Procedimiento para insertar datos en Document_Submission
CREATE PROCEDURE InsertRandomDocumentSubmission
AS
BEGIN
    DECLARE @id INT = (SELECT ISNULL(MAX(id), 0) + 1 FROM Document_Submission);
    DECLARE @assignment_date DATE = DATEADD(DAY, -ROUND(RAND() * 365, 0), GETDATE());
    DECLARE @person_id INT = (SELECT TOP 1 id FROM Person ORDER BY NEWID());
    DECLARE @ticket_id INT = (SELECT TOP 1 id FROM Ticket ORDER BY NEWID());
    DECLARE @document_id INT = (SELECT TOP 1 id FROM Document ORDER BY NEWID());

    INSERT INTO Document_Submission (assignment_date, person_id, ticket_id, document_id)
    VALUES (@assignment_date, @person_id, @ticket_id, @document_id);
END;

GO

BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomDocumentSubmission;

    PRINT 'CORRECTO: InsertRandomDocumentSubmission';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomDocumentSubmission: ' + ERROR_MESSAGE();
END CATCH
GO

-- Procedimiento para insertar datos en Luggage
CREATE PROCEDURE InsertRandomLuggage
AS
BEGIN
    DECLARE @id BIGINT = (SELECT ISNULL(MAX(id), 0) + 1 FROM Luggage);
    DECLARE @dimensions NVARCHAR(100) = '50x40x20';
    DECLARE @weight DECIMAL(5, 2) = ROUND(RAND() * 30, 2);
    DECLARE @pieces_of_luggage_id BIGINT = (SELECT TOP 1 id FROM Pieces_of_Luggage ORDER BY NEWID());
	DECLARE @type_of_luggages_id BIGINT = (SELECT TOP 1 id FROM Types_of_Luggages ORDER BY NEWID());

    INSERT INTO Luggage (dimensions, weight, pieces_of_luggage_id, type_of_luggages_id)
    VALUES (@dimensions, @weight, @pieces_of_luggage_id, @type_of_luggages_id);
END;

GO


BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomLuggage;

    PRINT 'CORRECTO: InsertRandomLuggage';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomLuggage: ' + ERROR_MESSAGE();
END CATCH
GO

-- Procedimiento para insertar datos en Flight_Cancellation
CREATE PROCEDURE InsertRandomFlightCancellation
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @i INT = 1;
    DECLARE @id BIGINT;
    DECLARE @cancellation_time DATETIME;
    DECLARE @cancellation_reason NVARCHAR(255) = 'Weather';
    DECLARE @responsible_party NVARCHAR(255) = 'Airline';
    DECLARE @flight_number BIGINT;
    DECLARE @compensation_detail BIGINT;

    WHILE @i <= 50
    BEGIN
        SET @id = (SELECT ISNULL(MAX(id), 0) + 1 FROM Flight_Cancellation);
        SET @cancellation_time = DATEADD(HOUR, -ROUND(RAND() * 1000, 0), GETDATE());
        SET @flight_number = (SELECT TOP 1 id FROM Flight_Number ORDER BY NEWID());
        SET @compensation_detail = (SELECT TOP 1 id FROM Compensation_Detail ORDER BY NEWID());

        INSERT INTO Flight_Cancellation (cancellation_time, cancellation_reason, responsible_party, flight_number, compensation_detail)
        VALUES (@cancellation_time, @cancellation_reason, @responsible_party, @flight_number, @compensation_detail);

        SET @i = @i + 1;
    END
END;

GO

BEGIN TRANSACTION

BEGIN TRY
    EXEC InsertRandomFlightCancellation;

    PRINT 'CORRECTO: InsertRandomFlightCancellation';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al ejecutar los procedimientos InsertRandomFlightCancellation: ' + ERROR_MESSAGE();
END CATCH
GO
