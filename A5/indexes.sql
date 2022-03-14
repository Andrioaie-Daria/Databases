CREATE TABLE tableA
	(aid INT PRIMARY KEY,
	 a2 INT UNIQUE,
	 name VARCHAR(10))

CREATE TABLE tableB
	(bid INT PRIMARY KEY,
	 b2 INT)


CREATE TABLE tableC
	(cid INT PRIMARY KEY,
	 aid INT FOREIGN KEY REFERENCES tableA(aid),
	 bid INT FOREIGN KEY REFERENCES tableB(bid),
	 name VARCHAR(10))

--- first add 10000 random values to each table

DECLARE @count INT
SET @count = 0

DECLARE @fk_a INT 
DECLARE @fk_b INT

WHILE @count < 10000
BEGIN
	INSERT INTO tableA
	VALUES(@count, @count*2+1, CONCAT('A', @count))

	INSERT INTO tableB
	VALUES(@count, RAND()*@count)

	SET @fk_a = (SELECT TOP 1 aid FROM tableA ORDER BY NEWID())
	SET @fk_b = (SELECT TOP 1 bid FROM tableB ORDER BY NEWID())


	INSERT INTO tableC
	VALUES(@count, @fk_a, @fk_b, CONCAT('C', @count))

	SET @count = @count + 1

END

SELECT * FROM tableA
SELECT * FROM tableB
SELECT * FROM tableC


---- a.

-- index seek - retrieves selective rows from the table
-- index scan - a scan touches every row in the table, whether or not it qualifies


--- clustered index scan, estimated subtree cost 0.006    
-- since data pages in a clustered index always include all the columns in the table, a clustered index scan is just like a Table Scan operation i.e. entire index is traversed row by row to return the data set
SELECT * 
FROM tableA
ORDER BY aid DESC

--- clustered index seek, estimated subtree cost 0.003
-- The Clustered Index Seek uses the structure of a clustered index to efficiently find either single rows (singleton seek) or specific subsets of rows (range seek)
SELECT * 
FROM tableA
WHERE aid < 100

--- non-clustered index scan
--- create a new one on column a2, which also includes the column name

CREATE NONCLUSTERED INDEX idx_tableA_a2 ON tableA(a2) INCLUDE (name)
DROP INDEX idx_tableA_a2 ON tableA

--- estimated subtree cost 0.0058
--  because we just need the name, but have no selectivity, the NCI scan will suffice and is narrower
SELECT name
FROM tableA
ORDER BY a2   -- unique column


--- non-clustered index seek, estimated subtree cost 0.0046
SELECT name
FROM tableA
WHERE a2 > 900


--- key lookup
SELECT name, a2
FROM tableA
WHERE a2 = 201


--- b.
--- query on table B with WHERE clause

SELECT * 
FROM tableB
WHERE b2 = 100

--- at this stage, the execution plan does a scan on the clustered index created automatically when defining the primary key of table B
--- estimated subtree cost 0.0059

CREATE NONCLUSTERED INDEX idx_tableB_b2 ON tableB(b2)
DROP INDEX idx_tableB_b2 ON tableB

--- now, the execution of the query uses a seek on the previously created nonclustered index, which is more efficient (the cost is halved)
--- estimated subtree cost 0.003

--- c. Create a view that joins at least 2 tables. 
--- Check whether existing indexes are helpful; if not, reassess existing indexes / examine the cardinality of the tables

GO
CREATE OR ALTER VIEW joinAllTables
AS
	SELECT tableA.aid, tableC.aid AS CA, tableB.bid, tableC.bid AS CB
	FROM tableC
		INNER JOIN tableA ON tableA.aid = tableC.aid
		INNER JOIN tableB ON tableB.bid = tableC.biD 
	WHERE tableB.bid < 100 AND tableA.aid >900
GO

SELECT * FROM joinAllTables
--- estimated cost: 0.17, current indexes are not helpful


CREATE NONCLUSTERED INDEX  idx_tableC_aid_bid
	ON tableC(bid, aid)

DROP INDEX idx_tableC_aid_bid on tableC

--- by creating the index idx_tableC_aid_bid, we perform an non index seek when joining tableC with tableA and tableB, which is more efficient
--- estimated subtree cost 0.12



GO
CREATE OR ALTER VIEW joinAllTables2
AS
	SELECT tableA.aid, tableC.aid AS CA, tableB.bid, tableC.bid AS CB
	FROM tableC
		INNER JOIN tableA ON tableA.aid = tableC.aid
		INNER JOIN tableB ON tableB.bid = tableC.biD 
	WHERE tableB.b2 < 100 AND tableA.a2 >900
GO

SELECT * FROM joinAllTables2    ---- here, existing indexes are helpful

