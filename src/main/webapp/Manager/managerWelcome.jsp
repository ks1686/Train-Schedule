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
    <link rel="stylesheet" href="../css/app.css">
</head>
<body>

<% 
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }
    String username = Auth.username(session);
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    List<Map<String, String>> employees = new ArrayList<>();
    List<Map<String, String>> topLines = new ArrayList<>();
    List<String> lineNames = new ArrayList<>();
    List<String> customerNames = new ArrayList<>();
    String bestCustomer = "";
    int reservationCount = 0;
    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        ps = conn.prepareStatement("SELECT ssn, firstName, lastName, username, role FROM Employee");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> employee = new HashMap<>();
            employee.put("ssn", rs.getString("ssn"));
            employee.put("firstName", rs.getString("firstName"));
            employee.put("lastName", rs.getString("lastName"));
            employee.put("username", rs.getString("username"));
            employee.put("role", rs.getString("role"));
            employees.add(employee);
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        String queryCustomer = "SELECT c.customerId, c.firstName, c.lastName, COUNT(r.reservationNo) AS reservationCount " +
                               "FROM Customer c " +
                               "JOIN Reservation r ON c.customerId = r.customerId " +
                               "GROUP BY c.customerId, c.firstName, c.lastName " +
                               "ORDER BY reservationCount DESC " +
                               "LIMIT 1";
        ps = conn.prepareStatement(queryCustomer);
        rs = ps.executeQuery();
        if (rs.next()) {
            bestCustomer = rs.getString("firstName") + " " + rs.getString("lastName");
            reservationCount = rs.getInt("reservationCount");
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        String queryTopLines = "SELECT t.lineName, COUNT(r.reservationNo) AS reservationCount " +
                               "FROM Reservation r " +
                               "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                               "GROUP BY t.lineName " +
                               "ORDER BY reservationCount DESC " +
                               "LIMIT 5";
        ps = conn.prepareStatement(queryTopLines);
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> line = new HashMap<>();
            line.put("lineName", rs.getString("lineName"));
            line.put("reservationCount", String.valueOf(rs.getInt("reservationCount")));
            topLines.add(line);
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        ps = conn.prepareStatement("SELECT DISTINCT lineName FROM TransitLine ORDER BY lineName");
        rs = ps.executeQuery();
        while (rs.next()) {
            lineNames.add(rs.getString("lineName"));
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        ps = conn.prepareStatement("SELECT DISTINCT firstName, lastName FROM Customer ORDER BY lastName, firstName");
        rs = ps.executeQuery();
        while (rs.next()) {
            customerNames.add(rs.getString("firstName") + " " + rs.getString("lastName"));
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
    <div class="username">Hi, <%= Html.escape(username) %>!</div>
    <div class="customer-info">Top Customer: <%= Html.escape(bestCustomer) %> (Reservations: <%= reservationCount %>)</div>
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
                    <td><%= Html.escape(employee.get("ssn")) %></td>
                    <td><%= Html.escape(employee.get("firstName")) %></td>
                    <td><%= Html.escape(employee.get("lastName")) %></td>
                    <td><%= Html.escape(employee.get("username")) %></td>
                    <td><%= Html.escape(employee.get("role")) %></td>
                    <td>
                        <% if (!Roles.MANAGER.equals(employee.get("role"))) { %>
                            <form method="POST" action="editEmployee.jsp" style="display: inline;">
                                <%= Csrf.hiddenField(session) %>
                                <input type="hidden" name="ssn" value="<%= Html.escape(employee.get("ssn")) %>">
                                <button type="submit" class="edit-button">Edit</button>
                            </form>
                            <form method="POST" action="deleteEmployee.jsp" style="display: inline;">
                                <%= Csrf.hiddenField(session) %>
                                <input type="hidden" name="username" value="<%= Html.escape(employee.get("username")) %>">
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
        <%= Csrf.hiddenField(session) %>
        <input type="text" name="ssn" placeholder="SSN" required pattern="\d{3}-\d{2}-\d{4}">
        <input type="text" name="firstName" placeholder="First Name" required>
        <input type="text" name="lastName" placeholder="Last Name" required>
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <input type="hidden" name="role" value="<%= Html.escape(Roles.REPRESENTATIVE) %>">
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
            <% for (Map<String, String> line : topLines) { %>
                <tr>
                    <td><%= Html.escape(line.get("lineName")) %></td>
                    <td><%= Html.escape(line.get("reservationCount")) %></td>
                </tr>
            <% } %>
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
            <% for (String lineName : lineNames) { %>
                <option value="<%= Html.escape(lineName) %>"><%= Html.escape(lineName) %></option>
            <% } %>
        </select>
    
        <label for="customerName">Select Customer:</label>
        <select name="customerName" id="customerName">
            <option value="">Select Customer</option>
            <% for (String customerName : customerNames) { %>
                <option value="<%= Html.escape(customerName) %>"><%= Html.escape(customerName) %></option>
            <% } %>
        </select>
        <button type="submit">Generate Report</button>
    </form>
    
    <!-- Generate Revenue Report -->
    <h3>Revenue Report</h3>
    <form method="POST" action="getRevenue.jsp" class="sales-report-form">
        <label for="transitLine">Select Transit Line:</label>
        <select name="transitLine" id="revenueTransitLine">
            <option value="">Select Line</option>
            <% for (String lineName : lineNames) { %>
                <option value="<%= Html.escape(lineName) %>"><%= Html.escape(lineName) %></option>
            <% } %>
        </select>
    
        <label for="revenueCustomerName">Select Customer:</label>
        <select name="customerName" id="revenueCustomerName">
            <option value="">Select Customer</option>
            <% for (String customerName : customerNames) { %>
                <option value="<%= Html.escape(customerName) %>"><%= Html.escape(customerName) %></option>
            <% } %>
        </select>
        <button type="submit">Generate Revenue Report</button>
    </form>
</div>
</body>
</html>