USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_Artist', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_Artist (
        PESEL VARCHAR(11),
        Birth_year INT,
        Death_year INT,
        Nationality VARCHAR(100),
        Name VARCHAR(50),
        Surname VARCHAR(50)
    );
END;
GO

TRUNCATE TABLE dbo.Stg_Artist;
GO

BEGIN TRY
    INSERT INTO dbo.Stg_Artist (PESEL, Birth_year, Death_year, Nationality, Name, Surname)
    SELECT PESEL, Birth_year, Death_year, Nationality, Name, Surname
    FROM Museum_DB.dbo.Artist;

    PRINT 'Data successfully loaded from Museum_DB.dbo.Artist into Stg_Artist.';
END TRY
BEGIN CATCH
    PRINT 'Error during INSERT from Museum: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    MERGE INTO dbo.Artist AS target
    USING (
        SELECT 
            PESEL,
            CONCAT(Name, ' ', Surname) AS Name_Surname,
            CAST(Birth_year AS SMALLINT) AS Birth_year,
            CAST(Death_year AS SMALLINT) AS Death_year,
            Nationality
        FROM dbo.Stg_Artist
        WHERE PESEL IS NOT NULL
    ) AS source
    ON target.PESEL = source.PESEL

    WHEN MATCHED AND (
        ISNULL(target.Name_Surname, '') <> ISNULL(source.Name_Surname, '') OR
        ISNULL(target.Birth_year, -1) <> ISNULL(source.Birth_year, -1) OR
        ISNULL(target.Death_year, -1) <> ISNULL(source.Death_year, -1) OR
        ISNULL(target.Nationality, '') <> ISNULL(source.Nationality, '')
    )
    THEN UPDATE SET
        Name_Surname = source.Name_Surname,
        Birth_year = source.Birth_year,
        Death_year = source.Death_year,
        Nationality = source.Nationality

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (PESEL, Name_Surname, Birth_year, Death_year, Nationality)
        VALUES (source.PESEL, source.Name_Surname, source.Birth_year, source.Death_year, source.Nationality);

    PRINT CONCAT('MERGE completed: ', @@ROWCOUNT, ' rows inserted or updated in Artist.');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_Artist;
END CATCH;
GO

SELECT COUNT(*) AS TotalArtists FROM dbo.Artist;
GO
