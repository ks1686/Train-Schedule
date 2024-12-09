<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>


<!DOCTYPE html>
<html>
<head>
    <title>Manager Welcome</title>
    <style>
        /* Common styles for header and layout */
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .header {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header .username {
            font-size: 20px;
            font-weight: bold;
        }

        .main-container {
            display: flex;
            flex-direction: column;
            padding: 20px;
        }

        .logout-button {
            padding: 8px 16px;
            background-color: #f44336;
            color: white;
            font-size: 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }

        .logout-button:hover {
            background-color: #d32f2f;
        }

        .employee-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        .employee-table th, .employee-table td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        .employee-table th {
            background-color: #4CAF50;
            color: white;
        }

        .employee-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .employee-table tr:hover {
            background-color: #f1f1f1;
        }

        .employee-form input, .employee-form select {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ddd;
        }

        .employee-form select {
            width: auto;
            padding: 6px 10px;
        }

        .employee-form button {
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
        }

        .employee-form button:hover {
            background-color: #45a049;
        }

        .edit-button, .delete-button {
            padding: 6px 12px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
        }

        .edit-button {
            background-color: #2196F3;
            color: white;
        }

        .edit-button:hover {
            background-color: #1976D2;
        }

        .delete-button {
            background-color: #f44336;
            color: white;
        }

        .delete-button:hover {
            background-color: #d32f2f;
        }
        
        /* Common styles for the form and report section */
        .sales-report-form {
            background-color: #ffffff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            margin-top: 20px;
        }
        
        .sales-report-form label {
            font-weight: bold;
            margin-bottom: 8px;
            display: block;
        }
        
        .sales-report-form select, .sales-report-form button {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ddd;
        }
        
        .sales-report-form button {
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            font-size: 14px;
        }
        
        .sales-report-form button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>

<% 
    String username = (String) session.getAttribute("username");

    if (session == null || username == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!role.equals("Manager")) {
        response.sendRedirect("../403.jsp");
        return;
    }
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    List<Map<String, String>> employees = new ArrayList<>();
    String bestCustomer = "";
    int reservationCount = 0;
    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();
        
        // Get all employees
        String query = "SELECT * FROM Employee";
        ps = conn.prepareStatement(query);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Map<String, String> employee = new HashMap<>();
            employee.put("ssn", rs.getString("ssn"));
            employee.put("firstName", rs.getString("firstName"));
            employee.put("lastName", rs.getString("lastName"));
            employee.put("username", rs.getString("username"));
            employee.put("password", rs.getString("password"));
            employee.put("role", rs.getString("role"));
            employees.add(employee);
        }
        
        // Get the customer with the most reservations
        String queryCustomer = "SELECT c.customerId, c.firstName, c.lastName, COUNT(r.reservationNo) AS reservationCount " +
                               "FROM Customer c " +
                               "JOIN Reservation r ON c.customerId = r.customerId " +
                               "GROUP BY c.customerId, c.firstName, c.lastName " +
                               "ORDER BY reservationCount DESC " +
                               "LIMIT 1;";
        
        ps = conn.prepareStatement(queryCustomer);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            bestCustomer = rs.getString("firstName") + " " + rs.getString("lastName");
            reservationCount = rs.getInt("reservationCount");
        }
        
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<div class="header">
    <div class="username">Hi, <%= username %>!</div>
    <div class="customer-info">Top Customer: <%= bestCustomer %> (Reservations: <%= reservationCount %>)</div>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<div class="main-container">
    <div class="welcome-message">
        <h2>Welcome to the Manager Dashboard</h2>
    </div>
    
    <!-- Employee Management Section -->
    <h3>Manage Employees</h3>
    <table class="employee-table">
        <thead>
            <tr>
                <th>SSN</th>
                <th>First Name</th>
                <th>Last Name</th>
                <th>Username</th>
                <th>Role</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <% for (Map<String, String> employee : employees) { %>
                <tr>
                    <td><%= employee.get("ssn") %></td>
                    <td><%= employee.get("firstName") %></td>
                    <td><%= employee.get("lastName") %></td>
                    <td><%= employee.get("username") %></td>
                    <td><%= employee.get("role") %></td>
                    <td>
                        <% if (!"Manager".equals(employee.get("role"))) { %>
                            <!-- Edit and Delete buttons -->
                            <form method="POST" action="editEmployee.jsp" style="display: inline;">
                                <input type="hidden" name="username" value="<%= employee.get("username") %>">
                                <input type="hidden" name="password" value="<%= employee.get("password") %>">
                                <input type="hidden" name="ssn" value="<%= employee.get("ssn") %>">
                                <input type="hidden" name="firstName" value="<%= employee.get("firstName") %>">
                                <input type="hidden" name="lastName" value="<%= employee.get("lastName") %>">
                                <input type="hidden" name="role" value="<%= employee.get("role") %>">
                                <button type="submit" class="edit-button">Edit</button>
                            </form>
                            <form method="POST" action="deleteEmployee.jsp" style="display: inline;">
                                <input type="hidden" name="username" value="<%= employee.get("username") %>">
                                <button type="submit" class="delete-button">Delete</button>
                            </form>
                        <% } %>
                    </td>
                </tr>
            <% } %>
        </tbody>
    </table>
    
    <!-- Add Employee Form -->
    <h3>Add Employee</h3>
    <form method="POST" action="addEmployee.jsp" class="employee-form">
        <input type="text" name="ssn" placeholder="SSN" required pattern="\d{3}-\d{2}-\d{4}">
        <input type="text" name="firstName" placeholder="First Name" required>
        <input type="text" name="lastName" placeholder="Last Name" required>
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <select name="role" required>
            <option value="Representative">Representative</option>
        </select>
        <button type="submit">Add Employee</button>
    </form>
    
    <!-- Top 5 Transit Lines -->
    <h3>Top 5 Transit Lines</h3>
    <table class="employee-table">
        <thead>
            <tr>
                <th>Transit Line</th>
                <th>Reservations</th>
            </tr>
        </thead>
        <tbody>
            <%
                Connection conn5 = null;
                PreparedStatement ps5 = null;
                ResultSet rs5 = null;
                try {
                    ApplicationDB db = new ApplicationDB();
                    conn5 = db.getConnection();
                    String queryTopLines = "SELECT t.lineName, COUNT(r.reservationNo) AS reservationCount " +
                                           "FROM Reservation r " +
                                           "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                                           "GROUP BY t.lineName " +
                                           "ORDER BY reservationCount DESC " +
                                           "LIMIT 5";
                    ps5 = conn5.prepareStatement(queryTopLines);
                    rs5 = ps5.executeQuery();
    
                    while (rs5.next()) {
                        String lineName = rs5.getString("lineName");
                        int topresCount = rs5.getInt("reservationCount");
                        out.println("<tr><td>" + lineName + "</td><td>" + topresCount + "</td></tr>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs5 != null) rs5.close();
                        if (ps5 != null) ps5.close();
                        if (conn5 != null) conn5.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </tbody>
    </table>
    
    
    <!-- Get Sales Report -->
    <h3>Sales Report</h3>
    <form method="POST" action="getSalesReport.jsp" class="sales-report-form">
        <label for="month">Month:</label>
        <select name="month" id="month" required>
            <% for (int i = 1; i <= 12; i++) { %>
                <option value="<%= i %>"><%= new java.text.DateFormatSymbols().getMonths()[i - 1] %></option>
            <% } %>
        </select>
        <label for="year">Year:</label>
        <select name="year" id="year" required>
            <%
                int currentYear = java.util.Calendar.getInstance().get(java.util.Calendar.YEAR);
                for (int i = currentYear; i >= currentYear - 10; i--) {
            %>
                <option value="<%= i %>"><%= i %></option>
            <% } %>
        </select>
        <button type="submit">Get Sales Report</button>
    </form>
    
    <!-- Generate Reservations Report -->
    <h3>Reservations Report</h3>
    <form method="POST" action="getReservations.jsp" class="sales-report-form">
        <label for="transitLine">Select Transit Line:</label>
        <select name="transitLine" id="transitLine">
            <option value="">Select Line</option>
            <%
                Connection conn1 = null;
                PreparedStatement ps1 = null;
                ResultSet rs1 = null;
                try {
                    ApplicationDB db = new ApplicationDB();
                    conn1 = db.getConnection();
                    String queryLine = "SELECT DISTINCT lineName FROM TransitLine";
                    ps1 = conn1.prepareStatement(queryLine);
                    rs1 = ps1.executeQuery();
                    
                    while (rs1.next()) {
                        String lineName = rs1.getString("lineName");
                        out.println("<option value='" + lineName + "'>" + lineName + "</option>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs1 != null) rs1.close();
                        if (ps1 != null) ps1.close();
                        if (conn1 != null) conn1.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </select>
    
        <label for="customerName">Select Customer:</label>
        <select name="customerName" id="customerName">
            <option value="">Select Customer</option>
            <%
                Connection conn2 = null;
                PreparedStatement ps2 = null;
                ResultSet rs2 = null;
                try {
                    ApplicationDB db = new ApplicationDB();
                    conn2 = db.getConnection();
                    String queryCustomer = "SELECT DISTINCT firstName, lastName FROM Customer";
                    ps2 = conn2.prepareStatement(queryCustomer);
                    rs2 = ps2.executeQuery();
                    
                    while (rs2.next()) {
                        String customerName = rs2.getString("firstName") + " " + rs2.getString("lastName");
                        out.println("<option value='" + customerName + "'>" + customerName + "</option>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs2 != null) rs2.close();
                        if (ps2 != null) ps2.close();
                        if (conn2 != null) conn2.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </select>
        <button type="submit">Generate Report</button>
    </form>
    
    <!-- Generate Revenue Report -->
    <h3>Revenue Report</h3>
    <form method="POST" action="getRevenue.jsp" class="sales-report-form">
        <label for="transitLine">Select Transit Line:</label>
        <select name="transitLine" id="transitLine">
            <option value="">Select Line</option>
            <%
                Connection conn3 = null;
                PreparedStatement ps3 = null;
                ResultSet rs3 = null;
                try {
                    ApplicationDB db = new ApplicationDB();
                    conn3 = db.getConnection();
                    String queryLine = "SELECT DISTINCT lineName FROM TransitLine";
                    ps3 = conn3.prepareStatement(queryLine);
                    rs3 = ps3.executeQuery();
    
                    while (rs3.next()) {
                        String lineName = rs3.getString("lineName");
                        out.println("<option value='" + lineName + "'>" + lineName + "</option>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs1 != null) rs3.close();
                        if (ps1 != null) ps3.close();
                        if (conn1 != null) conn3.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </select>
    
        <label for="customerName">Select Customer:</label>
        <select name="customerName" id="customerName">
            <option value="">Select Customer</option>
            <%
                Connection conn4 = null;
                PreparedStatement ps4 = null;
                ResultSet rs4 = null;
                try {
                    ApplicationDB db = new ApplicationDB();
                    conn4 = db.getConnection();
                    String queryCustomer = "SELECT DISTINCT firstName, lastName FROM Customer";
                    ps4 = conn4.prepareStatement(queryCustomer);
                    rs4 = ps4.executeQuery();
    
                    while (rs4.next()) {
                        String customerName = rs4.getString("firstName") + " " + rs4.getString("lastName");
                        out.println("<option value='" + customerName + "'>" + customerName + "</option>");
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs4 != null) rs4.close();
                        if (ps4 != null) ps4.close();
                        if (conn4 != null) conn4.close();
                    } catch (SQLException e) {
                        e.printStackTrace();
                    }
                }
            %>
        </select>
        <button type="submit">Generate Revenue Report</button>
    </form>
</div>
</body>
</html>