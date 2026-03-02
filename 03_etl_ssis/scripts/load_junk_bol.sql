USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_BorrowedLent','U') IS NULL
    CREATE TABLE dbo.Stg_BorrowedLent (
        Borrowing_ID INT,
        Artwork_ID VARCHAR(20),
        Institution VARCHAR(100),
        Start_date DATE,
        End_date VARCHAR(20),
        Status VARCHAR(50),
        Borrowed INT,
        Lent INT,
        Owned INT
    );
GO

TRUNCATE TABLE dbo.Stg_BorrowedLent;
GO

BEGIN TRY
    BULK INSERT dbo.Stg_BorrowedLent
    FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DW\Borrowed_orLent.csv'
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
    ;WITH DistinctStatuses AS (
        SELECT DISTINCT
            Status,
            CAST(Borrowed AS BIT) AS Borrowed,
            CAST(Lent AS BIT) AS Lent,
            CAST(Owned AS BIT) AS Owned
        FROM dbo.Stg_BorrowedLent
        WHERE Status IS NOT NULL
    )
    MERGE INTO Junk_Borrowing AS target
    USING DistinctStatuses AS source
    ON target.Status = source.Status
       AND target.Borrowed = source.Borrowed
       AND target.Lent = source.Lent
       AND target.Owned = source.Owned
    
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (Status, Borrowed, Lent, Owned)
        VALUES (source.Status, source.Borrowed, source.Lent, source.Owned);
    
    PRINT CONCAT('MERGE operation completed. ', @@ROWCOUNT, ' rows affected');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE operation: ' + ERROR_MESSAGE();
    
    SELECT TOP 10 Status, Borrowed, Lent, Owned 
    FROM dbo.Stg_BorrowedLent
    WHERE Status IS NOT NULL;
END CATCH
GO


--DROP TABLE IF EXISTS Stg_BorrowedLent;
SELECT * FROM Junk_Borrowing;
GO