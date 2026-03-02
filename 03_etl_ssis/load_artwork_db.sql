USE Museum_DW;

SET NOCOUNT ON;

IF OBJECT_ID('dbo.Stg_Artwork', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stg_Artwork (
		
        ARTWORK_AUTHENTICITY_CERT_NUM VARCHAR(50),
        Title VARCHAR(200),
        Year_created SMALLINT,
        Type VARCHAR(50),
        Medium VARCHAR(500),
        Category_of_size VARCHAR(100),
        Permanent BIT
    );
END;
GO

TRUNCATE TABLE dbo.Stg_Artwork;
GO

BEGIN TRY
    INSERT INTO dbo.Stg_Artwork (
        ARTWORK_AUTHENTICITY_CERT_NUM, Title, Year_created, Type, Medium,
        Category_of_size, Permanent
    )
    SELECT
        ARTWORK_AUTHENTICITY_CERT_NUM,
        Title,
        CAST(Year_created AS SMALLINT),
        Type,
        Medium,
        Category_of_size,
        Permanent
        
    FROM Museum_DB.dbo.Artwork;

    PRINT 'Loaded data from Museum_DB.dbo.Artwork into staging.';
END TRY
BEGIN CATCH
    PRINT 'Error loading from Museum_DB: ' + ERROR_MESSAGE();
    RETURN;
END CATCH;
GO

BEGIN TRY
    MERGE INTO dbo.Artwork AS target
    USING (
        SELECT 
            ARTWORK_AUTHENTICITY_CERT_NUM,
            Title,
            Year_created,
            Type,
            Medium,
            Category_of_size,
            Permanent
        FROM dbo.Stg_Artwork
    ) AS source
    ON target.ARTWORK_AUTHENTICITY_CERT_NUM = source.ARTWORK_AUTHENTICITY_CERT_NUM

    WHEN MATCHED AND (
           ISNULL(target.Title, '') <> ISNULL(source.Title, '')
        OR ISNULL(target.Year_created, -1) <> ISNULL(source.Year_created, -1)
        OR ISNULL(target.Type, '') <> ISNULL(source.Type, '')
        OR ISNULL(target.Medium, '') <> ISNULL(source.Medium, '')
        OR ISNULL(target.Category_of_size, '') <> ISNULL(source.Category_of_size, '')
        OR ISNULL(target.Permanent, -1) <> ISNULL(source.Permanent, -1)
    )
    THEN UPDATE SET
        Title = source.Title,
        Year_created = source.Year_created,
        Type = source.Type,
        Medium = source.Medium,
        Category_of_size = source.Category_of_size,
        Permanent = source.Permanent

    WHEN NOT MATCHED BY TARGET THEN
        INSERT (ARTWORK_AUTHENTICITY_CERT_NUM, Title, Year_created, Type, Medium,
                Category_of_size, Permanent)
        VALUES (source.ARTWORK_AUTHENTICITY_CERT_NUM, source.Title, source.Year_created,
                source.Type, source.Medium, source.Category_of_size,
                source.Permanent);

    PRINT CONCAT('MERGE completed. Rows affected: ', @@ROWCOUNT);
END TRY
BEGIN CATCH
    PRINT 'Error during MERGE: ' + ERROR_MESSAGE();
    SELECT TOP 10 * FROM dbo.Stg_Artwork;
END CATCH;
GO

SELECT COUNT(*) AS TotalArtworks FROM dbo.Artwork;
GO