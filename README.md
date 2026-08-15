# Train Reservation System

## Overview

This project is a Train Reservation System that allows customers to make reservations for train journeys, employees to manage customer queries, and managers to oversee operations. The system is built using Java and SQL.

[![Transit Application Demo](assets/transit-demo.gif "https://drive.google.com/file/d/1MTzI_Nyt1bbQcP5qQSDr59PSUrJYX6i4/view?usp=drive_link")](https://drive.google.com/file/d/1MTzI_Nyt1bbQcP5qQSDr59PSUrJYX6i4/view?usp=drive_link)

### Entity Relation Diagram (ERD)
<p align="center">
    <picture>
      <source media="(prefers-color-scheme: light)" srcset="assets/er_diagram-v3_light.png">
      <source media="(prefers-color-scheme: dark)" srcset="assets/er_diagram-v3_dark.png">
      <img alt="Entity Relation Diagram (ERD)" src="assets/er_diagram-v3_dark.png">
    </picture>
</p>

**Note**: While "Questions" and "Answers" could be combined into one entity because of their current one-to-one relationship, we've kept them separate to match our existing codebase. This separation makes the system easier to maintain and also allows for future flexibility, like adding multiple answers or replies to a single question (provided the cardinality constraint for "Questions" to "Reply" is updated). However, if a future refactor is considered, merging them could simplify the design by removing the "Reply" relationship and directly combining the entities.

## Functionality

All functionality from the checklist has been implemented.

#### I. **Account functionality**  
- Register customers  
- Login (for all customers, admin, customer reps)  
- Logout (for all customers, admin, customer reps)  

#### II. **Browsing and search functionality**  
- Search for train schedules by origin, destination, date of travel   
- Browse the resulting schedules   
  - See all the stops a train will make, fare, etc.  
- Sort by different criteria (by arrival time, departure time, fare)   

#### III. **Reservations**  
- A customer should be able to make a reservation for a specific route (round-trip/one way)   
- Get a discount in case of child/senior/disabled   
- Cancel existing reservation   
- View current and past reservations with their details (separately)   

#### IV. **Admin functions**  
- Admin (create an admin account ahead of time)  
  - Add, edit, and delete information for a customer representative   
  - Obtain sales reports per month   
  - Produce a list of reservations:   
    - By transit line  
    - By customer name  
  - Produce a listing of revenue per:   
    - Transit line  
    - Customer name  
- Best customer   
- Best 5 most active transit lines   

#### V. **Customer representative**  
- Edit and delete information for train schedules   
- Customers browse questions and answers   
- Customers search questions by keywords   
- Customers send a question to customer service   
  - Reps reply to customer questions   
- Produce a list of train schedules for a given station (as origin/destination)   
- Produce a list of all customers who have reservations on a given transit line and date   


## File Structure

```
.
├── pom.xml
├── assets/
├── src/main/java/com/cs336/pkg/     # helpers, DAOs, models, AuthFilter
├── src/main/webapp/                 # JSPs, css/app.css, WEB-INF
│   ├── Customer/placeReservation.jsp
│   ├── Manager/
│   └── Representative/
├── src/test/java/com/cs336/pkg/     # JUnit for dates, passwords, fares
└── tests/
    ├── buildMockTransit.py
    └── sql/
        ├── schema.sql               # source of truth
        ├── table_data.sql           # source of truth for mock rows
        ├── migrate_from_v1.sql      # ALTER path for existing trains DBs
        └── Dump20241209.sql         # historical dump; do not regenerate
```

- `assets/mock_transit.png`: Visual representation of NJ Transit lines, used as a reference for generating mock transit data.
  - ![Mock Transit Line Source](assets/mock_transit.png)
- `src/main/java/com/cs336/pkg/ApplicationDB.java`: JDBC factory. Reads `DB_URL`, `DB_USER`, `DB_PASSWORD` from the environment (defaults: `jdbc:mysql://localhost:3306/trains`, `root`, empty password).
- `tests/sql/schema.sql` + `tests/sql/table_data.sql`: source of truth for schema and seed data. `Dump20241209.sql` is a historical snapshot.
- `tests/buildMockTransit.py`: writes `tests/sql/table_data.sql`.
- `Reservation.totalFare` is the **charged** amount (segment fare × round-trip × discount). Reports `SUM(totalFare)` and do not re-apply multipliers.

### Testing Credentials

Seed passwords in `table_data.sql` are plaintext for first login. The app hashes them with jBCrypt on first successful login (legacy upgrade). After that, the stored value starts with `$2`.

- **Manager**: `mgr1` / `mgr1`
- **Employee**: `emp1` / `emp1`
- **Customer**: `aliceg` / `securepass1`

## How to Test

1. **Set Up the Database**:
    - MySQL running locally.
    - Fresh install: `schema.sql` then `table_data.sql`.
    - Existing `trains` DB from the original schema: `tests/sql/migrate_from_v1.sql`.

2. **Configure Database Connection**:
    - Optional env vars: `DB_URL`, `DB_USER`, `DB_PASSWORD`. Defaults still work for local root with an empty password.

3. **Tomcat 9**:
    - Eclipse + Tomcat 9 still works (`.classpath` / `.project`).
    - Or `mvn package` and deploy `target/train-schedule.war`.
    - Connector/J 8 and jBCrypt are in `src/main/webapp/WEB-INF/lib/`.

4. **Unit tests** (no Tomcat): compile `src/test/java` with JUnit 4 against `src/main/java`.

5. **Manual smoke**: login POST as the three roles; a customer cannot cancel another user's reservation; manager cannot add a Manager or delete self; employee passwords never appear in page source.
