CREATE TABLE [dbo].[Employee]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [FirstName] NVARCHAR(20) NOT NULL, 
    [LastName] NVARCHAR(20) NOT NULL, 
    [AddressId] INT NOT NULL, 
    [Identity] NVARCHAR(50) NOT NULL, 
    [ServiceAreas] NVARCHAR(150) NULL, 
    CONSTRAINT [FK_Employee_Address] FOREIGN KEY (AddressId) REFERENCES Address(Id)
)
