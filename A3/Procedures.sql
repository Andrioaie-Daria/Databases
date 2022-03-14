--- stores a single row with the current version
DROP TABLE CurrentVersion
CREATE TABLE CurrentVersion(
	currentVersion INT DEFAULT 0)

INSERT INTO CurrentVersion
VALUES(0)

SELECT * FROM CurrentVersion
GO

DROP TABLE historyOfExecutedProcedures
CREATE TABLE historyOfExecutedProcedures(
	executed_procedure VARCHAR(50),
	reverse_procedure VARCHAR(50),
	toVersion INT)


INSERT INTO historyOfExecutedProcedures
VALUES('uspCreateTableFinesPassengers', 'uspUndoCreateTableFinesPassengers', 1),
	  ('uspAddColumnPaid', 'uspUndoAddColumnPaid', 2),
	  ('uspAddCandidateKeyPassengerName', 'uspUndoAddCandidateKeyPassengerName', 2),
	  ('uspModifyDateTypes', 'uspUndoModifyDateTypes', 3),
	  ('uspAddDefaultFineValue', 'uspUndoAddDefaultFineValue', 4),
	  ('uspRemoveForeignKeyFineType', 'uspUndoRemoveForeignKeyFineType', 4),
	  ('uspRemovePrimaryKeyPassengerType', 'uspUndoRemovePrimaryKeyPassengerType', 5);

SELECT * FROM historyOfExecutedProcedures


DROP PROCEDURE uspChangeVersion
GO
CREATE OR ALTER PROCEDURE uspChangeVersion @toVersion INT
AS
BEGIN
	
	--- we first ckeck that the version is valid and throw an error if it's not
	DECLARE @maximumAvailableVersion INT
	SET @maximumAvailableVersion = (SELECT MAX(toVersion) FROM historyOfExecutedProcedures)

	IF @toVersion < 0 OR @toVersion > @maximumAvailableVersion
	BEGIN
		DECLARE @error_message AS NVARCHAR(50)
		SET @error_message = 'The version must be within the interval 0 : ' + CAST(@maximumAvailableVersion AS NVARCHAR(10));
		THROW 50000, @error_message, 1
	END

	--- get the current version from the table
	DECLARE @current_version INT;
	DECLARE @current_procedure NVARCHAR(50)
	SET @current_version = (SELECT currentVersion FROM CurrentVersion)

	--- we need these variables when we want to execute the procedures using sql_executesql
	DECLARE @SQLExecStatement NVARCHAR(50)
	DECLARE @ParamDefinition NVARCHAR(50)

	SET @SQLExecStatement = N'EXEC @procedure'
	SET @ParamDefinition = N'@procedure VARCHAR(50)'

	
	--- case 1. we go to a higher version
	WHILE @current_version < @toVersion 
	BEGIN
		PRINT N'The database is now in version ' + CAST(@current_version AS NVARCHAR(10))
		
		--- iterate through the set of procedures that lead to the very next version
		DECLARE Procedures_Cursor CURSOR FOR
			SELECT executed_procedure
			FROM historyOfExecutedProcedures
			WHERE toVersion = @current_version + 1
		OPEN Procedures_Cursor
		FETCH FROM Procedures_Cursor INTO @current_procedure

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT N'Executing procedure ' + @current_procedure
			---- execute the procedure
			EXECUTE sp_executesql @SQLExecStatement, @ParamDefinition, @procedure = @current_procedure;
			
			-- go to the next procedure to be executed
			FETCH FROM Procedures_Cursor INTO @current_procedure
		END
		CLOSE Procedures_Cursor
		DEALLOCATE Procedures_Cursor
		-- advance the current version
		SET @current_version += 1
	END

	--- case 2. we go to a lower version
	WHILE @current_version > @toVersion 
	BEGIN
		PRINT N'The data base is now in version ' + CAST(@current_version AS NVARCHAR(10))

		--- iterate backwards through the set of reverse procedures in the current version
		DECLARE Reverse_Procedures_Cursor CURSOR SCROLL FOR
			SELECT reverse_procedure
			FROM historyOfExecutedProcedures
			WHERE toVersion = @current_version
		OPEN Reverse_Procedures_Cursor
		FETCH LAST FROM Reverse_Procedures_Cursor INTO @current_procedure

		WHILE @@FETCH_STATUS = 0
		BEGIN
			PRINT N'Executing procedure ' + @current_procedure
			---- here we execute the procedure
			EXECUTE sp_executesql @SQLExecStatement, @ParamDefinition, @procedure = @current_procedure;
			--- go to the next procedure
			FETCH PRIOR FROM Reverse_Procedures_Cursor INTO @current_procedure
		END
		CLOSE Reverse_Procedures_Cursor
		DEALLOCATE Reverse_Procedures_Cursor
		SET @current_version -=1
	END

	--- finally, update the current version in the outer table
	UPDATE CurrentVersion
	SET currentVersion = @current_version


	IF @current_version = @toVersion
	BEGIN
		PRINT 'The database is now in version ' + CAST(@current_version AS NVARCHAR(2))
	END
END
GO

