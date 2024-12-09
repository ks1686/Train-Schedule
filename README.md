# Train Reservation System

## Overview

This project is a Train Reservation System that allows customers to make reservations for train journeys, employees to manage customer queries, and managers to oversee operations. The system is built using Java and SQL.

## Functionality

- **Customer Management**: Customers can register, log in, and make reservations for train journeys.
- **Employee Management**: Employees can answer customer queries and manage reservations.
- **Managerial Oversight**: Managers can oversee the operations and manage employees.
- **Train and Transit Management**: The system manages train schedules, stops, and transit lines.

## File Structure

```
.
├── src
│   └── main
│       └── java
│           ├── com
│           │   └── cs336
│           │       └── pkg
│           │           ├── DateTimeConversion.java
│           │           ├── LineSchedule.java
│           │           ├── Reservation.java
│           │           ├── Station.java
│           │           └── ApplicationDB.java
│           └── webapp
│               ├── Customer
│               │   ├── askQuestion.jsp
│               │   ├── cancelReservation.jsp
│               │   ├── confirmReservation.jsp
│               │   ├── customerWelcome.jsp
│               │   ├── placeReservation
│               │   └── viewSchedules.jsp
│               ├── Manager
│               │   ├── addEmployee.jsp
│               │   ├── deleteEmployee.jsp
│               │   ├── editEmployee.jsp
│               │   ├── getReservations.jsp
│               │   ├── getRevenue.jsp
│               │   ├── getSalesReport.jsp
│               │   ├── managerWelcome.jsp
│               │   └── updateEmployee.jsp
│               ├── Representative
│               │   ├── deleteSchedule.jsp
│               │   ├── repWelcome.jsp
│               │   ├── updateSchedule.jsp
│               │   └── viewStops.jsp
│               ├── 403.jsp
│               ├── login.jsp
│               │── logout.jsp
│               └── register.jsp
├── tests
│   └── sql
│       ├── mock_transit.sql
│       ├── table_data.sql
│       └── schema.sql
└── README.md
```

- `src/main/java/com/cs336/pkg/ApplicationDB.java`: Java class for database connection management.
- `tests/sql/mock_transit.sql`: SQL script for inserting mock transit data exclusively
- `tests/sql/table_data.sql`: SQL script for inserting mock data into all tables
- `tests/sql/schema.sql`: SQL script for creating the database schema.

## How to Test

1. **Set Up the Database**:
    - Ensure MySQL is installed and running on your machine.
    - Create the database and tables by running the respective scripts or using the command line.
    - Make sure JDBC is installed and configured on your machine.

2. **Configure Database Connection**:
    - Update the `DB_USER` and `DB_PASSWORD` in `ApplicationDB.java` with your MySQL credentials.

3. **Ensure Tomcat 9 Configuration**:
    - Ensure Tomcat 9 is installed and configured on your machine.
    - Follow the sample project in the course files.

3. **Compile and Run the Application**.

By following these steps, you can set up, configure, and test the Train Reservation System.