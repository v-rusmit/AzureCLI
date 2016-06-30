CREATE TABLE [dbo].[ScheduleItem]
(
	[Id] INT NOT NULL PRIMARY KEY IDENTITY, 
    [EmployeeId] INT NULL, 
    [ServiceTicketId] INT NULL, 
    [Start] DATETIME NOT NULL, 
    [WorkHours] INT NOT NULL, 
    [AssignedOn] DATETIME NOT NULL, 
    CONSTRAINT [FK_ScheduleItem_Employee] FOREIGN KEY (EmployeeId) REFERENCES Employee(Id), 
    CONSTRAINT [FK_ScheduleItem_ServiceTicket] FOREIGN KEY (ServiceTicketId) REFERENCES ServiceTicket(Id)
)
