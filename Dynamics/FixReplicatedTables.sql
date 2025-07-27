

DECLARE @command varchar(max) 

SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN 
print ''?''
USE [?] 
if exists (select * from sysobjects where name=''vendor'' and xtype=''U'')
GRANT CONTROL ON [dbo].[Vendor] TO [MSDSL]

if exists (select * from sysobjects where name=''vendor'' and xtype=''U'')
GRANT SELECT ON [dbo].[Vendor] TO [E8F575915A2E4897A517779C0DD7CE]

if exists (select * from sysobjects where name=''POAddress'' and xtype=''U'')
GRANT CONTROL ON [dbo].[POAddress] TO [MSDSL]

if exists (select * from sysobjects where name=''POAddress'' and xtype=''U'')
GRANT SELECT ON [dbo].[POAddress] TO [E8F575915A2E4897A517779C0DD7CE]

if exists (select * from sysobjects where name=''XDDBankHolidays'' and xtype=''U'')
GRANT CONTROL ON [dbo].[XDDBankHolidays] TO [MSDSL]

if exists (select * from sysobjects where name=''XDDBankHolidays'' and xtype=''U'')
GRANT SELECT ON [dbo].[XDDBankHolidays] TO [E8F575915A2E4897A517779C0DD7CE]
  end 
   ' 

EXEC sp_MSforeachdb @command ;
GO


------indexes--------

DECLARE @command varchar(max) 

SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN 
print ''?''
USE [?] 
SET ANSI_PADDING ON

if exists (select * from sysobjects where name=''vendor'' and xtype=''U'')
begin
if not exists (select * from sysindexes
  where id=object_id(''Vendor'') and name=''Vendor1'')
CREATE NONCLUSTERED INDEX [Vendor1] ON [dbo].[Vendor]
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

if not exists (select * from sysindexes
  where id=object_id(''Vendor'') and name=''Vendor2'')
CREATE NONCLUSTERED INDEX [Vendor2] ON [dbo].[Vendor]
(
	[Phone] ASC,
	[VendId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

if not exists (select * from sysindexes
  where id=object_id(''Vendor'') and name=''Vendor3'')
CREATE NONCLUSTERED INDEX [Vendor3] ON [dbo].[Vendor]
(
	[Zip] ASC,
	[VendId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

if not exists (select * from sysindexes
  where id=object_id(''Vendor'') and name=''Vendor4'')
CREATE NONCLUSTERED INDEX [Vendor4] ON [dbo].[Vendor]
(
	[Curr1099Yr] ASC,
	[VendId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
end
  end 
   ' 

EXEC sp_MSforeachdb @command ;
GO
--Fix error for new DB's

DECLARE @command varchar(max) 

SELECT @command = 'IF ''?'' NOT IN(''master'', ''model'', ''msdb'', ''tempdb'') BEGIN 

print ''?''
USE [?] 

GRANT SELECT ON  vs_company TO [07718158D19D4f5f9D23B55DBF5DF1]
GRANT SELECT ON  vs_company TO [E8F575915A2E4897A517779C0DD7CE]

END'

EXEC sp_MSforeachdb @command ;
