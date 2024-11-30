<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    String username = request.getParameter("username");
    String ssn = request.getParameter("ssn");
    String firstName = request.getParameter("firstName");
    String lastName = request.getParameter("lastName");
    String password = request.getParameter("password");
    String role = request.getParameter("role");

    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // SQL query to update all fields for an employee
        String updateQuery = "UPDATE Employee SET firstName = ?, lastName = ?, username = ?, password = ?, role = ? WHERE ssn = ?";
        ps = conn.prepareStatement(updateQuery);
        ps.setString(1, firstName);
        ps.setString(2, lastName);
        ps.setString(3, username);
        ps.setString(4, password); // Assuming password is hashed before being stored in the database
        ps.setString(5, role);
        ps.setString(6, ssn);

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
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
