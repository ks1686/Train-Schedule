<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%

    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!role.equals("Representative")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String lineId = request.getParameter("lineId");

    // Check if lineId is valid
    if (lineId != null && !lineId.isEmpty()) {
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            ApplicationDB appdb = new ApplicationDB();
            conn = appdb.getConnection();

            String deleteQuery = "DELETE FROM TransitLine WHERE lineId = ?";

            ps = conn.prepareStatement(deleteQuery);
            ps.setInt(1, Integer.parseInt(lineId));

            int result = ps.executeUpdate();
            if (result > 0) {
                // redirect back to repWelcome.jsp
                response.sendRedirect("repWelcome.jsp");
            } else {
                out.print("failure");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            out.print("error");
        } finally {
            try {
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.print("invalid lineId");
    }
%>