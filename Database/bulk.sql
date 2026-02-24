USE Museum;
-- Patron
DELETE FROM Patron;
BULK INSERT Patron
FROM 'C:\Users\cyryl\Desktop\task5\scripts_task5-20250515T070418Z-1-001\scripts_task5\output_csv\Patron.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
-- Artist"C:\Users\cyryl\Desktop\task5\scripts_task5-20250515T070418Z-1-001\scripts_task5\output_csv\Artist.csv"
DELETE FROM Artist;
BULK INSERT Artist
FROM 'C:\Users\cyryl\Desktop\task5\scripts_task5-20250515T070418Z-1-001\scripts_task5\output_csv\Artist.csv'
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
FROM 'C:\Users\cyryl\Desktop\task5\scripts_task5-20250515T070418Z-1-001\scripts_task5\output_csv\Artwork.csv'
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
FROM 'C:\Users\cyryl\Desktop\task5\scripts_task5-20250515T070418Z-1-001\scripts_task5\output_csv\Donations.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
