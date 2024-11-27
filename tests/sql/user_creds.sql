-- USE THIS TO TEST --

-- CREATE DATABASE trains;

-- USE trains; 

-- Table: Customer
-- CREATE TABLE Customer (
--    customerId INT AUTO_INCREMENT PRIMARY KEY,
--    firstName VARCHAR(25),
--    lastName VARCHAR(25),
--    username VARCHAR(10) UNIQUE,
--    password VARCHAR(50),
--    email VARCHAR(100) UNIQUE
--);

-- Table: Employee
--CREATE TABLE Employee (
--    ssn CHAR(11) PRIMARY KEY,
--    firstName VARCHAR(25) NOT NULL,
--    lastName VARCHAR(25) NOT NULL,
--    username VARCHAR(10) UNIQUE NOT NULL,
--    password VARCHAR(50) NOT NULL,
--    role ENUM('Manager', 'Representative')
--);

-- Table: Emp_Mngr
--CREATE TABLE Emp_Mngr (
--    manager_ssn CHAR(11) NOT NULL,
--    representative_ssn CHAR(11) NOT NULL,
--    PRIMARY KEY (manager_ssn, representative_ssn),
--    FOREIGN KEY (manager_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE,
--    FOREIGN KEY (representative_ssn) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
--);


-- INSERTING DATA PART

--INSERT INTO
--    Customer (firstName, lastName, username, password, email)
--VALUES
--    ('John', 'Doe', 'user1', 'password1', 'john@aol.com'),
--    ('Jane', 'Doe', 'user2', 'password2', 'jane@hotmail.com');

--INSERT INTO 
--	Employee (ssn, firstName, lastName, username, password, role)
--VALUES 
--	('111-11-1111', 'emp1Fname', 'emp1Lname', 'rep1', 'rep1', 'Representative'),
--	('222-22-2222', 'Mgr1Fname', 'Mgr1Lname', 'mgr1', 'mgr1', 'Manager');
);