﻿/*
Deployment script for FabrikamFiber

This code was generated by a tool.
Changes to this file may cause incorrect behavior and will be lost if
the code is regenerated.
*/

GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, ARITHABORT, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON;

SET NUMERIC_ROUNDABORT OFF;


GO
:setvar DatabaseName "FabrikamFiber"
:setvar DefaultFilePrefix "FabrikamFiber"
:setvar DefaultDataPath "D:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\"
:setvar DefaultLogPath "D:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\"

GO
:on error exit
GO
/*
Detect SQLCMD mode and disable script execution if SQLCMD mode is not supported.
To re-enable the script after enabling SQLCMD mode, execute the following:
SET NOEXEC OFF; 
*/
:setvar __IsSqlCmdEnabled "True"
GO
IF N'$(__IsSqlCmdEnabled)' NOT LIKE N'True'
    BEGIN
        PRINT N'SQLCMD mode must be enabled to successfully execute this script.';
        SET NOEXEC ON;
    END


GO
USE [$(DatabaseName)];


GO
/*
The column [dbo].[ServiceTicket].[StatusId] is being dropped, data loss could occur.
*/

IF EXISTS (select top 1 1 from [dbo].[ServiceTicket])
    RAISERROR (N'Rows were detected. The schema update is terminating because data loss might occur.', 16, 127) WITH NOWAIT

GO
PRINT N'Dropping [dbo].[FK_ServiceTicket_Status]...';


GO
ALTER TABLE [dbo].[ServiceTicket] DROP CONSTRAINT [FK_ServiceTicket_Status];


GO
PRINT N'Altering [dbo].[ServiceTicket]...';


GO
ALTER TABLE [dbo].[ServiceTicket] DROP COLUMN [StatusId];


GO
PRINT N'Creating [dbo].[FK_ServiceTicket_Status]...';


GO
ALTER TABLE [dbo].[ServiceTicket] WITH NOCHECK
    ADD CONSTRAINT [FK_ServiceTicket_Status] FOREIGN KEY ([StatusValue]) REFERENCES [dbo].[Status] ([Id]);


GO
PRINT N'Checking existing data against newly created constraints';


GO
USE [$(DatabaseName)];


GO
ALTER TABLE [dbo].[ServiceTicket] WITH CHECK CHECK CONSTRAINT [FK_ServiceTicket_Status];


GO
PRINT N'Update complete.';


GO
