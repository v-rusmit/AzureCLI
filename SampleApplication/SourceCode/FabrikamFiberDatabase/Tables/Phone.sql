CREATE TABLE [dbo].[Phone]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [Label] NVARCHAR(50) NULL, 
    [Number] NVARCHAR(20) NOT NULL, 
    [CustomerId] INT NULL, 
    [EmployeeId] INT NULL, 
    CONSTRAINT [FK_Phone_Customer] FOREIGN KEY (CustomerId) REFERENCES Customer(Id), 
    CONSTRAINT [FK_Phone_Employee] FOREIGN KEY (EmployeeId) REFERENCES Employee(Id)
)
