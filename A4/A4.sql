CREATE OR ALTER VIEW viewOnOneTable
AS
	SELECT * 
	FROM Passenger
	WHERE Status = 'student'

GO
CREATE OR ALTER VIEW viewOnTwoTables
AS
	
SELECT *
FROM Staff
WHERE Staff.Location <> ALL (SELECT rs.Location
							FROM RailwayStation rs
							WHERE rs.Country = 'Romania')
GO

CREATE OR ALTER VIEW viewGroupBy
AS
	--- compute the maximum salary above 1000 of employees for each country, with at least 2 stations
	SELECT rs.Country, MAX(s.Salary) as maximumSalary
	FROM Staff s INNER JOIN RailwayStation rs ON s.Location = rs.Location
	WHERE s.Salary > 1000
	GROUP BY rs.Country
	HAVING 2 <= (SELECT COUNT(*)
			FROM RailwayStation rs2
			WHERE rs.Country = rs2.Country)
GO

INSERT INTO Tables(Name)
VALUES('Passenger'), ('Route'), ('Driver_Train')


SELECT * FROM Route
SELECT * FROM Passenger
SELECT * FROM Driver_Train

INSERT INTO Views(Name)
VALUES('viewOnOneTable'), ('viewOnTwoTables'), ('viewGroupBy')

INSERT INTO Tests(Name)
VALUES ('test_1'),   --  10 rows
		('test_2'),  --- 100 rows
		('test_3'),  --- 1000 rows
		('test_4')   --- 10000 rows


INSERT INTO TestTables(TestID, TableID, NoOfRows, Position)
VALUES(1, 1, 10, 1),
		(1, 2, 10, 2),
		(1, 3, 10, 3),
		(2, 1, 100, 2),
		(2, 2, 100, 3),
		(2, 3, 100, 1),
		(3, 1, 1000, 3),
		(3, 2, 1000, 2),
		(3, 3, 1000, 1),
		(4, 1, 10000, 3),
		(4, 2, 10000, 1),
		(4, 3, 10000, 2)


INSERT INTO TestViews(TestID, ViewID)
VALUES (1,1), 
		(1,2),
		(1,3),
		(2,1),
		(2,2),
		(2,3),
		(3,1),
		(3,2),
		(3,3),
		(4,1),
		(4,2),
		(4,3)

SELECT * FROM Views
SELECT * FROM Tables
SELECT * FROM Tests
SELECT * FROM TestViews
SELECT * FROM TestTables


GO
CREATE OR ALTER PROCEDURE uspInsertTable9 @tableName VARCHAR(50), @numberOfRows INT
AS
BEGIN
	IF @tableName = 'Passenger'
	BEGIN
		DECLARE @name VARCHAR(50)
		DECLARE @cnp VARCHAR(50)
		DECLARE @email VARCHAR(50)
		DECLARE @status VARCHAR(50)
		DECLARE @dob date
		WHILE @numberOfRows > 0
		BEGIN
			SET @name = CONVERT(varchar(50), NEWID())
			SET @cnp = CONVERT(varchar(50), NEWID())
			SET @email = CONVERT(varchar(50), NEWID())
			SET @status = 'student'
			SET @dob = DATEADD(DAY, ABS(CHECKSUM(NEWID()) % 3650), '1990-01-01')

			INSERT INTO Passenger(Name, CNP, EmailAddress, DateOfBirth, Status)
			VALUES(@name, @cnp, @email, @dob, @status)
			SET @numberOfRows = @numberOfRows - 1
		END
	END

	ELSE IF @tableName = 'Route'
	BEGIN
		DECLARE @source VARCHAR(50)
		DECLARE @destination VARCHAR(50)
		SET @source = (SELECT TOP 1 Location FROM RailwayStation ORDER BY Location DESC)
		SET @destination = (SELECT TOP 1 Location FROM RailwayStation ORDER BY Location ASC)

		WHILE @numberOfRows > 0
		BEGIN
		
			INSERT INTO Route(Source, Destination)
			VALUES(@source, @destination)
			SET @numberOfRows = @numberOfRows - 1
		END
	END

	ELSE IF @tableName = 'Driver_Train'
	BEGIN

		DECLARE @inputID INT
		DECLARE @driverId INT
		DECLARE @trainId INT 
		--SET @driverId = (SELECT FLOOR(RAND()*(10000)))
		--SET @trainId = (SELECT FLOOR(RAND()*(10000)))

		SET @inputID = @numberOfRows
		WHILE @numberOfRows > 0
		BEGIN
			INSERT INTO Driver_Train(DriverID, TrainID)
			VALUES(@inputID, @inputID+1)
			SET @numberOfRows = @numberOfRows - 1
			SET @inputID = @inputID + 1
		END
	END
	ELSE
		BEGIN
			PRINT('Not a valid table name')
			RETURN 1
		END
