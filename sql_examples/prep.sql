GO

USE FoxFest

GO

CREATE TABLE Customers
(
    CustomerID int IDENTITY,
    CustomerName varchar(30),
    Active bit,
    CountryID int,
    Location varchar(30)
)

CREATE TABLE Countries
(
    Id int identity,
    English varchar(30),
    French varchar(30)
)

INSERT INTO Countries
    (English,French)
VALUES
    ('Canada', 'Canada')


INSERT INTO Countries
    (English,French)
VALUES
    ('US', 'E-U')


INSERT INTO Countries
    (English,French)
VALUES
    ('Australia', 'Australie')


INSERT INTO Countries
    (English,French)
VALUES
    ('France', 'France')

INSERT INTO Customers
    (CustomerName, Active,CountryId,Location)
VALUES
    ('Narwhal', 1, 1, 'Canadaland')


INSERT INTO Customers
    (CustomerName, Active,CountryId,Location)
VALUES
    ('Orca', 1, 2, 'Michigan')


INSERT INTO Customers
    (CustomerName, Active,CountryId,Location)
VALUES
    ('Emu', 0, 3, 'New South Wales')