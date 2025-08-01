USE Master;
GO
CREATE MASTER KEY ENCRYPTION
BY PASSWORD='password';
GO


CREATE CERTIFICATE TDE_Cert
WITH 
SUBJECT='Database_Encryption';
GO


BACKUP CERTIFICATE TDE_Cert
TO FILE = 'C:\storedcerts\SADDLEBROOKE_TDE_Cert'
WITH PRIVATE KEY (file='C:\\storedkeys\SADDLEBROOKE_TDE_CertKey.pvk',
ENCRYPTION BY PASSWORD='password') 



USE DBNAME
GO
CREATE DATABASE ENCRYPTION KEY
WITH ALGORITHM = AES_256
ENCRYPTION BY SERVER CERTIFICATE TDE_Cert;
GO


ALTER DATABASE DBNAME
SET ENCRYPTION ON;
GO