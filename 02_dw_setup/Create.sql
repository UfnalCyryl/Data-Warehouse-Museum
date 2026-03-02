USE Museum_DW;
GO
SET NOCOUNT ON;

-- Drop bridges first
IF OBJECT_ID('A_B_L', 'U') IS NOT NULL DROP TABLE A_B_L;
IF OBJECT_ID('A_D', 'U') IS NOT NULL DROP TABLE A_D;

-- Drop fact tables
IF OBJECT_ID('Donation', 'U') IS NOT NULL DROP TABLE Donation;
IF OBJECT_ID('Borrowed_or_lent', 'U') IS NOT NULL DROP TABLE Borrowed_or_lent;
IF OBJECT_ID('Patron_date_joined', 'U') IS NOT NULL DROP TABLE Patron_date_joined;

-- Drop dimension tables
IF OBJECT_ID('Artwork', 'U') IS NOT NULL DROP TABLE Artwork;
IF OBJECT_ID('Artist', 'U') IS NOT NULL DROP TABLE Artist;
IF OBJECT_ID('Patron', 'U') IS NOT NULL DROP TABLE Patron;
IF OBJECT_ID('Institution', 'U') IS NOT NULL DROP TABLE Institution;
IF OBJECT_ID('Date', 'U') IS NOT NULL DROP TABLE [Date];
IF OBJECT_ID('Junk_Donation', 'U') IS NOT NULL DROP TABLE Junk_Donation;
IF OBJECT_ID('Junk_Borrowing', 'U') IS NOT NULL DROP TABLE Junk_Borrowing;
GO


CREATE TABLE [Date] (
    ID_Date INT IDENTITY(1,1) PRIMARY KEY,
    [Date] DATE NOT NULL,
    [Year] NUMERIC(4) NOT NULL,
    [Month] VARCHAR(10) NOT NULL,
    MonthNo NUMERIC NOT NULL,
    DayOfWeek VARCHAR(10) NOT NULL,
    DayOfWeekNo NUMERIC NOT NULL,
    WorkingDay BIT NOT NULL,
    Vacation VARCHAR(20) NOT NULL,
    Holiday BIT NOT NULL,
    CONSTRAINT UQ_Date UNIQUE ([Date])
);

CREATE TABLE Artist (
    ID_Artist INT IDENTITY(1,1) PRIMARY KEY,
	PESEL VARCHAR(11) NOT NULL UNIQUE,
    Name_Surname VARCHAR(150) NOT NULL,
    Birth_year SMALLINT,
    Death_year SMALLINT NULL,
    Nationality VARCHAR(100)
);

CREATE TABLE Patron (
    ID_Patron INT IDENTITY(1,1) PRIMARY KEY,
    PESEL VARCHAR(11) NOT NULL UNIQUE, 
    Name_Surname VARCHAR(150) NOT NULL,
    Type VARCHAR(50) NOT NULL,
    Phone_number VARCHAR(15),
    Address VARCHAR(255),
    Membership_status VARCHAR(50),
    Membership_level VARCHAR(50),
    Date_joined DATE,
    Country VARCHAR(50),
    City VARCHAR(50),
    District VARCHAR(50),
    Street VARCHAR(50)
);

CREATE TABLE Institution (
    ID_Institution INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Prestige NUMERIC,
	Country VARCHAR(50),
    City VARCHAR(50),
    District VARCHAR(50),
    Street VARCHAR(50)
);

CREATE TABLE Junk_Donation (
    ID_Junk1 INT IDENTITY(1,1) PRIMARY KEY,
    Purpose VARCHAR(255) NOT NULL
);


CREATE TABLE Junk_Borrowing (
    ID_Junk2 INT IDENTITY(1,1) PRIMARY KEY,
    Status VARCHAR(50),
    Borrowed BIT NOT NULL,
    Lent BIT NOT NULL,
    Owned BIT NOT NULL
);


CREATE TABLE dbo.Artwork (
    ID_Artwork INT IDENTITY(1,1) PRIMARY KEY,
    ARTWORK_AUTHENTICITY_CERT_NUM VARCHAR(50) NOT NULL UNIQUE,
    Title VARCHAR(200) NOT NULL,
    Year_created SMALLINT,
    Type VARCHAR(50),
    Medium VARCHAR(500),
    Category_of_size VARCHAR(15),
    Permanent BIT,
);


CREATE TABLE Patron_date_joined (
    ID_Date INT NOT NULL,
    ID_Patron INT NOT NULL,
    ID_PDJ INT NOT NULL,
    PRIMARY KEY (ID_Date, ID_Patron, ID_PDJ),
    FOREIGN KEY (ID_Date) REFERENCES [Date](ID_Date),
    FOREIGN KEY (ID_Patron) REFERENCES Patron(ID_Patron)
);


CREATE TABLE Borrowed_or_lent (
    Borrowing_ID INT IDENTITY(1,1) PRIMARY KEY,
    ID_Artwork INT NOT NULL,
    ID_Junk2 INT NOT NULL,
    ID_Institution INT NOT NULL,
	ID_Date INT NOT NULL,
    FOREIGN KEY (ID_Artwork) REFERENCES Artwork(ID_Artwork),
    FOREIGN KEY (ID_Junk2) REFERENCES Junk_Borrowing(ID_Junk2),
    FOREIGN KEY (ID_Institution) REFERENCES Institution(ID_Institution),
	FOREIGN KEY (ID_Date) REFERENCES [Date](ID_Date)
);


CREATE TABLE A_D (
    INVOICE_NUMBER VARCHAR(30) NOT NULL,
    ID_Artist INT NOT NULL,
    PRIMARY KEY (INVOICE_NUMBER, ID_Artist),
    FOREIGN KEY (ID_Artist) REFERENCES Artist(ID_Artist)
);


CREATE TABLE A_B_L (
    ID_Borrowing INT NOT NULL,
    ID_Artist INT NOT NULL,
    PRIMARY KEY (ID_Borrowing, ID_Artist),
    FOREIGN KEY (ID_Borrowing) REFERENCES Borrowed_or_lent(Borrowing_ID),
    FOREIGN KEY (ID_Artist) REFERENCES Artist(ID_Artist)
);


CREATE TABLE Donation (
    INVOICE_NUMBER VARCHAR(30) PRIMARY KEY,
    ID_Date INT NOT NULL,
    ID_Patron INT NOT NULL,
    ID_Artwork INT NOT NULL,
    ID_Junk1 INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    Tax DECIMAL(10,2),
    Profit DECIMAL(10,2),
    FOREIGN KEY (ID_Date) REFERENCES [Date](ID_Date),
    FOREIGN KEY (ID_Patron) REFERENCES Patron(ID_Patron),
    FOREIGN KEY (ID_Artwork) REFERENCES Artwork(ID_Artwork),
    FOREIGN KEY (ID_Junk1) REFERENCES Junk_Donation(ID_Junk1)
);


ALTER TABLE A_D
ADD CONSTRAINT fk_a_d_donation FOREIGN KEY (INVOICE_NUMBER) REFERENCES Donation(INVOICE_NUMBER);