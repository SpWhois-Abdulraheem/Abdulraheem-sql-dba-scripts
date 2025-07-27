--This script shows indexes which are never used but updated costing you both CPU time and memory.  It can be modified with a where to pull up specific indexes you want to view.

select user_seeks, user_scans, user_lookups, user_updates, name, type_desc from sys.dm_db_index_usage_stats as s
inner join sys.indexes as i on i.[OBJECT_ID] = s.[OBJECT_ID] and i.INDEX_ID = s.INDEX_ID
where name = 'IX_PLPolicyTodoList_ClosedDate' or name = 'IX_PLPolicyTodoList_GetList' or name = 'IX_PLPolicyTodoList_PLPolicyTodoListID' or name = 'IX_PLPolicyTodoList_PolicyID' or name = 'PK_PLPolicyTodoList'