--Databases MSSQL Server Retake Exam - 8 April 2021
CREATE DATABASE Service
GO
USE Service
GO
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) UNIQUE NOT NULL,
	Password VARCHAR(50) NOT NULL,
	Name VARCHAR(50),
	Birthdate DATETIME,
	Age INT CHECK(Age >=14 AND Age <= 110),
	Email VARCHAR(50) NOT NULL
);
CREATE TABLE Departments
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL
);
CREATE TABLE Employees
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(25),
	LastName VARCHAR(25),
	Birthdate DATETIME,
	Age INT CHECK(Age >=18 AND Age <= 110),
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id)
);
CREATE TABLE Categories
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL,
	DepartmentId INT FOREIGN KEY REFERENCES Departments(Id) NOT NULL
);
CREATE TABLE Status
(
	Id INT PRIMARY KEY IDENTITY,
	Label VARCHAR(20) NOT NULL
);
CREATE TABLE Reports
(
	Id INT PRIMARY KEY IDENTITY,
	CategoryId INT FOREIGN KEY REFERENCES Categories(Id) NOT NULL,
	StatusId INT FOREIGN KEY REFERENCES Status(Id) NOT NULL,
	OpenDate DATETIME NOT NULL,
	CloseDate DATETIME,
	Description VARCHAR(200) NOT NULL,
	UserId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	EmployeeId  INT FOREIGN KEY REFERENCES Employees(Id),
);
--Problem 2
INSERT INTO Employees (FirstName, LastName, Birthdate, DepartmentId)
VALUES
('Marlo',	'O''Malley',	'1958-9-21', 1),
('Niki',	'Stanaghan',	'1969-11-26', 4),
('Ayrton',	'Senna',	'1960-03-21',	9),
('Ronnie',	'Peterson',	'1944-02-14',	9),
('Giovanna',	'Amati',	'1959-07-20',	5)

INSERT INTO Reports (CategoryId, StatusId, OpenDate, CloseDate, Description, UserId, EmployeeId)
VALUES
(1,	1,	'2017-04-13',	NULL,	'Stuck Road on Str.133',	6,	2),
(6,	3,	'2015-09-05',	'2015-12-06',	'Charity trail running',	3,	5),
(14, 2,	'2015-09-07',	NULL, 'Falling bricks on Str.58',	5,	2),
(4,	3,	'2017-07-03',	'2017-07-06',	'Cut off streetlight on Str.11',	1,	1)

--Problem 3
UPDATE Reports
SET CloseDate = GETDATE()
WHERE CloseDate IS NULL

--Problem 4
DELETE Reports
WHERE StatusId = 4

--Problem 5
SELECT r.Description, FORMAT(r.OpenDate, 'dd-MM-yyyy') AS OpenDate
FROM Reports AS r
WHERE r.EmployeeId IS NULL
ORDER BY r.OpenDate, r.Description

--Problem 6
SELECT r.Description, c.Name
FROM Reports AS r
INNER JOIN Categories AS c ON r.CategoryId = c.Id
ORDER BY r.Description, c.Name

--Problem 7
SELECT TOP(5)
c.Name, COUNT(*) AS ReportsNumber
FROM Reports AS r
INNER JOIN Categories AS c ON r.CategoryId = c.Id
GROUP BY c.Name
ORDER BY ReportsNumber DESC, c.Name

--Problem 8
SELECT u.Username, c.Name AS CategoryName
FROM Reports AS r
INNER JOIN Categories AS c ON r.CategoryId = c.Id
INNER JOIN Users AS u ON r.UserId = u.Id
WHERE MONTH(r.OpenDate) = MONTH(u.Birthdate) AND DAY(r.OpenDate) = DAY(u.Birthdate)
ORDER BY u.Username, c.Name

--Problem 9
SELECT CONCAT(e.FirstName, ' ',  e.LastName) AS FullName,
	COUNT(u.Id) AS UsersCount
FROM Employees AS e 
LEFT JOIN Reports AS r ON e.Id = r.EmployeeId
LEFT JOIN Users AS u ON r.UserId = u.Id
GROUP BY CONCAT(e.FirstName, ' ',  e.LastName)
ORDER BY UsersCount DESC, FullName

--Problem 10
SELECT 
	CASE WHEN COALESCE(e.FirstName, e.LastName) IS NULL
		THEN 'None'
	ELSE  CONCAT(e.FirstName,' ',e.LastName)
	END AS Employee,
	ISNULL(d.Name, 'None') AS Department, 
	ISNULL(c.Name, 'None') AS Category, 
	ISNULL(r.Description, 'None'),
	ISNULL(FORMAT(r.OpenDate, 'dd.MM.yyyy'), 'None') AS OpenDate, 
	ISNULL(s.Label, 'None') AS Status, 
	ISNULL(u.Name, 'None') AS [User]
FROM Reports AS r
LEFT JOIN Employees AS e ON r.EmployeeId = e.Id
LEFT JOIN Departments AS d ON e.DepartmentId = d.Id
LEFT JOIN Categories AS c ON c.Id = r.CategoryId
LEFT JOIN Users AS u ON r.UserId = u.Id
LEFT JOIN Status AS s ON r.StatusId = s.Id
ORDER BY e.FirstName DESC, e.LastName DESC, Department, Category, r.Description, r.OpenDate, s.Label, [User]
GO

--Problem 11
CREATE FUNCTION udf_HoursToComplete(@StartDate DATETIME, @EndDate DATETIME) 
RETURNS INT AS
BEGIN
 RETURN
	ISNULL(DATEDIFF(HOUR, @StartDate, @EndDate), 0)	
END

GO

SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports
GO

--Problem 12
CREATE PROCEDURE usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT)
AS
BEGIN
	 DECLARE @employeeDepartmentId INT = (SELECT DepartmentId FROM Employees WHERE Id LIKE @EmployeeId)
 
     DECLARE @categoryDepartmentId INT = (SELECT d.Id AS CategoryDepartmentId 
									FROM Reports AS r 
                                    INNER JOIN Categories AS c ON r.CategoryId = c.Id
                                    INNER JOIN Departments AS d ON c.DepartmentId = d.Id
									WHERE r.Id LIKE @ReportId)
 
                            IF(@employeeDepartmentId<>@categoryDepartmentId)
                            THROW 500001, 'Employee doesn''t belong to the appropriate department!', 1
 
                             UPDATE Reports
                                 SET EmployeeId = @EmployeeId
                               WHERE Id LIKE @ReportId
END
GO
