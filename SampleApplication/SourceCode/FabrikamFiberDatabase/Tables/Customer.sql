CREATE TABLE [dbo].[Customer]
(
	[Id] INT NOT NULL IDENTITY , 
    [FirstName] NVARCHAR(20) NOT NULL, 
    [LastName] NVARCHAR(20) NOT NULL, 
    [AddressId] INT NOT NULL, 
    PRIMARY KEY ([Id]), 
    CONSTRAINT [FK_Customer_Address] FOREIGN KEY (AddressId) REFERENCES Address(Id) 
)
