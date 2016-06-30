DELETE FROM ScheduleItem
DELETE FROM ServiceLogEntry
DELETE FROM ServiceTicket
DELETE FROM Customer
DELETE FROM Employee
DELETE FROM Phone
DELETE FROM Address


-- Employee

DECLARE @eid0 int
DECLARE @table table (id int)
INSERT INTO Address OUTPUT Inserted.Id Values('45 Greenbelt Way','Redmond','WA','98052')
INSERT INTO Employee OUTPUT Inserted.Id into @table Values('Drew', 'Robbins', @@IDENTITY, 'NORTHAMERICA\drobbins', null)
SELECT @eid0 = id from @table

DECLARE @eid1 int
INSERT INTO Address OUTPUT Inserted.Id Values('123 Standard Street','Redmond','WA','98052')
INSERT INTO Employee OUTPUT Inserted.Id into @table Values('Jonathan', 'Carter', @@IDENTITY, '', null)
SELECT @eid1 = id from @table

DECLARE @eid2 int
INSERT INTO Address OUTPUT Inserted.Id Values('361 North Avenue','Redmond','WA','98052')
INSERT INTO Employee OUTPUT Inserted.Id into @table Values('Brian', 'Keller', @@IDENTITY, '', null)
SELECT @eid2 = id from @table

DECLARE @eid3 int
INSERT INTO Address OUTPUT Inserted.Id Values('9342 2nd Street','Redmond','WA','98052')
INSERT INTO Employee OUTPUT Inserted.Id into @table Values('James', 'Conard', @@IDENTITY, '', null)
SELECT @eid3 = id from @table

-- Customer

DECLARE @cid0 int
INSERT INTO Address OUTPUT Inserted.Id Values('One Microsoft Way','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Maria', 'Cameron', @@IDENTITY)
SELECT @cid0 = id from @table

DECLARE @cid1 int
INSERT INTO Address OUTPUT Inserted.Id Values('45 Greenbelt Way','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Antonio', 'Alwan', @@IDENTITY)
SELECT @cid1 = id from @table

DECLARE @cid2 int
INSERT INTO Address OUTPUT Inserted.Id Values('123 Standard Street','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Patrick', 'Cook', @@IDENTITY)
SELECT @cid2 = id from @table

DECLARE @cid3 int
INSERT INTO Address OUTPUT Inserted.Id Values('9342 2nd Street','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Jane', 'Dow', @@IDENTITY)
SELECT @cid3 = id from @table

DECLARE @cid4 int
INSERT INTO Address OUTPUT Inserted.Id Values('361 North Avenue','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Michele', 'Martin', @@IDENTITY)
SELECT @cid4 = id from @table

DECLARE @cid5 int
INSERT INTO Address OUTPUT Inserted.Id Values('45 Greenbelt Way','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Dan', 'Bacon', @@IDENTITY)
SELECT @cid5 = id from @table

DECLARE @cid6 int
INSERT INTO Address OUTPUT Inserted.Id Values('123 Standard Street','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Johnson', 'Apacible', @@IDENTITY)
SELECT @cid6 = id from @table

DECLARE @cid7 int
INSERT INTO Address OUTPUT Inserted.Id Values('9342 2nd Street','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Pilar', 'Ackerman', @@IDENTITY)
SELECT @cid7 = id from @table

