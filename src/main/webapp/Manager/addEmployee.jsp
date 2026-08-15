<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        response.sendRedirect("managerWelcome.jsp?add=error");
        return;
    }

    String ssn = request.getParameter("ssn");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String usernameInput = request.getParameter("username");
    String password = request.getParameter("password");

    if (ssn != null) ssn = ssn.trim();
    if (firstName != null) firstName = firstName.trim();
    if (lastName != null) lastName = lastName.trim();
    if (usernameInput != null) usernameInput = usernameInput.trim();
    if (password != null) password = password.trim();

    if (ssn == null || ssn.isEmpty()
            || firstName == null || firstName.isEmpty()
            || lastName == null || lastName.isEmpty()
            || usernameInput == null || usernameInput.isEmpty()
            || password == null || password.isEmpty()) {
        response.sendRedirect("managerWelcome.jsp?add=failure");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        String query = "INSERT INTO Employee (ssn, firstName, lastName, username, password, role) VALUES (?, ?, ?, ?, ?, ?)";
        ps = conn.prepareStatement(query);
        ps.setString(1, ssn);
        ps.setString(2, firstName);
        ps.setString(3, lastName);
        ps.setString(4, usernameInput);
        ps.setString(5, Passwords.hash(password));
        ps.setString(6, Roles.REPRESENTATIVE);

        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("managerWelcome.jsp?add=success");
        } else {
            response.sendRedirect("managerWelcome.jsp?add=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("managerWelcome.jsp?add=error");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
