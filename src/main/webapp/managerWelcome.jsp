<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Manager Welcome</title>
    <style>
        /* Existing CSS styles here */
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

        .employee-form input {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ddd;
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
    </style>
</head>
<body>

<% 
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
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
    <div class="username">Hello, <%= username %>!</div>
    <a href="logout.jsp" class="logout-button">Logout</a>
</div>

<div class="main-container">
    <div class="welcome-message">
        <h2> Welcome to the Manager Dashboard </h2>
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
                            <button type="submit">Edit</button>
                        </form>
                        <form method="POST" action="deleteEmployee.jsp" style="display: inline;">
                            <input type="hidden" name="username" value="<%= employee.get("username") %>">
                            <button type="submit" style="background-color: #f44336;">Delete</button>
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
