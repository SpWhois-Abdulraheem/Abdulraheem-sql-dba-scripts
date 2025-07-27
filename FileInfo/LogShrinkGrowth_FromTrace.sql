select path 
 from sys.traces 
 where is_default = 1

SELECT 
    TextData,
    HostName,
    ApplicationName,
    LoginName, 
    StartTime  
FROM 
[fn_trace_gettable]('E:\data\MSSQL13.PTES\MSSQL\Log\log_63.trc', DEFAULT) 
WHERE TextData LIKE '%SHRINKFILE%';

--use older trace files if needed