/****************************************
		Role Creation Script
	
	This script creates the procrunner
	and procviewer roles and associated
	schema objects.

	This does not grant any rights to
	roles. The procrunner/procviewer
	cursors do that.
	
  YOU MUST HAVE OWNERSHIP PERMISSIONS
	  ON THE DB TO RUN THIS SCRIPT
*****************************************/

CREATE SCHEMA [db_procrunner] AUTHORIZATION [dbo]
GO
CREATE SCHEMA [db_procviewer] AUTHORIZATION [dbo]
GO

CREATE ROLE [db_procrunner] AUTHORIZATION [dbo]
GO
CREATE ROLE [db_procviewer] AUTHORIZATION [dbo]
GO

ALTER AUTHORIZATION ON SCHEMA::[db_procrunner] TO [db_procrunner]
GO
ALTER AUTHORIZATION ON SCHEMA::[db_procviewer] TO [db_procviewer]
GO

--EXEC sp_addrolemember db_procrunner, [AMTRUSTSERVICES\Developers]
--GO
--EXEC sp_addrolemember db_procviewer, [AMTRUSTSERVICES\Developers]
--GO