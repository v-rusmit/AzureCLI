CREATE TABLE [dbo].[ServiceLogEntry]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [CreatedAt] DATETIME NOT NULL, 
    [Description] NVARCHAR(300) NOT NULL, 
    [CreatedById] INT NOT NULL, 
    [ServiceTicketId] INT NOT NULL, 
    CONSTRAINT [FK_ServiceLogEntry_Employee] FOREIGN KEY (CreatedById) REFERENCES Employee(Id), 
    CONSTRAINT [FK_ServiceLogEntry_ServiceTicket] FOREIGN KEY (ServiceTicketId) REFERENCES ServiceTicket(Id)
)
