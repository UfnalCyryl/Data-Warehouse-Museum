USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_BorrowedLent', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_BorrowedLent (
        Artwork_ID VARCHAR(50),       
        Institution VARCHAR(100),     
        Start_date DATE,               
        End_date VARCHAR(20),           
        Status VARCHAR(50),
        Borrowed INT,
        Lent INT,
        Owned INT
    );
END;
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
    PRINT 'BULK INSERT into Stg_BorrowedLent completed';
END TRY
BEGIN CATCH
    PRINT 'Error during BULK INSERT: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO


BEGIN TRY
    ;WITH Resolved AS (
        SELECT
            a.ID_Artwork,
			j.ID_Junk2,
            i.ID_Institution,
            d.ID_Date
        FROM dbo.Stg_BorrowedLent s
        INNER JOIN Artwork a 
            ON s.Artwork_ID = a.ARTWORK_AUTHENTICITY_CERT_NUM
        INNER JOIN Institution i 
            ON s.Institution = i.Name
        INNER JOIN Junk_Borrowing j 
            ON s.Status = j.Status
           AND CAST(s.Borrowed AS BIT) = j.Borrowed
           AND CAST(s.Lent AS BIT) = j.Lent
           AND CAST(s.Owned AS BIT) = j.Owned
        INNER JOIN [Date] d 
            ON s.Start_date = d.[Date]
    )
    INSERT INTO Borrowed_or_lent (
        ID_Artwork, ID_Junk2, ID_Institution, ID_Date
    )
    SELECT r.ID_Artwork, r.ID_Junk2, r.ID_Institution, r.ID_Date
    FROM Resolved r
    WHERE NOT EXISTS (
        SELECT 1
        FROM Borrowed_or_lent b
        WHERE b.ID_Artwork = r.ID_Artwork
          AND b.ID_Junk2 = r.ID_Junk2
          AND b.ID_Institution = r.ID_Institution
          AND b.ID_Date = r.ID_Date
    );

    PRINT CONCAT('Inserted ', @@ROWCOUNT, ' new rows into Borrowed_or_lent.');
END TRY
BEGIN CATCH
    PRINT 'Error during INSERT: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_BorrowedLent;
END CATCH;
GO


SELECT COUNT(*) AS TotalBorrowedLent FROM Borrowed_or_lent;
GO

