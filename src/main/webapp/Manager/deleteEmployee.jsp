<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        response.sendRedirect("managerWelcome.jsp?message=Invalid+request");
        return;
    }

    String username = request.getParameter("username");
    if (username != null) {
        username = username.trim();
    }
    String self = Auth.username(session);
    if (username == null || username.isEmpty()) {
        response.sendRedirect("managerWelcome.jsp?message=Invalid+employee+to+delete");
        return;
    }
    if (username.equals(self)) {
        response.sendRedirect("managerWelcome.jsp?message=Cannot+delete+yourself");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        ps = conn.prepareStatement("SELECT role FROM Employee WHERE username = ?");
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (!rs.next()) {
            response.sendRedirect("managerWelcome.jsp?message=Invalid+employee+to+delete");
            return;
        }
        if (Roles.MANAGER.equals(rs.getString("role"))) {
            response.sendRedirect("managerWelcome.jsp?message=Cannot+delete+a+manager");
            return;
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        ps = conn.prepareStatement("DELETE FROM Employee WHERE username = ? AND role = ?");
        ps.setString(1, username);
        ps.setString(2, Roles.REPRESENTATIVE);

        int rowsAffected = ps.executeUpdate();
        if (rowsAffected > 0) {
            response.sendRedirect("managerWelcome.jsp");
        } else {
            response.sendRedirect("managerWelcome.jsp?message=Failed+to+delete+employee");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("managerWelcome.jsp?message=Error+occurred+while+deleting+employee");
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