END
GO


CREATE OR ALTER PROCEDURE uspGetIntValueFromReferencedTable(@refTable VARCHAR(50), @refColumn VARCHAR(50), @value INT OUTPUT)
AS
BEGIN

DECLARE @sqlStatement NVARCHAR(50)
DECLARE @ParmDefinition nvarchar(500);
PRINT 'HI'
SET @sqlStatement = N'SELECT TOP 1 ' + @refColumn +  ' FROM ' + @refTable
SET @ParmDefinition = N'@retvalOUT int OUTPUT';

EXEC sp_executesql @sqlStatement, @ParmDefinition, @retvalOUT=@value OUTPUT;
END
GO

CREATE OR ALTER PROCEDURE uspGetVarcharValueFromReferencedTable(@refTable VARCHAR(50), @refColumn VARCHAR(50), @value VARCHAR(50) OUTPUT)
AS
BEGIN

DECLARE @sqlStatement NVARCHAR(50)
DECLARE @ParmDefinition nvarchar(500);
PRINT 'HI'
SET @sqlStatement = N'SELECT TOP 1 ' + @refColumn +' FROM ' + @refTable
SET @ParmDefinition = N'@retvalOUT varchar(50) OUTPUT';

EXEC sp_executesql @sqlStatement, @ParmDefinition, @retvalOUT=@value OUTPUT;
END
GO

/*
DECLARE @val VARCHAR(50)
EXEC uspGetVarcharValueFromReferencedTable 'RailwayStation', 'Location',  @value = @val OUTPUT
PRINT @val
*/

