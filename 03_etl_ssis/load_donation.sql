USE Museum_DW;
GO
SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_Donation', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_Donation (
        INVOICE_NUMBER VARCHAR(30),
        Amount DECIMAL(10,2),
        Date_of_donation DATE,
        Purpose VARCHAR(255),
        Artwork_ID VARCHAR(50),         -- ARTWORK_AUTHENTICITY_CERT_NUM
        Patron_PESEL VARCHAR(11)
    );
END;
GO

TRUNCATE TABLE dbo.Stg_Donation;
GO

BEGIN TRY
    BULK INSERT dbo.Stg_Donation
    FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DW\Donations.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        CODEPAGE = '65001',
        TABLOCK
    );

    PRINT 'BULK INSERT into Stg_Donation completed';
END TRY
BEGIN CATCH
    PRINT 'Error during BULK INSERT: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO


BEGIN TRY
    MERGE INTO Donation AS target
    USING (
        SELECT
            s.INVOICE_NUMBER,
            s.Amount,
            d.ID_Date,
            p.ID_Patron,
            a.ID_Artwork,
            j.ID_Junk1,
            CAST(s.Amount * 0.23 AS DECIMAL(10,2)) AS Tax,
            CAST(s.Amount * 0.77 AS DECIMAL(10,2)) AS Profit
        FROM dbo.Stg_Donation s
        INNER JOIN [Date] d ON s.Date_of_donation = d.[Date]
        INNER JOIN Patron p ON s.Patron_PESEL = p.PESEL
        INNER JOIN Artwork a ON s.Artwork_ID = a.ARTWORK_AUTHENTICITY_CERT_NUM
        INNER JOIN Junk_Donation j ON s.Purpose = j.Purpose
    ) AS source
    ON target.INVOICE_NUMBER = source.INVOICE_NUMBER

    WHEN MATCHED AND (
           target.Amount <> source.Amount
        OR target.ID_Date <> source.ID_Date
        OR target.ID_Patron <> source.ID_Patron
        OR target.ID_Artwork <> source.ID_Artwork
        OR target.ID_Junk1 <> source.ID_Junk1
        OR ISNULL(target.Tax, 0) <> source.Tax
        OR ISNULL(target.Profit, 0) <> source.Profit
    )
    THEN UPDATE SET
        target.Amount = source.Amount,
        target.ID_Date = source.ID_Date,
        target.ID_Patron = source.ID_Patron,
        target.ID_Artwork = source.ID_Artwork,
        target.ID_Junk1 = source.ID_Junk1,
        target.Tax = source.Tax,
        target.Profit = source.Profit

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            INVOICE_NUMBER, ID_Date, ID_Patron, ID_Artwork,
            ID_Junk1, Amount, Tax, Profit
        )
        VALUES (
            source.INVOICE_NUMBER, source.ID_Date, source.ID_Patron, source.ID_Artwork,
            source.ID_Junk1, source.Amount, source.Tax, source.Profit
        );

    PRINT CONCAT('MERGE completed. ', @@ROWCOUNT, ' rows inserted or updated in Donation.');
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_Donation;
END CATCH;
GO


SELECT COUNT(*) AS TotalDonations FROM Donation;
GO
