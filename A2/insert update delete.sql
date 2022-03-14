DELETE FROM Driver
INSERT INTO Driver(Name, CNP, Email, Salary, DateOfBirth, WorksSince)
VALUES ('Tom Ericksen', '1204751485621', 'tom.ericksen@gmail.com', 1234, '1957-10-13', '1992-07-01'),
		('Anna Bey', '7451248574512', 'anna.bey@gmail.com', 4217, '1958-02-21', '1986-12-01'),
		('Tim Jackson', '7451248759612', 'tim.jackson@yahoo.ro', 3124, '1978-12-03', '1995-05-01'),
		('Ben Asimov', '654128745118', 'ben.asimov@gmail.com', 2563, '1963-05-14', '1986-04-01'),
		('Mary Jane', '4125412784512',  'mary.jane@yahoo.ro', 2311, '1980-08-19', '2003-07-01');

INSERT INTO RailwayStation(Location, NumberOfLines)
VALUES ('Cluj Napoca', 10),
		('Brasov', 5),
		('Bacau', 10),
		('Onesti', 6),
		('Targu Mures', 10),
		('Pascani', 8),
	    ('Sfantu Gheorghe', 10),
		('Viena', 15),
		('Milano', 9),
		('Sevilla', 12),
		('Arad', 9),
		('Zurich', 18),
		('Bucharest', 20),
		('Graz', 9),
		('Oradea', 8),
		('Timisoara', 12),
		('Iasi', 15),
		('Satu Mare', 11),
		('Constanta', 6),
		('Sighisoara', 5),
		('Budapesta', 25),
		('Salzburg', 25),
		('Medias', 10),
		('Sibiu', 8),
		('Targu Frumos', 5);

INSERT INTO Route(Source, Destination)
VALUES ('Cluj Napoca', 'Viena'),
	   ('Milano', 'Sevilla'),
	   ('Zurich', 'Bucharest'),
	   ('Graz', 'Oradea'),
	   ('Timisoara', 'Iasi'),
	   ('Satu Mare', 'Constanta');

SELECT * from Route

INSERT INTO Train(NumberOfSeats, RouteID, StartTime, EndTime)
VALUES (1004, 2, '07:43', '23:12'),
		(432, 6, '8:35', '17:00'),
		(1320, 1, '10:40', '21:55'),
		(900, 4, '08:00', '18:30'),
		(570, 5, '09:55', '20:30'),
		(542, 3, '07:09', '23:45');


INSERT INTO Passenger(Name, CNP, EmailAddress, DateOfBirth, Status)
VALUES('John Doe', '2314521781369', 'john.doe@gmail.com', '2001-01-03', 'student'),
		('Karen Smith', '1024135612489', 'karen.smith@gmail.com', '1999-09-08', 'student'),
		('Alex Ford', '6541248574316', 'alex.ford@yahoo.ro', '1994-07-25', 'adult'),
		('Tim Crook', '5412896574312', 'tim.crook@yahoo.ro', '1998-09-15', 'adult'),
		('Scarlet Moose', '9574124587456', 'scarlet.moose@gmail.com', '1965-07-30', 'retired');

INSERT INTO Subscription(RouteID, Duration, Price, Currency)
VALUES(1, 366, 100, '€'),
		(1, 183, 55, '€'),
		(1, 31, 25, '€'),
		(5, 7, 80, 'RON'),
		(5, 31, 130, 'RON'),
		(5, 183, 200, 'RON'),
		(5, 366, 350, 'RON'),
		(6, 7, 70, 'RON'),
		(6, 31, 160, 'RON'),
		(6, 183, 230, 'RON'),
		(6, 366, 400, 'RON');

INSERT INTO Subscription(RouteID, Duration, Price, Currency)
VALUES(2, 31, 235, 'RON');

SELECT * FROM Subscription

INSERT INTO Passenger_Subscription(PassengerID, SubscriptionID, StartDate)
VALUES(1, 1, '2021-10-26'),
		(1, 7, '2021-06-12'),
		(3, 6, '2021-12-01');


DELETE FROM Ticket
INSERT INTO Ticket(DepartureTime, ArrivalTime, Source, Destination, Price, TrainID, PassengerID)
VALUES ('2021-11-21 02:43', '2021-11-21 23:12', 'Satu Mare', 'Constanta', 103, 2, 4),
		('2021-10-23 16:00', '2021-10-23 21:30', 'Sighisoara', 'Bacau', 72, 5, 1),
		('2021-10-12 09:10', '2021-10-12 14:50', 'Brasov', 'Iasi', 31, 5, 3),
		('2021-12-25 12:00', '2021-12-26 15:30', 'Zurich', 'Brasov', 450, 6, 1),
	    ('2021-12-01 02:43', '2021-12-01 23:12', 'Satu Mare', 'Constanta', 103, 2, 3),
	    ('2021-12-01 16:00', '2021-12-01 21:30', 'Sighisoara', 'Bacau', 72, 5, 2);

UPDATE Ticket
SET Validated = 3
WHERE TrainID = 2

