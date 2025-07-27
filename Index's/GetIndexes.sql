


/*******************************************
	Script to Script all non-PK Indexes	and Procs	
*******************************************/



PRINT 'USE ' + db_name() 
--PRINT 'GO' + '--'
PRINT ''

-- Get all existing indexes, but NOT the primary keys
DECLARE cIX CURSOR FOR
	SELECT	OBJECT_NAME(SI.Object_ID), 
			SI.Object_ID, 
			SI.Name, 
			SI.Index_ID
	FROM Sys.Indexes SI 
	LEFT JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC 
		ON	SI.Name = TC.CONSTRAINT_NAME 
		AND OBJECT_NAME(SI.Object_ID) = TC.TABLE_NAME
	WHERE	TC.CONSTRAINT_NAME IS NULL
		AND OBJECTPROPERTY(SI.Object_ID, 'IsUserTable') = 1
		AND OBJECTPROPERTY(SI.Object_ID, 'IsMSShipped') = 0
		AND SI.Index_ID <> 0
		and is_hypothetical = 0
	ORDER BY OBJECT_NAME(SI.Object_ID), SI.Index_ID

DECLARE @IxTable SYSNAME
DECLARE @IxTableID INT
DECLARE @IxName SYSNAME
DECLARE @IxID INT

-- Loop through all indexes
OPEN cIX
FETCH NEXT FROM cIX INTO @IxTable, @IxTableID, @IxName, @IxID
WHILE (@@FETCH_STATUS = 0)
BEGIN
	DECLARE @IFSQL NVARCHAR(4000) --Variable for IF NOT EXISTS statement
	DECLARE @IXSQL NVARCHAR(4000) --Variable for CREATE statement
	
	SET @IFSQL = 'IF NOT EXISTS(SELECT [object_id] FROM sys.indexes WHERE [object_id] = OBJECT_ID(''' + @IxTable + ''') AND [name] = ''' + @IxName + ''')'
	SET @IXSQL = '    CREATE '

	-- Check if the index is unique
	IF (INDEXPROPERTY(@IxTableID, @IxName, 'IsUnique') = 1)
		SET @IXSQL = @IXSQL + 'UNIQUE '
	-- Check if the index is clustered
	IF (INDEXPROPERTY(@IxTableID, @IxName, 'IsClustered') = 1)
		SET @IXSQL = @IXSQL + 'CLUSTERED '

	SET @IXSQL = @IXSQL + 'INDEX ' + '[' + @IxName + ']' +  ' ON ' + @IxTable + '('

	-- Get all columns of the index
	DECLARE cIxColumn CURSOR FOR 
		SELECT SC.Name
		FROM Sys.Index_Columns IC
			JOIN Sys.Columns SC ON IC.Object_ID = SC.Object_ID AND IC.Column_ID = SC.Column_ID
		WHERE IC.Object_ID = @IxTableID AND Index_ID = @IxID and ic.is_included_column = 0 --exclude included column
		ORDER BY IC.Index_Column_ID

	DECLARE @IxColumn SYSNAME
	DECLARE @IxFirstColumn BIT SET @IxFirstColumn = 1

	-- Loop throug all columns of the index and append them to the CREATE statement
	OPEN cIxColumn
	FETCH NEXT FROM cIxColumn INTO @IxColumn
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF (@IxFirstColumn = 1)
			SET @IxFirstColumn = 0
		ELSE
			SET @IXSQL = @IXSQL + ', '

		SET @IXSQL = @IXSQL + @IxColumn

		FETCH NEXT FROM cIxColumn INTO @IxColumn
	END
	CLOSE cIxColumn
	DEALLOCATE cIxColumn

	--##############################################
	-- Get any included columns of the index
	
	declare @includedcount as INT
	set @includedcount =(select count(SC.Name)
		FROM Sys.Index_Columns IC
			JOIN Sys.Columns SC ON IC.Object_ID = SC.Object_ID AND IC.Column_ID = SC.Column_ID
		WHERE IC.Object_ID = @IxTableID AND Index_ID = @IxID and ic.is_included_column = 1) 

	if @includedcount > 1 
	begin
	DECLARE cIxColumnINCLUDE CURSOR FOR 
		SELECT SC.Name
		FROM Sys.Index_Columns IC
			JOIN Sys.Columns SC ON IC.Object_ID = SC.Object_ID AND IC.Column_ID = SC.Column_ID
		WHERE IC.Object_ID = @IxTableID AND Index_ID = @IxID and ic.is_included_column = 1 --only included column
		ORDER BY IC.Index_Column_ID

	DECLARE @IxColumnINCLUDE SYSNAME
	DECLARE @IxFirstColumnInc BIT SET @IxFirstColumnInc = 1

	-- Loop throug all columns of the index and append them to the CREATE statement
	OPEN cIxColumnINCLUDE
	FETCH NEXT FROM cIxColumnINCLUDE INTO @IxColumnINCLUDE 
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
		IF (@IxFirstColumnInc = 1)
			begin
				SET @IxFirstColumnInc = 0
				SET @IXSQL = @IXSQL + ') INCLUDE('
			end
		ELSE
			begin
			SET @IXSQL = @IXSQL + ', '
			end
		SET @IXSQL = @IXSQL + @IxColumnINCLUDE 

		FETCH NEXT FROM cIxColumnINCLUDE INTO @IxColumnINCLUDE 
	END
	
	CLOSE cIxColumnINCLUDE
	DEALLOCATE cIxColumnINCLUDE
	SET @IXSQL = @IXSQL + ') WITH (ONLINE = ON, Data_Compression = Page, FILLFACTOR = 80)'
	end
	else 
		begin
		If @includedcount = 1 
			begin
			Set @IxColumnINCLUDE = (SELECT SC.Name
		FROM Sys.Index_Columns IC
			JOIN Sys.Columns SC ON IC.Object_ID = SC.Object_ID AND IC.Column_ID = SC.Column_ID
		WHERE IC.Object_ID = @IxTableID AND Index_ID = @IxID and ic.is_included_column = 1 --exclude included column
		)
		SET @IXSQL = @IXSQL + ') INCLUDE('+@IxColumnINCLUDE+') WITH (ONLINE = ON, Data_Compression = Page, FILLFACTOR = 80)'
			end
		else
			begin			
			SET @IXSQL = @IXSQL + ') WITH (ONLINE = ON, Data_Compression = Page, FILLFACTOR = 80)'
			end
		end

	print 'GO'
	PRINT @IFSQL
	PRINT @IXSQL
	PRINT ' '

	FETCH NEXT FROM cIX INTO @IxTable, @IxTableID, @IxName, @IxID
END

CLOSE cIX
DEALLOCATE cIX

