<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        response.sendRedirect("managerWelcome.jsp?update=error");
        return;
    }

    String username = request.getParameter("username");
    String ssn = request.getParameter("ssn");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");

    if (username != null) username = username.trim();
    if (ssn != null) ssn = ssn.trim();
    if (firstName != null) firstName = firstName.trim();
    if (lastName != null) lastName = lastName.trim();
    if (password != null) password = password.trim();

    if (ssn == null || ssn.isEmpty()
            || username == null || username.isEmpty()
            || firstName == null || firstName.isEmpty()
            || lastName == null || lastName.isEmpty()) {
        response.sendRedirect("managerWelcome.jsp?update=failure");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        ps = conn.prepareStatement("SELECT role FROM Employee WHERE ssn = ?");
        ps.setString(1, ssn);
        rs = ps.executeQuery();
        if (!rs.next() || Roles.MANAGER.equals(rs.getString("role"))) {
            response.sendRedirect("managerWelcome.jsp?update=failure");
            return;
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        if (password == null || password.isEmpty()) {
            ps = conn.prepareStatement(
                    "UPDATE Employee SET firstName = ?, lastName = ?, username = ?, role = ? WHERE ssn = ?");
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, username);
            ps.setString(4, Roles.REPRESENTATIVE);
            ps.setString(5, ssn);
        } else {
            ps = conn.prepareStatement(
                    "UPDATE Employee SET firstName = ?, lastName = ?, username = ?, password = ?, role = ? WHERE ssn = ?");
            ps.setString(1, firstName);
            ps.setString(2, lastName);
            ps.setString(3, username);
            ps.setString(4, Passwords.hash(password));
            ps.setString(5, Roles.REPRESENTATIVE);
            ps.setString(6, ssn);
        }

        int rowsUpdated = ps.executeUpdate();
        if (rowsUpdated > 0) {
            response.sendRedirect("managerWelcome.jsp?update=success");
        } else {
            response.sendRedirect("managerWelcome.jsp?update=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("managerWelcome.jsp?update=error");
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
