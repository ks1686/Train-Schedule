<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Edit Employee</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }

        .header {
            background-color: #333;
            color: #fff;
            padding: 15px 20px;
            text-align: center;
            font-size: 24px;
        }

        .main-container {
            width: 100%;
            max-width: 500px;
            margin: 20px auto;
            padding: 15px;
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        }

        h2 {
            text-align: center;
            margin-bottom: 20px;
            color: #333;
        }

        .edit-form input,
        .edit-form select {
            display: block;
            margin-bottom: 15px;
            padding: 10px;
            width: 90%;
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
            font-size: 16px;
        }

        .edit-form button:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>

<%
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if the user is a manager
    if (!session.getAttribute("role").equals("Manager")) {
        response.sendRedirect("../403.jsp");
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

<div class="header">Edit Employee Details</div>

<div class="main-container">
    <form method="POST" action="updateEmployee.jsp" class="edit-form">
        <input type="hidden" name="ssn" value="<%= ssn %>">

        <label for="firstName">First Name:</label>
        <input type="text" name="firstName" value="<%= firstName %>" required>

        <label for="lastName">Last Name:</label>
        <input type="text" name="lastName" value="<%= lastName %>" required>

        <label for="username">Username:</label>
        <input type="text" name="username" value="<%= username %>" required>

        <label for="password">Password:</label>
        <input type="text" name="password" value="<%= password %>" required>

        <label for="role">Role:</label>
        <select name="role" required>
            <option value="Representative" <%= role.equals("Representative") ? "selected" : "" %>>Representative</option>
        </select>

        <button type="submit">Update Employee</button>
    </form>
</div>

</body>
</html>
