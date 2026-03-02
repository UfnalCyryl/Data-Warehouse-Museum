USE Museum_DW;
GO
SET NOCOUNT ON;
IF OBJECT_ID('dbo.Stg_A_DD', 'U') IS NULL
BEGIN
CREATE TABLE dbo.Stg_A_DD (
    Artist_PESEL VARCHAR(11) NOT NULL,
    ARTWORK_AUTHENTICITY_CERT_NUM VARCHAR(50) NOT NULL,
    INVOICE_NUMBER VARCHAR(50) NOT NULL
);

END;
GO

TRUNCATE TABLE dbo.Stg_A_DD;
GO

BEGIN TRY
    INSERT INTO dbo.Stg_A_DD (Artist_PESEL, ARTWORK_AUTHENTICITY_CERT_NUM, INVOICE_NUMBER)
    SELECT 
        a1.PESEL, 
        a2.ARTWORK_AUTHENTICITY_CERT_NUM,
        d2.INVOICE_NUMBER
    FROM Museum_DB.dbo.Artist a1
    JOIN Museum_DB.dbo.Artwork a2 
        ON a2.Artist_PESEL = a1.PESEL
    JOIN museum_DB.dbo.Donations d2 
        ON d2.Artwork_ID = a2.ARTWORK_AUTHENTICITY_CERT_NUM;

    PRINT 'Data successfully loaded from Museum_DB.dbo.Artist into Stg_A_DD.';
END TRY
BEGIN CATCH
    PRINT 'Error during INSERT from Museum_DB: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    ;WITH Resolved AS (
        SELECT
            s.INVOICE_NUMBER,
            a.ID_Artist
        FROM  dbo.Stg_A_DD s
        INNER JOIN Artist a ON s.Artist_PESEL = a.PESEL
        INNER JOIN Donation d ON s.INVOICE_NUMBER = d.INVOICE_NUMBER
    )
    INSERT INTO A_D (INVOICE_NUMBER, ID_Artist)
    SELECT 
        r.INVOICE_NUMBER,
        r.ID_Artist
    FROM Resolved r
    WHERE NOT EXISTS (
        SELECT 1
        FROM A_D existing
        WHERE existing.INVOICE_NUMBER = r.INVOICE_NUMBER
          AND existing.ID_Artist = r.ID_Artist
    );

    PRINT CONCAT('A_D bridge populated: ', @@ROWCOUNT, ' new rows inserted.');
END TRY
BEGIN CATCH
    PRINT 'Error populating A_D: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_A_DD;
END CATCH;
GO

SELECT COUNT(*) AS Total_A_D_Records FROM A_D;
