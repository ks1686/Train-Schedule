<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!role.equals("Representative")) {
        response.sendRedirect("../403.jsp");
        return;
    }


    // Retrieve the parameters sent via POST
    String lineId = request.getParameter("lineId");
    String departure = request.getParameter("departure");
    String arrival = request.getParameter("arrival");
    String fare = request.getParameter("fare");

    // Connection setup for the database
    Connection conn = null;
    PreparedStatement ps = null;
    
    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();
        
        String updateQuery = "UPDATE TransitLine SET departureDateTime = ?, arrivalDateTime = ?, fare = ? WHERE lineId = ?";
        
        ps = conn.prepareStatement(updateQuery);
        ps.setString(1, departure); 
        ps.setString(2, arrival); 
        ps.setFloat(3, Float.parseFloat(fare)); 
        ps.setInt(4, Integer.parseInt(lineId)); 
        
        int result = ps.executeUpdate();
        if (result > 0) {
            out.print("success");
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
%>