USE Museum_DB;
--Patron
DELETE FROM Patron;
BULK INSERT Patron
FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DB\Patron.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
--Artist
DELETE FROM Artist;
BULK INSERT Artist
FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DB\Artist.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);



-- Artwork
DELETE FROM Artwork;
BULK INSERT Artwork
FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DB\Artwork.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

-- Donations
DELETE FROM Donations;
BULK INSERT Donations
FROM 'C:\Users\cyryl\Desktop\DW_Museum\Data\Museum_DB\Donations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
