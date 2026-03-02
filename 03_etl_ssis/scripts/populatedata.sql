USE Museum_DW;
GO

DECLARE @Start DATE = '1980-01-01';
DECLARE @End DATE = '2025-05-31';

;WITH Nbrs_3(n) AS (SELECT 1 UNION ALL SELECT 0),
     Nbrs_2(n) AS (SELECT 1 FROM Nbrs_3 a CROSS JOIN Nbrs_3 b),
     Nbrs_1(n) AS (SELECT 1 FROM Nbrs_2 a CROSS JOIN Nbrs_2 b),
     Nbrs_0(n) AS (SELECT 1 FROM Nbrs_1 a CROSS JOIN Nbrs_1 b),
     Nbrs(n)   AS (SELECT 1 FROM Nbrs_0 a CROSS JOIN Nbrs_0 b),
     DatesToInsert AS (
         SELECT 
             DATEADD(DAY, n - 1, @Start) AS [Date]
         FROM (
             SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
             FROM Nbrs
         ) AS D
         WHERE n <= DATEDIFF(DAY, @Start, @End) + 1
     )

INSERT INTO dbo.Date (
    Date,
    Year,
    Month,
    MonthNo,
    DayOfWeek,
    DayOfWeekNo,
    WorkingDay,
    Vacation,
    Holiday
)
SELECT 
    d.[Date],
    YEAR(d.[Date]),
    DATENAME(MONTH, d.[Date]),
    MONTH(d.[Date]),
    DATENAME(WEEKDAY, d.[Date]),
    DATEPART(WEEKDAY, d.[Date]),
    CASE DATEPART(WEEKDAY, d.[Date])
        WHEN 1 THEN 0  -- Sunday
        WHEN 7 THEN 0  -- Saturday
        ELSE 1
    END AS WorkingDay,
    CASE WHEN MONTH(d.[Date]) IN (7, 8) THEN 'Yes' ELSE 'No' END AS Vacation,
    CASE WHEN ABS(CHECKSUM(NEWID())) % 15 = 0 THEN 1 ELSE 0 END AS Holiday
FROM DatesToInsert d
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Date existing WHERE existing.Date = d.Date
);