EXEC uspChangeVersion 0

-- a. modify the type of a column;
GO 

CREATE OR ALTER PROCEDURE uspModifyDateTypes
AS 
	ALTER TABLE Fines_Passengers
	ALTER COLUMN ReceivedDate DATE NOT NULL

	ALTER TABLE Fines_Passengers
	ALTER COLUMN PaidDate DATE
GO

EXEC uspModifyDateTypes


--- reverse of modifying the date types

GO 
CREATE OR ALTER PROCEDURE uspUndoModifyDateTypes
AS 
	ALTER TABLE Fines_Passengers
	ALTER COLUMN ReceivedDate VARCHAR(100) NOT NULL

	ALTER TABLE Fines_Passengers
	ALTER COLUMN PaidDate VARCHAR(100)
GO

EXEC uspUndoModifyDateTypes


-- b. add column;
GO
CREATE OR ALTER PROCEDURE uspAddColumnPaid
AS
	ALTER TABLE Fines_Passengers
	ADD isPaid BIT
GO

EXEC uspAddColumnPaid

-- reverse of adding a column

GO
CREATE OR ALTER PROCEDURE uspUndoAddColumnPaid
AS
	ALTER TABLE Fines_Passengers
	DROP COLUMN isPaid
GO

EXEC uspUndoAddColumnPaid


-- c. add a DEFAULT constraint;

GO
CREATE OR ALTER PROCEDURE uspAddDefaultFineValue
AS 
	ALTER TABLE Fine
	ADD CONSTRAINT DefaultFineValue
	DEFAULT 100 for Value
GO

EXEC uspAddDefaultFineValue

--- reverse of adding a default constraint

GO
CREATE OR ALTER PROCEDURE uspUndoAddDefaultFineValue
AS 
	ALTER TABLE Fine
	DROP CONSTRAINT DefaultFineValue
GO

EXEC uspUndoAddDefaultFineValue

-- d. remove a primary key;

GO
CREATE OR ALTER PROCEDURE uspRemovePrimaryKeyPassengerType
AS 
	ALTER TABLE Fines_Passengers
	DROP CONSTRAINT PK_Passenger_Type
GO

EXEC uspRemovePrimaryKeyPassengerType

--- reverse of removing the primary key 

GO
CREATE OR ALTER PROCEDURE uspUndoRemovePrimaryKeyPassengerType
AS 
	ALTER TABLE Fines_Passengers
	ADD CONSTRAINT PK_Passenger_Type PRIMARY KEY(PassengerID, FineType)
GO

EXEC uspUndoRemovePrimaryKeyPassengerType

-- e. add a candidate key
GO
CREATE OR ALTER PROCEDURE uspAddCandidateKeyPassengerName
AS
	ALTER TABLE Passenger
	ADD CONSTRAINT UQ_Passenger_Name UNIQUE(Name)

GO

EXEC uspAddCandidateKeyPassengerName

--- reverse of adding a candidate key

GO
CREATE OR ALTER PROCEDURE uspUndoAddCandidateKeyPassengerName
AS
	ALTER TABLE Passenger
	DROP CONSTRAINT UQ_Passenger_Name

GO

EXEC uspUndoAddCandidateKeyPassengerName


-- f. remove a foreign key;
GO
CREATE OR ALTER PROCEDURE uspRemoveForeignKeyFineType
AS 
	ALTER TABLE Fines_Passengers
	DROP CONSTRAINT FK_FineType_in_Fines_Passengers
GO

EXEC uspRemoveForeignKeyFineType

--- reverse of removing the primary key 

GO
CREATE OR ALTER PROCEDURE uspUndoRemoveForeignKeyFineType
AS 
	ALTER TABLE Fines_Passengers
	ADD CONSTRAINT FK_FineType_in_Fines_Passengers FOREIGN KEY (FineType) REFERENCES Fine(Type)
GO

EXEC uspUndoRemoveForeignKeyFineType


-- g. create table.

GO
CREATE OR ALTER PROCEDURE uspCreateTableFinesPassengers
AS
	CREATE TABLE Fines_Passengers(
	PassengerID INT,
	CONSTRAINT FK_PassengerID_in_Fines_Passengers FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),

	FineType VARCHAR(100),
	CONSTRAINT FK_FineType_in_Fines_Passengers FOREIGN KEY (FineType) REFERENCES Fine(Type),

	CONSTRAINT PK_Passenger_Type PRIMARY KEY(PassengerID, FineType),
	ReceivedDate VARCHAR(50),
	PaidDate VARCHAR(50)
	);
GO

EXEC uspCreateTableFinesPassengers


--- reverse of creating a table

GO
CREATE OR ALTER PROCEDURE uspUndoCreateTableFinesPassengers
AS
	DROP TABLE IF EXISTS Fines_Passengers
GO

EXEC uspUndoCreateTableFinesPassengers


DROP TABLE Fine
CREATE TABLE Fine(
	 Type VARCHAR(100),
	 CONSTRAINT PK_FineType PRIMARY KEY(Type),
	 Value INT,
	 halvedValuePeriodDays INT)