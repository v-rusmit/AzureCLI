CREATE TABLE [dbo].[ServiceTicket]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [Title] NVARCHAR(50) NOT NULL, 
    [Description] NVARCHAR(600) NOT NULL, 
    [StatusValue] INT NOT NULL, 
    [EscalationLevel] INT NOT NULL, 
    [Opened] DATETIME NULL, 
    [Closed] DATETIME NULL, 
    [CustomerId] INT NULL, 
    [CreatedById] INT NULL, 
    [AssignedToId] INT NULL, 
    CONSTRAINT [FK_ServiceTicket_Status] FOREIGN KEY (StatusValue) REFERENCES Status(Id), 
    CONSTRAINT [FK_ServiceTicket_Customer] FOREIGN KEY (CustomerId) REFERENCES Customer(Id), 
    CONSTRAINT [FK_ServiceTicket_CBEmployee] FOREIGN KEY (CreatedById) REFERENCES Employee(Id), 
    CONSTRAINT [FK_ServiceTicket_ATEmployee] FOREIGN KEY (AssignedToId) REFERENCES Employee(Id)
)
