
USE [DB_Utility]
GO

--Deadlock Report
--Only alter the AlertTimeRange below to examine deadlocks in a given time frame, or Enter a specific DeadlockID
WITH CTE AS 
(
SELECT  DeadlockID,
        DeadlockGraph,
		AlertTime
FROM    DB_Utility.dbo.DeadlockProcessEventLog
WHERE DeadlockID = 12
--WHERE AlertTime >= '2016-03-08 08:00:00.000'
--AND AlertTime <= '2016-03-08 16:30:00.000'
), 
Victims AS 
(
SELECT    ID = Victims.List.value('@id', 'varchar(50)')
FROM      CTE
          CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/victim-list/victimProcess') AS Victims (List)
), 
Locks AS 
(
-- Merge all of the lock information together.
SELECT  CTE.DeadlockID,
        MainLock.Process.value('@id', 'varchar(100)') AS LockID,
        OwnerList.Owner.value('@id', 'varchar(200)') AS LockProcessId,
        REPLACE(MainLock.Process.value('local-name(.)', 'varchar(100)'), 'lock', '') AS LockEvent,
        MainLock.Process.value('@objectname', 'sysname') AS ObjectName,
        OwnerList.Owner.value('@mode', 'varchar(10)') AS LockMode,
        MainLock.Process.value('@dbid', 'INTEGER') AS Database_id,
        MainLock.Process.value('@associatedObjectId', 'BIGINT') AS AssociatedObjectId,
        MainLock.Process.value('@WaitType', 'varchar(100)') AS WaitType,
        WaiterList.Owner.value('@id', 'varchar(200)') AS WaitProcessId,
        WaiterList.Owner.value('@mode', 'varchar(10)') AS WaitMode
FROM    CTE
        CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/resource-list') AS Lock (list)
        CROSS APPLY Lock.list.nodes('*') AS MainLock (Process)
        OUTER APPLY MainLock.Process.nodes('owner-list/owner') AS OwnerList (Owner)
        CROSS APPLY MainLock.Process.nodes('waiter-list/waiter') AS WaiterList (Owner)
), 
Process AS 
(
-- get the data from the process node
SELECT  CTE.DeadlockID,
		CTE.AlertTime,
        [Victim] = CONVERT(BIT, CASE WHEN Deadlock.Process.value('@id', 'varchar(50)') = ISNULL(Deadlock.Process.value('../../@victim', 'varchar(50)'), v.ID) 
                                     THEN 1
                                     ELSE 0
                                END),
        [LockMode] = Deadlock.Process.value('@lockMode', 'varchar(10)'), -- how is this different from in the resource-list section?
        [ProcessID] = Process.ID, --Deadlock.Process.value('@id', 'varchar(50)'),
        [KPID] = Deadlock.Process.value('@kpid', 'int'), -- kernel-process id / thread ID number
        [SPID] = Deadlock.Process.value('@spid', 'int'), -- system process id (connection to sql)
        [SBID] = Deadlock.Process.value('@sbid', 'int'), -- system batch id / request_id (a query that a SPID is running)
        [ECID] = Deadlock.Process.value('@ecid', 'int'), -- execution context ID (a worker thread running part of a query)
        [IsolationLevel] = Deadlock.Process.value('@isolationlevel', 'varchar(200)'),
        [WaitResource] = Deadlock.Process.value('@waitresource', 'varchar(200)'),
        [LogUsed] = Deadlock.Process.value('@logused', 'int'),
        [ClientApp] = Deadlock.Process.value('@clientapp', 'varchar(100)'),
        [HostName] = Deadlock.Process.value('@hostname', 'varchar(100)'),
        [LoginName] = Deadlock.Process.value('@loginname', 'varchar(100)'),
        [TransactionTime] = Deadlock.Process.value('@lasttranstarted', 'datetime'),
        [BatchStarted] = Deadlock.Process.value('@lastbatchstarted', 'datetime'),
        [BatchCompleted] = Deadlock.Process.value('@lastbatchcompleted', 'datetime'),
        [InputBuffer] = Input.Buffer.query('.'),
        CTE.[DeadlockGraph],
        es.ExecutionStack,
        [SQLHandle] = ExecStack.Stack.value('@sqlhandle', 'varchar(64)'),
        [QueryStatement] = NULLIF(ExecStack.Stack.value('.', 'varchar(max)'), ''),
        --[QueryStatement] = Execution.Frame.value('.', 'varchar(max)'),
        [ProcessQty] = SUM(1) OVER (PARTITION BY CTE.DeadlockID),
        [TranCount] = Deadlock.Process.value('@trancount', 'int')
FROM    CTE
        CROSS APPLY CTE.DeadlockGraph.nodes('//deadlock/process-list/process') AS Deadlock (Process)
        CROSS APPLY (SELECT Deadlock.Process.value('@id', 'varchar(50)') ) AS Process (ID)
        LEFT JOIN Victims v ON Process.ID = v.ID
        CROSS APPLY Deadlock.Process.nodes('inputbuf') AS Input (Buffer)
        CROSS APPLY Deadlock.Process.nodes('executionStack') AS Execution (Frame)
-- get the data from the executionStack node as XML
        CROSS APPLY (SELECT ExecutionStack = (SELECT   ProcNumber = ROW_NUMBER() 
                                                                    OVER (PARTITION BY CTE.DeadlockID,
                                                                                       Deadlock.Process.value('@id', 'varchar(50)'),
                                                                                       Execution.Stack.value('@procname', 'sysname'),
                                                                                       Execution.Stack.value('@code', 'varchar(MAX)') 
                                                                              ORDER BY (SELECT 1)),
                                                        ProcName = Execution.Stack.value('@procname', 'sysname'),
                                                        Line = Execution.Stack.value('@line', 'int'),
                                                        SQLHandle = Execution.Stack.value('@sqlhandle', 'varchar(64)'),
                                                        Code = LTRIM(RTRIM(Execution.Stack.value('.', 'varchar(MAX)')))
                                                FROM Execution.Frame.nodes('frame') AS Execution (Stack)
                                                ORDER BY ProcNumber
                                                FOR XML PATH('frame'), ROOT('executionStack'), TYPE )
                    ) es
        CROSS APPLY Execution.Frame.nodes('frame') AS ExecStack (Stack)
)
--Final Select
SELECT  p.DeadlockID,
		p.AlertTime,
		DB_NAME(CONVERT(INTEGER,l.database_id)) as 'Database',
        LockedObject = NULLIF(l.ObjectName, ''),
		p.QueryStatement,
		p.Victim,
        p.ProcessQty,
        ProcessNbr = DENSE_RANK() 
                     OVER (PARTITION BY p.DeadlockId 
                               ORDER BY p.ProcessID),
        p.LockMode,
        --l.AssociatedObjectId as 'AssociatedObject',
        LockProcess = p.ProcessID,
        --p.KPID,
        p.SPID,
        --p.SBID,
        --p.ECID,
        --p.TranCount,
        --l.LockEvent,
        --LockedMode = l.LockMode,
        l.WaitProcessID,
        l.WaitMode,
        --p.WaitResource,
        --l.WaitType,
        --p.IsolationLevel,
        --p.LogUsed,
        p.ClientApp,
        p.HostName,
        p.LoginName,
        --p.TransactionTime,
        --p.BatchStarted,
        --p.BatchCompleted,
        --p.SQLHandle,
        --p.InputBuffer,
        --p.DeadlockGraph,
        p.ExecutionStack
FROM    Process p
LEFT JOIN Locks l
ON p.DeadlockID = l.DeadlockID
AND p.ProcessID = l.LockProcessID
ORDER BY p.DeadlockId,
        p.Victim DESC,
        p.ProcessId;
