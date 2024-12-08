<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="com.cs336.pkg.*"%>

<%
	String username = (String) session.getAttribute("username");

    if (session == null || username == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    // Check if the user is a Customer   
    if (!session.getAttribute("role").equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    int reservationNo = Integer.valueOf(request.getParameter("cancel"));
    
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        String reservationCancellation = "DELETE FROM Reservation WHERE reservationNo = ?";
        
        ps = conn.prepareStatement(reservationCancellation);
       	ps.setInt(1, reservationNo);

        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            response.sendRedirect("customerWelcome.jsp?cancellation=success");
        } else {
            response.sendRedirect("customerWelcome.jsp?cancellation=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("customerWelcome.jsp?cancellation=error");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
