USE Museum_DW;
GO

IF OBJECT_ID('dbo.Stg_A_B_L', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_A_B_L (
        Borrowing_ID INT,
        Artist_PESEL VARCHAR(11)
    );
END;
GO

TRUNCATE TABLE dbo.Stg_A_B_L;
GO

BEGIN TRY
    BULK INSERT dbo.Stg_A_B_L
    FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DW\A_B_L.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );
    PRINT 'BULK INSERT into Stg_A_B_L completed';
END TRY
BEGIN CATCH
    PRINT ' Error during BULK INSERT: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    ;WITH Resolved AS (
        SELECT
            b.Borrowing_ID,
            a.ID_Artist
        FROM dbo.Stg_A_B_L s
        INNER JOIN Borrowed_or_lent b ON s.Borrowing_ID = b.Borrowing_ID
        INNER JOIN Artist a ON s.Artist_PESEL = a.PESEL
    )
    INSERT INTO A_B_L (ID_Borrowing, ID_Artist)
    SELECT r.Borrowing_ID, r.ID_Artist
    FROM Resolved r
    WHERE NOT EXISTS (
        SELECT 1 FROM A_B_L ab
        WHERE ab.ID_Borrowing = r.Borrowing_ID AND ab.ID_Artist = r.ID_Artist
    );

    PRINT CONCAT(' A_B_L bridge populated: ', @@ROWCOUNT, ' new rows inserted');
END TRY
BEGIN CATCH
    PRINT 'Error during INSERT: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_A_B_L;
END CATCH;
GO

SELECT COUNT(*) AS TotalBridgeRows FROM A_B_L;
GO
