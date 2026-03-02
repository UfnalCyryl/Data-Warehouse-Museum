USE Museum_DW;
GO
SET NOCOUNT ON;

BEGIN TRY
    INSERT INTO Patron_date_joined (ID_Date, ID_Patron, ID_PDJ)
    SELECT
        d.ID_Date,
        p.ID_Patron,
        ABS(CHECKSUM(NEWID())) % 1000000  -- pseudorandom surrogate key
    FROM Patron p
    INNER JOIN [Date] d ON p.Date_joined = d.[Date]
    WHERE NOT EXISTS (
        SELECT 1
        FROM Patron_date_joined pdj
        WHERE pdj.ID_Date = d.ID_Date AND pdj.ID_Patron = p.ID_Patron
    );

    PRINT CONCAT('Inserted ', @@ROWCOUNT, ' new rows into Patron_date_joined');
END TRY
BEGIN CATCH
    PRINT 'Error during insert: ' + ERROR_MESSAGE();
END CATCH;
GO

SELECT COUNT(*) AS TotalRows FROM Patron_date_joined;