DECLARE @cid8 int
INSERT INTO Address OUTPUT Inserted.Id Values('361 North Avenue','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('David', 'Alexander', @@IDENTITY)
SELECT @cid8 = id from @table

DECLARE @cid9 int
INSERT INTO Address OUTPUT Inserted.Id Values('45 Greenbelt Way','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Jose', 'Auricchio', @@IDENTITY)
SELECT @cid9 = id from @table

DECLARE @cid10 int
INSERT INTO Address OUTPUT Inserted.Id Values('123 Standard Street','Redmond','WA','98052')
INSERT INTO Customer OUTPUT Inserted.Id into @table Values('Ty', 'Carlson', @@IDENTITY)
SELECT @cid10 = id from @table


-- Service Tickets

DECLARE @stid0 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table Values ('Modem keeps resetting itself',
	'About two months ago, I started getting randomly disconnected. My modem would lose its ONLINE green light, then the SEND light, then the RECEIVE, and then finally the POWER light would go and the modem would reset itself. I bought the new one wondering if it my old router might be the problem (it was fairly old). However, the problem still persists',
	4,
	1,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	null,
	@cid0,
	@eid1,
	@eid0)

	SELECT @stid0 = id from @table
	INSERT INTO ScheduleItem Values (@eid0, @stid0, CONVERT(datetime,'16-05-11 8:00:00 AM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120), 'Opened ticket for customer', @eid0, @stid0)

DECLARE @stid1 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table Values ('Internet Upload speed slow from 11pm-11am',
	'I''m extremely unhappy with the service I have recieved as of late from FabFiber. At night, my upload is garbage. I have the extreme 50 package and I''m only getting 1mb upload and anywhere from 1%-16% packetloss. This has been going on for a week and a half now.  I''ve had two techs come out here now and nobody seems to know what is going on.',
	2,
	2,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	CONVERT(varchar(10),(dateadd(dd, 2, getdate())),120),
	@cid0,
	@eid0,
	@eid2)

	SELECT @stid1 = id from @table
	INSERT INTO ServiceLogEntry Values (CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120), 'Opened ticket for customer', @eid0, @stid1)

DECLARE @stid2 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id Values ('FabFiber is the worst EVER!!!',
	'You guys set up and no-showed two service appointments in a row. You call, they set the appointment, then reschedule it (without notifying me) and of course the guarantee no longer applies.',
	1,
	1,
	dateadd(minute,-55,getdate()),
	null,
	@cid1,
	@eid0,
	@eid0)

	SELECT @stid2 = id from @table
	INSERT INTO ServiceLogEntry Values (dateadd(minute,-55,getdate()), 'Opened ticket for customer', @eid0, @stid2)

DECLARE @stid3 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table VALUES ('changing channel by it self',
	'TV changes channels by it self I even removed the batteries from remote and it still kept changing channels every couple of minutes what is going on this happen on only one tv out of 5 in the house?',
	4,
	1,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	null,
	@cid2,
	@eid0,
	@eid0)

	SELECT @stid3 = id from @table
	INSERT INTO ScheduleItem Values (@eid0, @stid3, CONVERT(datetime,'16-05-11 9:30:00 AM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120), 'Opened ticket for customer', @eid0, @stid3)

DECLARE @stid4 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table VALUES ('Viewing Recorded Programs',
	'I would like to know if it is possible to adjust the amount of "fast-forward" or "fast-rewind" time, using the remote, while viewing a recorded program.As the remote is set, the fast-forward goes somewhat too far ahead.',
	4,
	2,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	null,
	@cid3,
	@eid0,
	@eid2)

	SELECT @stid4 = id from @table
	INSERT INTO ScheduleItem Values (@eid1, @stid4, CONVERT(datetime,'16-05-11 10:00:00 AM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (CONVERT(datetime,'16-05-11 10:00:00 AM',5), 'Opened ticket for customer', @eid0, @stid4)

DECLARE @stid5 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table VALUES ('Issues with service',
	'About a month ago I started having issues with the TV, internet and phone. The TV was pixelating and when this happened I would also lose the internet connection and phone. I called and a technician came, he said the issue was with with a lose connection with the wires outside in the apartment complex. After he came in and fixed it, the issue went away for a few weeks. Now it''s back',
	4,
	1,
	dateadd(minute,-55,getdate()),
	null,
	@cid4,
	@eid0,
	@eid1)

	SELECT @stid5 = id from @table
	INSERT INTO ScheduleItem Values (@eid1, @stid5, CONVERT(datetime,'16-05-11 1:00:00 PM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (dateadd(minute,-55,getdate()), 'Opened ticket for customer', @eid0, @stid5)

DECLARE @stid6 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table VALUES ('Poor Picture Quality',
	'I just purchased a Fibrikam Fiber bundle and I am very dissatisfied with the picture quality to say the least. So far, two different service representatives have been out to look at the issue.  My picture is horribly fuzzy, grainy, blurry, and almost unwatchable.  The issue goes away when I hook the coax directly through my TV as opposed to using the provided cable box, but then I do not get as many channels.  The last service tech told me that you made some sort of change a while back and the picture quality has been poor ever since',
	4,
	1,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	null,
	@cid5,
	@eid0,
	@eid1)

	SELECT @stid6 = id from @table
	INSERT INTO ScheduleItem Values (@eid1, @stid6, CONVERT(datetime,'16-05-11 2:00:00 PM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120), 'Opened ticket for customer', @eid0, @stid6)

DECLARE @stid7 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table Values ('Channels gone!',
	'I got a digital set-top box 2 years ago. Since then I get all the HD channels, basic channels, and a bunch of channels in the 200''s. Since yesterday, when I turn to these stations in the 200s a gray box appears that says, "Subscription Service." Is this just a temporary problem? Why can I no longer access these channels? I am still paying the same amount, what is going on?',
	4,
	2,
	CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120),
	null,
	@cid6,
	@eid1,
	@eid2)

	SELECT @stid7 = id from @table
	INSERT INTO ScheduleItem Values (@eid2, @stid7, CONVERT(datetime,'16-05-11 8:00:00 AM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120), 'Opened ticket for customer', @eid0, @stid7)

DECLARE @stid8 int
INSERT INTO ServiceTicket OUTPUT Inserted.Id into @table Values ('Not getting all my channels',
	'I don''t have access to all the channels I supposedly get.  Every channel gives me the message that I need to contact Fabrikam Fiber to subscribe, even though it is on the lineup I print out.  I went to the local office and they said it starts November 1.  Well it is November 2 and still no access',
	4,
	1,
	dateadd(minute,-55,getdate()),
	null,
	@cid7,
	@eid1,
	@eid2)

	SELECT @stid8 = id from @table
	INSERT INTO ScheduleItem Values (@eid2, @stid8, CONVERT(datetime,'16-05-11 12:00:00 PM',5), 1, CONVERT(varchar(10),(dateadd(dd, -1, getdate())),120))
	INSERT INTO ServiceLogEntry Values (dateadd(minute,-55,getdate()), 'Opened ticket for customer', @eid0, @stid8)