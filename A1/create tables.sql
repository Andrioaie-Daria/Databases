DROP TABLE RailwayStation;
CREATE TABLE RailwayStation(
	Location VARCHAR(50),
	CONSTRAINT PK_Location PRIMARY KEY(Location),
	Country VARCHAR(50),
	NumberOfLines INT);


DROP TABLE Route;
CREATE TABLE Route(
	RouteID INT IDENTITY,
	CONSTRAINT PK_RouteID PRIMARY KEY(RouteID),
	
	Source VARCHAR(50),
	Destination VARCHAR(50),
	UNIQUE(Destination, Source),
	CHECK(Destination <> Source),

	CONSTRAINT FK_Source_in_Route FOREIGN KEY (Source) REFERENCES RailwayStation(Location) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_Destination_in_Route FOREIGN KEY (Destination) REFERENCES RailwayStation(Location),
);


DROP TABLE Route_Intermediary_Stations;
CREATE TABLE Route_Intermediary_Stations(
	RouteID INT NOT NULL,
	CONSTRAINT FK_RouteID_Route_Intermediary_Stations FOREIGN KEY(RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE ON UPDATE CASCADE,
	
	Location VARCHAR(50),
	CONSTRAINT FK_Location_in_Route_Intermediary_Stations FOREIGN KEY(Location) REFERENCES RailwayStation(Location),
	CONSTRAINT PK_Route_Station PRIMARY KEY(RouteID, Location),

	Line INT,
	StopNumber INT);



DROP TABLE Train;
CREATE TABLE Train (
	TrainID INT IDENTITY(1,1),
	CONSTRAINT PK_TrainID PRIMARY KEY (TrainID),

	RouteID INT,
	CONSTRAINT FK_Route_in_Train FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE SET NULL,

	NumberOfSeats INT,
	StartTime TIME,
	EndTime TIME );


DROP TABLE Staff;
CREATE TABLE Staff(
	StaffID INT IDENTITY(1,1),
	CONSTRAINT PK_StaffID PRIMARY KEY (StaffID),

	JobTitle VARCHAR(50),
	Name VARCHAR(50),
	CNP VARCHAR(50) NOT NULL UNIQUE,
	Email VARCHAR(50),
	Salary INT,
	Location VARCHAR(50)
	CONSTRAINT FK_Location_in_Staff FOREIGN KEY (Location) REFERENCES RailwayStation(Location) ON DELETE SET NULL ON UPDATE CASCADE,
	DateOfBirth DATE);

ALTER TABLE Staff
ADD WorksSince DATE 


DROP TABLE Driver
CREATE TABLE Driver(
	DriverID INT IDENTITY(1,1),
	CONSTRAINT PK_DriverID PRIMARY KEY(DriverID),

	Name VARCHAR(50),
	CNP VARCHAR(50) NOT NULL UNIQUE,
	Email VARCHAR(50),
	Salary INT,
	DateOfBirth Date)

ALTER TABLE Driver
ADD WorksSince DATE 


DROP TABLE Driver_Train
CREATE TABLE Driver_Train(
	DriverID INT,
	CONSTRAINT FK_DriverID_in_Driver_Train FOREIGN KEY (DriverID) REFERENCES Driver(DriverID) ON DELETE CASCADE ON UPDATE CASCADE,
	TrainID INT,
	CONSTRAINT FK_TrainID_in_Driver_Train FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT PK_Driver_Train PRIMARY KEY(DriverId, TrainId));


DROP TABLE Passenger
CREATE TABLE Passenger(
	PassengerID INT IDENTITY(1,1),
	CONSTRAINT PK_Passenger PRIMARY KEY (PassengerID),
	Name VARCHAR(50),
	CNP VARCHAR(50) NOT NULL UNIQUE,
	EmailAddress VARCHAR(50),
	DateOfBirth DATE,
	Status VARCHAR(50),
	CHECK( Status IN('child', 'student', 'adult', 'retired')),
	)


DROP TABLE TicketValidator
CREATE TABLE TicketValidator(
	ValidatorID INT IDENTITY(1,1),
	TrainID INT,
	CONSTRAINT PK_ValidatorID PRIMARY KEY (ValidatorID),
	CONSTRAINT FK_Train_inTicketValidator FOREIGN KEY (TrainID) REFERENCES Train(TrainID))

DROP TABLE Ticket
CREATE TABLE Ticket(
	TicketID INT IDENTITY(1,1),
	DepartureTime DATETIME,
	ArrivalTime DATETIME,
	CHECK(DepartureTime < ArrivalTime),
	Source VARCHAR(50),
	Destination VARCHAR(50),
	CHECK( Source <> Destination),
	Price INT NOT NULL,
	TrainID INT,
	PassengerID INT,
	Currency VARCHAR(10),
	Validated INT NULL,

	CONSTRAINT PK_TicketID PRIMARY KEY (TicketID),
	CONSTRAINT FK_Source_in_Ticket FOREIGN KEY (Source) REFERENCES RailwayStation(Location),
	CONSTRAINT FK_Destination_in_Ticket FOREIGN KEY (Destination) REFERENCES RailwayStation(Location),
	CONSTRAINT FK_TrainID_in_Ticket FOREIGN KEY (TrainID) REFERENCES Train(TrainID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_PassengerID_in_Ticket FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT FK_Validator_in_Ticket FOREIGN KEY (Validated) REFERENCES TicketValidator(ValidatorID) ON UPDATE CASCADE)


DROP TABLE Subscription
CREATE TABLE Subscription(
	SubscriptionID INT IDENTITY(1,1),
	RouteID INT,
	Duration INT NOT NULL,
	CHECK (Duration IN (7, 31, 183 ,366)),
	Price INT,
	Currency VARCHAR(10),

	CONSTRAINT CK_Subscription UNIQUE (RouteID, Duration),
	CONSTRAINT PK_SubscriptionID PRIMARY KEY (SubscriptionID),
	CONSTRAINT FK_RouteID_in_Subscription FOREIGN KEY (RouteID) REFERENCES Route(RouteID) ON DELETE CASCADE ON UPDATE CASCADE)


DROP TABLE Passenger_Subscription
CREATE TABLE Passenger_Subscription(
	PassengerID INT REFERENCES Passenger(PassengerID) ON DELETE CASCADE ON UPDATE CASCADE,
	SubscriptionID INT REFERENCES Subscription(SubscriptionID) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT PK_Passenger_Subscription PRIMARY KEY(PassengerID, SubscriptionID),
	StartDate DATE)
