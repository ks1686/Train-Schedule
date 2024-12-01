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
    </style>
</head>
<body>

<% 

    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!role.equals("Manager")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    List<Map<String, String>> employees = new ArrayList<>();
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
            employee.put("role", rs.getString("role"));
            employees.add(employee);
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
                        <!-- Edit and Delete buttons -->
                        <form method="POST" action="editEmployee.jsp" style="display: inline;">
                            <input type="hidden" name="username" value="<%= employee.get("username") %>">
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
            <option value="Manager">Manager</option>
            <option value="Representative">Representative</option>
        </select>
        <button type="submit">Add Employee</button>
    </form>
</div>

</body>
</html>