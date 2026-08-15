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
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }

    String ssn = request.getParameter("ssn");
    if (ssn != null) {
        ssn = ssn.trim();
    }
    if (ssn == null || ssn.isEmpty()) {
        response.sendRedirect("managerWelcome.jsp?update=failure");
        return;
    }

    String username = null;
    String firstName = null;
    String lastName = null;

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();
        ps = conn.prepareStatement("SELECT ssn, firstName, lastName, username, role FROM Employee WHERE ssn = ?");
        ps.setString(1, ssn);
        rs = ps.executeQuery();
        if (!rs.next() || Roles.MANAGER.equals(rs.getString("role"))) {
            response.sendRedirect("managerWelcome.jsp?update=failure");
            return;
        }
        username = rs.getString("username");
        firstName = rs.getString("firstName");
        lastName = rs.getString("lastName");
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("managerWelcome.jsp?update=error");
        return;
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

<div class="header">Edit Employee Details</div>

<div class="main-container">
    <form method="POST" action="updateEmployee.jsp" class="edit-form">
        <%= Csrf.hiddenField(session) %>
        <input type="hidden" name="ssn" value="<%= Html.escape(ssn) %>">

        <label for="firstName">First Name:</label>
        <input type="text" name="firstName" id="firstName" value="<%= Html.escape(firstName) %>" required>

        <label for="lastName">Last Name:</label>
        <input type="text" name="lastName" id="lastName" value="<%= Html.escape(lastName) %>" required>

        <label for="username">Username:</label>
        <input type="text" name="username" id="username" value="<%= Html.escape(username) %>" required>

        <label for="password">New password:</label>
        <input type="password" name="password" id="password" placeholder="Leave blank to keep current password" autocomplete="new-password">

        <label for="role">Role:</label>
        <input type="text" id="role" value="<%= Html.escape(Roles.REPRESENTATIVE) %>" disabled>
        <input type="hidden" name="role" value="<%= Html.escape(Roles.REPRESENTATIVE) %>">

        <button type="submit">Update Employee</button>
    </form>
</div>

</body>
</html>