DELETE FROM Staff
INSERT INTO Staff(JobTitle, Name, CNP, Email, Salary, Location, DateOfBirth, WorksSince)
VALUES('Janitor', 'Mark Drew', '1246325748512', 'mark.drew@gmail.com', 3212, 'Cluj Napoca', '1989-12-23', '2007-08-01'),
		('Manager', 'Jane Smith', '6954238175423', 'jane.smith@yahoo.ro', 6542, 'Zurich', '1976-07-14', '2010-11-01'),
		('Customer assistant', 'Adam Horan', '3462157431597', 'adam.horan@yahoo.ro', 4231, 'Zurich', '1958-11-03', '1999-04-01'),
		('Customer assistant', 'Jane Bake', '4571239854125', 'jane.bake@yahoo.ro', 3652, 'Zurich', '1978-11-03', '1999-04-01'),
		('Manager', 'Alexander Phillips', '9864751263410', 'alexander.phillips@gmail.com', 4568, 'Brasov', '1959-03-06', '1998-09-01'),
		('Customer Assistant', 'Max Peev', '3214517542154', 'max.peev@gmail.com', 5068, 'Viena', '1959-03-06', '1998-09-01'),
		('Janitor', 'Nancy Millan', '4215764215789', 'nancy.millan@gmail.com', 4512, 'Graz', '1989-12-23', '2007-08-01'),
		('Manager', 'Anna Mills', '4512368547854', 'anna.mills@gmail.com', 7541, 'Salzburg', '1989-12-23', '2007-08-01');

INSERT INTO Staff(JobTitle, Name, CNP, Email, Salary, Location, DateOfBirth, WorksSince)
VALUES('Janitor', 'John Doe', '1245124632541', 'john.doe@gmail.com', 2223, 'Cluj Napoca', '1989-12-23', '2007-08-01'),
		('Manager', 'Bella Steve', '7845124632541', 'bella.steve@yahoo.ro', 5421, 'Brasov', '1976-07-14', '2010-11-01');



INSERT INTO Driver_Train (DriverID, TrainID)
VALUES (13, 2),
		(14,4),
		(15,2),
		(16,3),
		(17, 4),
		(13,1),
		(14, 5),
		(15, 6),
		(16, 6);

INSERT INTO TicketValidator(TrainID)
VALUES(1),
	(1),
	(2),
	(2),
	(2),
	(3),
	(4);

INSERT INTO Route_Intermediary_Stations(RouteID, Location, Line, StopNumber)
VALUES(1, 'Budapesta', 2, 1),
		(1, 'Graz', 5, 2),
		(3, 'Viena', 2, 1),
		(3, 'Budapesta', 3, 2),
		(3, 'Timisoara', 4, 3);

-- Insert statement that violates the primary key(RouteID, Location) constraint, because a route cannot have 2 different stops at the same Location 
INSERT INTO Route_Intermediary_Stations(RouteID, Location, Line, StopNumber)
VALUES(1, 'Budapesta', 10, 3);



----- UPDATING DATA ------------

--- After an increase in the national minimum wage, update the salary of all staff and drivers with less than 3000 per month to 3000.
UPDATE Staff
SET Salary = 3000
WHERE Salary < 3000

UPDATE Driver
SET Salary = 3000
WHERE Salary < 3000


----- ADD THE COUNTRY TO EACH RAILWAY STATION
UPDATE RailwayStation
SET Country='Romania'
WHERE Location IN ('Arad', 'Bacau', 'Brasov', 'Bucharest', 'Cluj Napoca', 'Constanta',
					'Iasi', 'Onesti', 'Oradea', 'Pascani', 'Satu Mare', 'Sfantu Gheorghe', 'Sighisoara',
					'Targu Mures', 'Timisoara', 'Targu Frumos', 'Sibiu', 'Medias')

UPDATE RailwayStation
SET Country='Austria'
WHERE Location='Graz' OR Location = 'Viena' OR Location = 'Salzburg'

UPDATE RailwayStation
SET Country='Hungary'
WHERE Location='Budapesta'

UPDATE RailwayStation
SET Country='Italy'
WHERE Location='Milano'

UPDATE RailwayStation
SET Country='Switzerland'
WHERE Location='Zurich'

UPDATE RailwayStation
SET Country='Spain'
WHERE Location='Sevilla'


---- The Romanian Ministry of Transport decided to expand the number of lines of each railway station by 50%, so update the number of lines of each romanian station.
UPDATE RailwayStation
SET NumberOfLines = NumberOfLines * 1.5
WHERE Country='Romania'


--- Add the RON currency to all ticket who have it NULL.
UPDATE Ticket
SET Currency = 'RON'
WHERE Currency IS NULL



------ DELETING DATA 
--- Because by the company's police, the retirement age is 63, delete all the records of drivers and staff who are born before 01.01.1959
DELETE FROM Staff
WHERE Staff.DateOfBirth BETWEEN '01.01.1940' AND '01.01.1959'

DELETE FROM Driver
WHERE Driver.DateOfBirth BETWEEN '01.01.1940' AND '01.01.1959'


---- Because the 1st of december is the Natioanl Day of Romania, no train rides take place, so the tickets on the first of december are cancelled.
DELETE FROM Ticket
WHERE CONVERT(VARCHAR, Ticket.DepartureTime, 21) LIKE '2021-12-01%'


SELECT * FROM Train
SELECT * FROM Driver
SELECT * FROM Driver_Train
SELECT * FROM Ticket
SELECT * FROM TicketValidator
SELECT * FROM Passenger
SELECT * FROM Subscription
SELECT * FROM Passenger_Subscription
SELECT * FROM Route
SELECT * FROM RailwayStation
SELECT * FROM Route_Intermediary_Stations
SELECT * FROM Staff