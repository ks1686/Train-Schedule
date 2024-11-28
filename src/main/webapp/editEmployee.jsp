<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Employee</title>
    <style>
        .edit-form {
            width: 100%;
            max-width: 500px;
            margin: 20px auto;
        }

        .edit-form input,
        .edit-form select {
            display: block;
            margin-bottom: 10px;
            padding: 8px;
            width: 100%;
            border-radius: 4px;
            border: 1px solid #ddd;
        }

        .edit-form button {
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            padding: 10px 20px;
            cursor: pointer;
            width: 100%;
        }

        .edit-form button:hover {
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

    // Retrieve parameters from the request
    String username = request.getParameter("username");
    String ssn = request.getParameter("ssn");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");
    String role = request.getParameter("role");
%>

<div class="main-container">
    <h2>Edit Employee Details</h2>
    <form method="POST" action="updateEmployee.jsp" class="edit-form">
        <input type="hidden" name="username" value="<%= username %>">
        <input type="hidden" name="ssn" value="<%= ssn %>">

        <label for="firstName">First Name:</label>
        <input type="text" name="firstName" value="<%= firstName %>" required>

        <label for="lastName">Last Name:</label>
        <input type="text" name="lastName" value="<%= lastName %>" required>

        <label for="username">Username:</label>
        <input type="text" name="username" value="<%= username %>" required>

        <label for="password">Password:</label>
        <input type="password" name="password" placeholder="Enter new password" required>

        <label for="role">Role:</label>
        <select name="role" required>
            <option value="Manager" <%= role.equals("Manager") ? "selected" : "" %>>Manager</option>
            <option value="Representative" <%= role.equals("Representative") ? "selected" : "" %>>Representative</option>
        </select>

        <button type="submit">Update Employee</button>
    </form>
</div>

</body>
</html>
