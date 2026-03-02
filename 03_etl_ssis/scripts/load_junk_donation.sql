USE Museum_DW;
GO
 
IF OBJECT_ID('dbo.Stg_Donations','U') IS NULL
    CREATE TABLE dbo.Stg_Donations (
        INVOICE_NUMBER VARCHAR(20),
        Amount DECIMAL(18,2),
        Date_of_donation DATE,
        Purpose VARCHAR(100),
        Artwork_ID VARCHAR(20),
        Patron_PESEL VARCHAR(20)
    );
GO

TRUNCATE TABLE dbo.Stg_Donations;
GO

BEGIN TRY
    BULK INSERT dbo.Stg_Donations
    FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DW\Donations.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );
    
    PRINT 'BULK INSERT completed successfully';
END TRY
BEGIN CATCH
    PRINT 'Error during BULK INSERT: ' + ERROR_MESSAGE();
    RETURN;
END CATCH
GO

BEGIN TRY
    ;WITH DistinctPurposes AS (
        SELECT DISTINCT
            Purpose
        FROM dbo.Stg_Donations
        WHERE Purpose IS NOT NULL
    )
    MERGE INTO Junk_Donation AS target
    USING DistinctPurposes AS source
    ON target.Purpose = source.Purpose
    
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Purpose)
        VALUES (source.Purpose);
    
    PRINT CONCAT('MERGE operation completed. ', @@ROWCOUNT, ' rows affected');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE operation: ' + ERROR_MESSAGE();
    
    SELECT TOP 10 Purpose
    FROM dbo.Stg_Donations
    WHERE Purpose IS NOT NULL;
END CATCH
GO

--DROP TABLE IF EXISTS Stg_Donations;
SELECT * FROM Junk_Donation;
GO