GO
CREATE OR ALTER PROCEDURE uspInsertTable @tableName VARCHAR(50), @numberOfRows INT
AS
BEGIN

	IF @tableName IN (SELECT name FROM sys.objects WHERE type = 'U')
	BEGIN

		DECLARE @insertStatement as varchar(max)
		DECLARE @valuesStatement AS VARCHAR(MAX)
		DECLARE @columnIntValue INT
		DECLARE @columnVarcharValue VARCHAR(50)
		DECLARE @columnDateValue DATE
		DECLARE @columnName VARCHAR(50)
		DECLARE @columnType VARCHAR(50)
		DECLARE @referencedTable VARCHAR(50)
		DECLARE @referencedColumnId INT
		DECLARE @isIdentity BIT
		
	-- get data related to columns: name, type, maximum length, is primary key, is identity, is unique, is foreign key and the referenced column from the referenced table   
	DECLARE columnsCursor CURSOR FOR 
	SELECT sys.all_columns.name, sys.types.name, object_name(sys.foreign_key_columns.referenced_object_id) AS referencedTable, sys.foreign_key_columns.referenced_column_id AS referencedColumn, sys.all_columns.is_identity AS is_identity
	FROM ((sys.all_columns INNER JOIN sys.tables ON sys.all_columns.object_id = sys.tables.object_id AND sys.tables.name = @tableName) 
		INNER JOIN sys.types ON sys.all_columns.system_type_id = sys.types.system_type_id)
		LEFT JOIN sys.foreign_key_columns ON OBJECT_NAME(sys.foreign_key_columns.parent_object_id) = @tableName AND sys.all_columns.column_id = sys.foreign_key_columns.parent_column_id 

	WHILE @numberOfRows > 0
		BEGIN
			OPEN columnsCursor

			--- build an insert statement for each newly inserted row
			SET @insertStatement = 'INSERT INTO ' + @tableName + ' ('
			SET @valuesStatement = ' VALUES (' 

		    --- iterate through all the columnns with a cursor, identify their type and generate a random value
			FETCH FROM columnsCursor INTO @columnName, @columnType, @referencedTable, @referencedColumnId, @isIdentity
			WHILE @@FETCH_STATUS = 0
			BEGIN 
				IF @isIdentity = 0   ---  only generate a random value if the column is not an identity
				BEGIN
					SET @insertStatement = @insertStatement + @columnName + ','

					--- if it's a foreign key, we get a value from the referenced table
					if @referencedTable IS NOT NULL
					BEGIN
						DECLARE @referencedColumnName VARCHAR(50)
						SET @referencedColumnName = (SELECT name FROM sys.all_columns WHERE object_id = OBJECT_ID(@referencedTable) AND column_id = @referencedColumnId)

						IF @columnType = 'int'
						BEGIN
							EXEC uspGetIntValueFromReferencedTable @referencedTable , @referencedColumnName , @value = @columnIntValue OUTPUT
							
							PRINT 'Got '  + CAST(@columnIntValue AS VARCHAR(10))
							SET @valuesStatement = @valuesStatement + CAST(@columnIntValue AS VARCHAR(10)) + ','
						END

						ELSE IF @columnType = 'varchar'
						BEGIN
							EXEC uspGetVarcharValueFromReferencedTable @referencedTable , @referencedColumnName , @value = @columnVarcharValue OUTPUT
							PRINT 'Got ' + @columnVarcharValue
							SET @valuesStatement = @valuesStatement + ''''+ @columnVarcharValue + ''','
						END
					END

					---- if it's a primary key
					--- we will assign to it the current number of rows, to ensure its unicity across all rows
					ELSE IF EXISTS(SELECT *
					FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE c
					WHERE c.CONSTRAINT_NAME like 'PK%' and @columnName = c.COLUMN_NAME and @tableName = c.TABLE_NAME
					) BEGIN
						IF @columnType = 'int'
							SET @valuesStatement = @valuesStatement + CAST(@numberOfRows AS VARCHAR(10)) + ','
						IF @columnType = 'varchar'
						BEGIN
							SET @valuesStatement = @valuesStatement + '''' + CAST(@numberOfRows AS VARCHAR(10)) + ''','

						END
					END

					--- if it's just a simple field, generate random values
					ELSE if @columnType = 'int'
					BEGIN
						SET @columnIntValue = (SELECT FLOOR(RAND()*(1000)))
						SET @valuesStatement = @valuesStatement + CAST(@columnIntValue AS VARCHAR(10)) + ','
					END

					ELSE IF  @columnType = 'varchar'
					BEGIN
						SET @columnVarcharValue = (CONVERT(varchar(50), NEWID()))
						SET @valuesStatement = @valuesStatement + '''' + + @columnVarcharValue + ''','
					END

					ELSE if @columnType = 'date'
					BEGIN
						SET @columnDateValue = (SELECT DATEADD(DAY, CONVERT(int, CRYPT_GEN_RANDOM(2)), '1960-01-01T00:00:00'))
						SET @valuesStatement = @valuesStatement + '''' + CAST(@columnDateValue AS VARCHAR(10)) + ''','
					END
				END
					
				FETCH FROM columnsCursor INTO @columnName ,@columnType, @referencedTable, @referencedColumnId, @isIdentity
			END
			CLOSE columnsCursor
		
			--- execute the insert statement
			set @insertStatement = LEFT(@insertStatement, len(@insertStatement)-1) + ')'
			set @valuesStatement = LEFT(@valuesStatement, len(@valuesStatement)-1) + ')'
			set @insertStatement = @insertStatement + @valuesStatement
			PRINT @insertStatement
			exec(@insertStatement)
			SET @numberOfRows = @numberOfRows - 1
		END
	DEALLOCATE columnsCursor
	END
	ELSE
		PRINT 'Table name is not valid'
END
GO

DELETE FROM Passenger
SELECT * FROM Passenger
EXEC uspInsertTable 'Passenger', 10

DELETE FROM Driver_Train
SELECT * FROM Driver_Train
EXEC uspInsertTable 'Driver_Train', 10

DELETE FROM Route
SELECT * FROM Route
EXEC uspInsertTable 'Route', 10


DELETE FROM Staff
SELECT * FROM Staff
EXEC uspInsertTable 'Staff', 10

DELETE FROM TicketValidator
SELECT * FROM TicketValidator
EXEC uspInsertTable 'TicketValidator', 10

GO
CREATE OR ALTER PROCEDURE uspDeleteTableContent @tableName VARCHAR(50)
AS
BEGIN

	--- chack that the table name is valid 
	IF @tableName IN (SELECT name FROM sys.objects WHERE type = 'U')
	BEGIN
		DECLARE @sqlStatement NVARCHAR(50)
		SET @sqlStatement = N'DELETE FROM ' + @tableName
		EXECUTE sp_executesql @sqlStatement
		PRINT 'Deleted all content from ' + @tableName
	END
	ELSE
		PRINT 'Table name is not valid'
END

GO


