USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_Institution', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_Institution (
        Name VARCHAR(100),
        Prestige NUMERIC,
        Country VARCHAR(50),
        City VARCHAR(50),
        District VARCHAR(50),
        Street VARCHAR(50)
    );
END;
GO

TRUNCATE TABLE dbo.Stg_Institution;
GO

BEGIN TRY
    BULK INSERT dbo.Stg_Institution
    FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DW\Institutions.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'BULK INSERT into Stg_Institution completed';
END TRY
BEGIN CATCH
    PRINT 'Error during BULK INSERT: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    MERGE INTO Institution AS target
    USING (
        SELECT DISTINCT *
        FROM dbo.Stg_Institution
        WHERE Name IS NOT NULL
    ) AS source
    ON target.Name = source.Name

    WHEN MATCHED AND (
           ISNULL(target.Prestige, -1) <> ISNULL(source.Prestige, -1)
        OR ISNULL(target.Country, '') <> ISNULL(source.Country, '')
        OR ISNULL(target.City, '') <> ISNULL(source.City, '')
        OR ISNULL(target.District, '') <> ISNULL(source.District, '')
        OR ISNULL(target.Street, '') <> ISNULL(source.Street, '')
    )
    THEN UPDATE SET
        target.Prestige = source.Prestige,
        target.Country = source.Country,
        target.City = source.City,
        target.District = source.District,
        target.Street = source.Street

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Name, Prestige, Country, City, District, Street)
        VALUES (source.Name, source.Prestige, source.Country, source.City, source.District, source.Street);

    PRINT CONCAT('MERGE completed. ', @@ROWCOUNT, ' institutions inserted or updated.');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_Institution;
END CATCH;
GO

SELECT COUNT(*) AS TotalInstitutions FROM Institution;
GO
