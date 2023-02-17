--Databases MSSQL Server Exam - 13 February 2021
CREATE DATABASE Bitbucket
GO
USE Bitbucket
GO
CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	Password VARCHAR(30) NOT NULL,
	Email VARCHAR(30) NOT NULL
);
CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL
);
CREATE TABLE RepositoriesContributors
(
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL,
	PRIMARY KEY(RepositoryId, ContributorId)
);
CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus CHAR(6) NOT NULL,
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
);
CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	Message VARCHAR(255) NOT NULL,
	IssueId INT FOREIGN KEY REFERENCES Issues(Id),
	RepositoryId INT FOREIGN KEY REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT FOREIGN KEY REFERENCES Users(Id) NOT NULL
);
CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(100) NOT NULL,
	Size DECIMAL(18, 2) NOT NULL,
	ParentId  INT FOREIGN KEY REFERENCES Files(Id),
	CommitId  INT FOREIGN KEY REFERENCES Commits(Id) NOT NULL
);
--Problem 2
INSERT INTO Files(Name, Size, ParentId, CommitId)
VALUES
('Trade.idk',	2598.0,	1,	1),
('menu.net',	9238.31,	2,	2),
('Administrate.soshy',	1246.93,	3,	3),
('Controller.php',	7353.15,	4,	4),
('Find.java',	9957.86,	5,	5),
('Controller.json',	14034.87,	3,	6),
('Operate.xix',	7662.92,	7,	7)

INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
('Critical Problem with HomeController.cs file',	'open',	1,	4),
('Typo fix in Judge.html',	'open',	4,	3),
('Implement documentation for UsersService.cs',	'closed',	8,	2),
('Unreachable code in Index.cs',	'open',	9, 8)

--Problem 3
UPDATE Issues
SET IssueStatus = 'closed'
WHERE AssigneeId = 6

--Problem 4
SELECT * FROM Repositories
WHERE Name = 'Softuni-Teamwork'

DELETE Issues
WHERE RepositoryId = 3

DELETE RepositoriesContributors
WHERE RepositoryId = 3

--Problem 5
SELECT c.Id, c.Message, c.RepositoryId, c.ContributorId
FROM Commits AS c
ORDER BY c.Id, c.Message, c.RepositoryId, c.ContributorId

--Problem 6
SELECT f.Id, f.Name, f.Size
FROM Files AS f
WHERE f.Size > 1000 AND f.Name LIKE '%html%'
ORDER BY f.Size DESC, f.Id, f.Name

--Problem 7
SELECT i.Id, CONCAT(u.Username,' : ', i.Title) AS IssueAssignee
FROM Issues AS i
INNER JOIN Users AS u ON i.AssigneeId = u.Id
ORDER BY i.Id DESC, IssueAssignee

--Problem 8
SELECT fl.Id, fl.Name, CONCAT(fl.Size, 'KB') AS Size
FROM Files AS f
RIGHT JOIN Files AS fl ON f.ParentId = fl.Id
WHERE f.ParentId IS NULL
ORDER BY fl.Id, fl.Name, fl.Size DESC

--Problem 9
SELECT TOP(5) r.Id, r.Name, COUNT(c.Id) AS Commits
FROM Repositories AS r
INNER JOIN Commits AS c ON c.RepositoryId = r.Id
INNER JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
GROUP BY r.Id, r.Name
ORDER BY Commits DESC, r.Id, r.Name

SELECT *
FROM Repositories AS r
INNER JOIN Commits AS c ON c.RepositoryId = r.Id
INNER JOIN RepositoriesContributors AS rc ON r.Id = rc.RepositoryId
WHERE r.Id = 1

--Problem 10
SELECT u.Username, AVG(f.Size) AS Size
FROM Commits AS c
INNER JOIN Users AS u ON c.ContributorId = u.Id
INNER JOIN Files AS f ON f.CommitId = c.Id
GROUP BY u.Username
ORDER BY Size DESC, u.Username

--Problem 11
GO
CREATE FUNCTION udf_AllUserCommits(@username  VARCHAR(30)) 
RETURNS INT AS
BEGIN

RETURN  ( SELECT COUNT(c.Id)
		FROM Users AS u
		LEFT JOIN Commits AS c ON c.ContributorId = u.Id
		WHERE u.Username = @username)

END
GO
SELECT dbo.udf_AllUserCommits('UnderSinduxrein')
GO

--Problem 12
CREATE PROCEDURE usp_SearchForFiles(@fileExtension VARCHAR(10))
AS
BEGIN
	SELECT f.Id, f.Name, CONCAT(f.Size, 'KB') AS Size
	FROM Files AS f
	WHERE f.Name LIKE '%'+@fileExtension+'%'
	ORDER BY f.Id, f.Name, f.Size DESC
END
GO

SELECT f.Id, f.Name, CONCAT(f.Size, 'KB') AS Size
FROM Files AS f
WHERE f.Name LIKE '%'+'txt'+'%'
ORDER BY f.Id, f.Name, f.Size DESC

EXEC usp_SearchForFiles 'txt'