CREATE OR ALTER PROCEDURE uspEvaluateView @viewName VARCHAR(50)
AS
BEGIN
	---- check that the viewName is valid
	IF @viewName IN (SELECT name FROM sys.all_views)
	BEGIN
		DECLARE @sqlStatement NVARCHAR(50)
		DECLARE @paramDefinition NVARCHAR(50)

		PRINT @viewName
		SET @sqlStatement = N'SELECT * FROM ' + @viewName
		-- SET @paramDefinition = N'@view VARCHAR(50)'

		--EXECUTE sp_executesql @sqlStatement, @paramDefinition, @view = @viewName
		EXECUTE sp_executesql @sqlStatement
	END
	ELSE
		PRINT 'Not a valid view name'
END

GO
CREATE OR ALTER PROCEDURE uspRunTest @testID INT
AS
BEGIN
	--- variables we will need
	DECLARE @tableID INT
	DECLARE @tableName VARCHAR(30)
	DECLARE @noOfRows INT
	DECLARE @startAt DATETIME
	DECLARE @endAt DATETIME
	DECLARE @viewId INT
	DECLARE @viewName VARCHAR(30)
	
	--- log the test into the testRuns table
	INSERT INTO TestRuns VALUES((SELECT Name FROM Tests WHERE TestID = @testID), GETDATE(), GETDATE())
	DECLARE @testRunId INT 
	SET @testRunId = (SELECT MAX(TestRunID) FROM TestRuns)


	--- iterate through the tables of the test and delete their content with exec
	DECLARE deleteTablesCursor CURSOR FOR
	SELECT TableID
	FROM TestTables
	WHERE TestID = @testID
	ORDER BY Position ASC

	OPEN deleteTablesCursor

	FETCH FROM deleteTablesCursor INTO @tableID

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @tableName = (SELECT Name FROM Tables WHERE TableID = @tableID)
		EXEC uspDeleteTableContent @tableName
		FETCH FROM deleteTablesCursor INTO @tableID
	END
	CLOSE deleteTablesCursor
	DEALLOCATE deleteTablesCursor

	--- iterate through the tables of the test in the reverse order, insert rows with exec and log them in TestRunTables

	DECLARE insertTablesCursor CURSOR FOR
	SELECT TableID, NoOfRows
	FROM TestTables
	WHERE TestID = @testID
	ORDER BY Position DESC

	OPEN insertTablesCursor

	FETCH FROM insertTablesCursor INTO @tableID, @noOfRows

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @tableName = (SELECT Name FROM Tables WHERE TableID = @tableID)

		SET @startAt = GETDATE()
		EXEC uspInsertTable9 @tableName, @noOfRows
		SET @endAt = GETDATE()

		INSERT INTO TestRunTables VALUES(@testRunId, @tableID, @startAt, @endAt)
		FETCH FROM insertTablesCursor INTO @tableID, @noOfRows
	END

	CLOSE insertTablesCursor
	DEALLOCATE insertTablesCursor

	--- iterate through the views, evaluate them with exec and log them in TestRunViews

	DECLARE evaluateViewsCursor CURSOR FOR
	SELECT ViewID
	FROM TestViews
	WHERE TestID = @testID

	OPEN evaluateViewsCursor

	FETCH FROM evaluateViewsCursor INTO @viewId

	WHILE @@FETCH_STATUS = 0
	BEGIN 
		SET @viewName = (SELECT Name FROM Views WHERE ViewID = @viewId)

		SET @startAt = GETDATE()
		EXEC uspEvaluateView @viewName
		SET @endAt = GETDATE()

		INSERT INTO TestRunViews VALUES(@testRunId, @viewId, @startAt, @endAt)
		FETCH FROM evaluateViewsCursor INTO @viewId
	END
	CLOSE evaluateViewsCursor
	DEALLOCATE evaluateViewsCursor

	UPDATE TestRuns
	SET EndAt = GETDATE()
	WHERE TestRunID = @testRunId
END

EXEC uspRunTest 4


DELETE FROM TestRuns
DELETE FROM TestRunTables
DELETE FROM TestRunViews
DELETE FROM TestTables
DELETE FROM TestViews
DELETE FROM Tables
DELETE FROM Tests
DELETE FROM Views


SELECT * FROM TestRuns
SELECT * FROM TestRunTables
SELECT * FROM TestRunViews
SELECT * FROM Tables
SELECT * FROM Views
SELECT * FROM TestTables
SELECT * FROM TestViews
SELECT * FROM Tests

SELECT * FROM Passenger
SELECT * FROM Route