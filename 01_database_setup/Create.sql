CREATE DATABASE Museum_DB;
Use Museum_DB;
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

IF OBJECT_ID('Donations', 'U') IS NOT NULL
    DROP TABLE Donations;

IF OBJECT_ID('Artwork', 'U') IS NOT NULL
    DROP TABLE Artwork;

IF OBJECT_ID('Artist', 'U') IS NOT NULL
    DROP TABLE Artist;

IF OBJECT_ID('Patron', 'U') IS NOT NULL
    DROP TABLE Patron;
GO

EXEC sp_MSforeachtable 'ALTER TABLE ? CHECK CONSTRAINT ALL';
GO

CREATE TABLE Patron (
    PESEL VARCHAR(11) PRIMARY KEY,
    Type VARCHAR(50) NOT NULL,
    Phone_number VARCHAR(15),
    Address VARCHAR(255),
    Membership_status VARCHAR(50),
    Membership_level VARCHAR(50) CHECK (Membership_level IN ('Platinum', 'Gold', 'Silver', 'Bronze')),
    Date_joined DATE NOT NULL,
    Name VARCHAR(150) NOT NULL,
    Surname VARCHAR(150),
    Country VARCHAR(50),
    City VARCHAR(50),
    District VARCHAR(50),
    Street VARCHAR(50)
);

CREATE TABLE Artist (
    PESEL VARCHAR(11) PRIMARY KEY,
    Birth_year INT NOT NULL,
    Death_year INT,
    Nationality VARCHAR(100),
    Name VARCHAR(30) NOT NULL,
    Surname VARCHAR(50) NOT NULL
);

CREATE TABLE Artwork (
    ARTWORK_AUTHENTICITY_CERT_NUM VARCHAR(50) PRIMARY KEY,
    Title VARCHAR(200),
    Year_created INT,
    Type VARCHAR(50),
    Medium VARCHAR(500),
    Category_of_size VARCHAR(100),
    Permanent BIT,
    Artist_PESEL VARCHAR(11) NOT NULL,
    FOREIGN KEY (Artist_PESEL) REFERENCES Artist(PESEL) ON DELETE CASCADE
);

CREATE TABLE Donations (
    INVOICE_NUMBER VARCHAR(50) PRIMARY KEY,
    Amount DECIMAL(10,2) NOT NULL,
    Date_of_donation DATE NOT NULL,
    Purpose VARCHAR(255),
    Artwork_ID VARCHAR(50) NOT NULL,
    Patron_PESEL VARCHAR(11) NOT NULL,
    FOREIGN KEY (Artwork_ID) REFERENCES Artwork(ARTWORK_AUTHENTICITY_CERT_NUM) ON DELETE CASCADE,
    FOREIGN KEY (Patron_PESEL) REFERENCES Patron(PESEL) ON DELETE CASCADE
);
GO

PRINT 'All tables created successfully';