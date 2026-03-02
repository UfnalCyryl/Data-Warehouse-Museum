USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_Patron', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_Patron (
        PESEL VARCHAR(11),
        Type VARCHAR(50),
        Phone_number VARCHAR(15),
        Address VARCHAR(255),
        Membership_status VARCHAR(50),
        Membership_level VARCHAR(50),
        Date_joined DATE,
        Name VARCHAR(50),
        Surname VARCHAR(50),
        Country VARCHAR(50),
        City VARCHAR(50),
        District VARCHAR(50),
        Street VARCHAR(50)
    );
END;
GO

TRUNCATE TABLE dbo.Stg_Patron;
GO

BEGIN TRY
    INSERT INTO dbo.Stg_Patron
    SELECT PESEL, Type, Phone_number, Address, Membership_status,
           Membership_level, Date_joined, Name, Surname,
           Country, City, District, Street
    FROM Museum_DB.dbo.Patron;

    PRINT 'Data loaded from Museum_DB.dbo.Patron into Stg_Patron.';
END TRY
BEGIN CATCH
    PRINT 'Error loading from Museum_DB.dbo.Patron: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    MERGE INTO dbo.Patron AS target
    USING (
        SELECT 
            PESEL,
            CONCAT(Name, ' ', Surname) AS Name_Surname,
            Type, Phone_number, Address, Membership_status,
            Membership_level, Date_joined, Country, City, District, Street
        FROM dbo.Stg_Patron
        WHERE PESEL IS NOT NULL
    ) AS source
    ON target.PESEL = source.PESEL

    WHEN MATCHED AND (
        ISNULL(target.Name_Surname, '') <> ISNULL(source.Name_Surname, '') OR
        ISNULL(target.Type, '') <> ISNULL(source.Type, '') OR
        ISNULL(target.Phone_number, '') <> ISNULL(source.Phone_number, '') OR
        ISNULL(target.Address, '') <> ISNULL(source.Address, '') OR
        ISNULL(target.Membership_status, '') <> ISNULL(source.Membership_status, '') OR
        ISNULL(target.Membership_level, '') <> ISNULL(source.Membership_level, '') OR
        ISNULL(target.Date_joined, '') <> ISNULL(source.Date_joined, '') OR
        ISNULL(target.Country, '') <> ISNULL(source.Country, '') OR
        ISNULL(target.City, '') <> ISNULL(source.City, '') OR
        ISNULL(target.District, '') <> ISNULL(source.District, '') OR
        ISNULL(target.Street, '') <> ISNULL(source.Street, '')
    )
    THEN UPDATE SET
        Name_Surname = source.Name_Surname,
        Type = source.Type,
        Phone_number = source.Phone_number,
        Address = source.Address,
        Membership_status = source.Membership_status,
        Membership_level = source.Membership_level,
        Date_joined = source.Date_joined,
        Country = source.Country,
        City = source.City,
        District = source.District,
        Street = source.Street

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (PESEL, Name_Surname, Type, Phone_number, Address, Membership_status,
                Membership_level, Date_joined, Country, City, District, Street)
        VALUES (source.PESEL, source.Name_Surname, source.Type, source.Phone_number, source.Address,
                source.Membership_status, source.Membership_level, source.Date_joined,
                source.Country, source.City, source.District, source.Street);

    PRINT CONCAT('MERGE completed: ', @@ROWCOUNT, ' rows inserted or updated in Patron.');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE into Patron: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_Patron;
END CATCH;
GO

SELECT COUNT(*) AS TotalPatrons FROM dbo.Patron;
GO
