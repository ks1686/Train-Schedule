<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>

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

    String username = request.getParameter("username");
    if (username != null) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();

            String query = "DELETE FROM Employee WHERE username = ?";
            ps = conn.prepareStatement(query);
            ps.setString(1, username);

            int rowsAffected = ps.executeUpdate();
            if (rowsAffected > 0) {
                // Redirect to managerWelcome.jsp after deletion
                response.sendRedirect("managerWelcome.jsp");
            } else {
                // Redirect to managerWelcome.jsp with a failure message (use query parameters if needed)
                response.sendRedirect("managerWelcome.jsp?message=Failed to delete employee");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            // Redirect to managerWelcome.jsp with an error message (use query parameters if needed)
            response.sendRedirect("managerWelcome.jsp?message=Error occurred while deleting employee");
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        // If the username is not provided, redirect back with an error message
        response.sendRedirect("managerWelcome.jsp?message=Invalid employee to delete");
    }
%>
