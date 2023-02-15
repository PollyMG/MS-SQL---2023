--Databases MSSQL Server Exam - 16 October 2021
CREATE DATABASE CigarShop
GO
USE CigarShop
GO
CREATE TABLE Sizes
(
	Id INT PRIMARY KEY IDENTITY,
	[Length] INT CHECK(Length >= 10 AND Length <= 25) NOT NULL,
	RingRange DECIMAL(18, 2) CHECK(RingRange >= 1.5 AND RingRange <= 7.5) NOT NULL
);
CREATE TABLE Tastes
(
	Id INT PRIMARY KEY IDENTITY,
	TasteType VARCHAR(20) NOT NULL,
	TasteStrength VARCHAR(15) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL
);
CREATE TABLE Brands
(
	Id INT PRIMARY KEY IDENTITY,
	BrandName VARCHAR(30) UNIQUE NOT NULL,
	BrandDescription VARCHAR(MAX)
);
CREATE TABLE Cigars
(
	Id INT PRIMARY KEY IDENTITY,
	CigarName  VARCHAR(80) NOT NULL,
	BrandId INT FOREIGN KEY REFERENCES Brands(Id) NOT NULL,
	TastId INT FOREIGN KEY REFERENCES Tastes(Id) NOT NULL,
	SizeId INT FOREIGN KEY REFERENCES Sizes(Id) NOT NULL,
	PriceForSingleCigar DECIMAL(18,4) NOT NULL,
	ImageURL NVARCHAR(100) NOT NULL
);
CREATE TABLE Addresses
(
	Id INT PRIMARY KEY IDENTITY,
	Town VARCHAR(30) NOT NULL,
	Country NVARCHAR(30) NOT NULL,
	Streat NVARCHAR(100) NOT NULL,
	ZIP VARCHAR(20) NOT NULL
);
CREATE TABLE Clients
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(30) NOT NULL,
	LastName NVARCHAR(30) NOT NULL,
	Email NVARCHAR(50) NOT NULL,
	AddressId INT FOREIGN KEY REFERENCES Addresses(Id) NOT NULL
);
CREATE TABLE ClientsCigars
(
	ClientId INT FOREIGN KEY REFERENCES Clients(Id) NOT NULL,
	CigarId INT FOREIGN KEY REFERENCES Cigars(Id) NOT NULL,
	PRIMARY KEY(ClientId, CigarId)
);

--Problem 2
INSERT INTO Cigars (CigarName, BrandId, TastId, SizeId, PriceForSingleCigar, ImageURL)
VALUES
('COHIBA ROBUSTO',	9,	1,	5,	15.50,	'cohiba-robusto-stick_18.jpg'),
('COHIBA SIGLO I',	9,	1,	10,	410.00,	'cohiba-siglo-i-stick_12.jpg'),
('HOYO DE MONTERREY LE HOYO DU MAIRE',	14,	5,	11,	7.50,	'hoyo-du-maire-stick_17.jpg'),
('HOYO DE MONTERREY LE HOYO DE SAN JUAN', 14,	4,	15,	32.00,	'hoyo-de-san-juan-stick_20.jpg'),
('TRINIDAD COLONIALES',	2,	3,	8,	85.21,	'trinidad-coloniales-stick_30.jpg')

INSERT INTO Addresses(Town, Country, Streat, ZIP)
VALUES
('Sofia',	'Bulgaria',	'18 Bul. Vasil levski',	1000),
('Athens',	'Greece',	'4342 McDonald Avenue',	10435),
('Zagreb',	'Croatia',	'4333 Lauren Drive',	10000)

--Problem 3
SELECT * FROM Tastes
WHERE TasteType = 'Spicy'


UPDATE Cigars
SET PriceForSingleCigar = PriceForSingleCigar * 1.20
WHERE TastId = 1

UPDATE Brands
SET BrandDescription = 'New description'
WHERE BrandDescription IS NULL

SELECT * FROM Brands

--Problem 4
SELECT * FROM Addresses
WHERE Country LIKE 'C%'

DELETE Clients
WHERE AddressId IN (7, 8, 10)

DELETE Addresses
WHERE Country LIKE 'C%'

--Problem 5
SELECT CigarName, PriceForSingleCigar, ImageURL
FROM Cigars
ORDER BY PriceForSingleCigar, CigarName DESC

--Problem 6
SELECT c.Id, c.CigarName, c.PriceForSingleCigar, t.TasteType, t.TasteStrength
FROM Cigars AS c
INNER JOIN Tastes AS t ON c.TastId = t.Id
WHERE TasteType = 'Earthy' OR TasteType = 'Woody'
ORDER BY PriceForSingleCigar DESC

--Problem 7
SELECT c.Id, 
	CONCAT(c.FirstName, ' ', c.LastName) AS ClientName, c.Email
FROM Clients AS c
LEFT JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
LEFT JOIN Cigars AS cg ON cc.CigarId = cg.Id
WHERE cc.ClientId IS NULL
ORDER BY ClientName

--Problem 8
SELECT TOP(5) c.CigarName, c.PriceForSingleCigar, c.ImageURL 
FROM Cigars AS c
INNER JOIN Sizes AS s ON c.SizeId = s.Id
where (s.Length >= 12) and (c.CigarName like('%ci%') or s.RingRange>2.55 and c.PriceForSingleCigar>50)
ORDER BY c.CigarName, c.PriceForSingleCigar DESC

--Problem 9
SELECT 
	CONCAT(c.FirstName, ' ', c.LastName) AS FullName, a.Country, a.ZIP, CONCAT('$', MAX(cg.PriceForSingleCigar)) AS CigarPrice
FROM Clients AS c
INNER JOIN Addresses AS a ON c.AddressId = a.Id
INNER JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
INNER JOIN Cigars AS cg ON cc.CigarId = cg.Id
WHERE a.ZIP NOT LIKE '%[^0-9]%'
GROUP BY c.Id, CONCAT(c.FirstName, ' ', c.LastName), a.Country, a.ZIP
ORDER BY FullName


--Problem 10
SELECT c.LastName,
		AVG(s.Length) AS CiagrLength,
		CEILING(AVG(s.RingRange)) AS CiagrRingRange
FROM Clients AS c
INNER JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
INNER JOIN Cigars AS cg ON cc.CigarId = cg.Id
INNER JOIN Sizes AS s ON cg.SizeId = s.Id
GROUP BY c.LastName
ORDER BY CiagrLength DESC

--Problem 11
GO
CREATE FUNCTION udf_ClientWithCigars(@name NVARCHAR(30))
RETURNS INT AS
BEGIN

 RETURN (SELECT COUNT(c.Id)
FROM Clients AS c
INNER JOIN ClientsCigars AS cc ON c.Id = cc.ClientId
WHERE c.FirstName = @name)
END

GO
SELECT dbo.udf_ClientWithCigars('Betty')
GO

--Problem 12
CREATE PROCEDURE usp_SearchByTaste(@taste VARCHAR(20))
AS
BEGIN
	SELECT c.CigarName,
 CONCAT('$', c.PriceForSingleCigar)  AS Price,
t.TasteType, b.BrandName,
 CONCAT(s.Length, ' cm')  AS CigarLength,
 CONCAT(s.RingRange, ' cm')  AS CigarRingRange
FROM Cigars AS c
INNER JOIN Tastes AS t ON c.TastId = t.Id
INNER JOIN Brands AS b ON c.BrandId = b.Id
INNER JOIN Sizes AS s ON c.SizeId = s.Id
WHERE t.TasteType = @taste
ORDER BY CigarLength, CigarRingRange DESC
END

GO
EXEC usp_SearchByTaste 'Woody'