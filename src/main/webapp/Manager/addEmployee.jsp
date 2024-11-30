<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Add Employee</title>
    <style>
        .employee-form input, .employee-form select {
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
        response.sendRedirect("../login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        if (request.getMethod().equalsIgnoreCase("POST")) {
            String ssn = request.getParameter("ssn").trim();
            String firstName = request.getParameter("firstName").trim();
            String lastName = request.getParameter("lastName").trim();
            String usernameInput = request.getParameter("username").trim();
            String password = request.getParameter("password").trim();
            String role = request.getParameter("role").trim();

            // Validate role
            if (!role.equalsIgnoreCase("Manager") && !role.equalsIgnoreCase("Representative")) {
                out.println("<p style='color: red;'>Invalid role. Please select either 'Manager' or 'Representative'.</p>");
            } else {
                // Insert the new employee into the database
                String query = "INSERT INTO Employee (ssn, firstName, lastName, username, password, role) VALUES (?, ?, ?, ?, ?, ?)";
                ps = conn.prepareStatement(query);
                ps.setString(1, ssn);
                ps.setString(2, firstName);
                ps.setString(3, lastName);
                ps.setString(4, usernameInput);
                ps.setString(5, password);
                ps.setString(6, role);

                int rowsAffected = ps.executeUpdate();
                if (rowsAffected > 0) {
                    // Redirect to managerWelcome.jsp after successful insertion
                    response.sendRedirect("managerWelcome.jsp");
                    return; // Exit to ensure the rest of the code doesn't execute
                } else {
                    out.println("<p style='color: red;'>Failed to add employee. Please try again.</p>");
                }
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<p style='color: red;'>An error occurred: " + e.getMessage() + "</p>");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
</body>
</html>
