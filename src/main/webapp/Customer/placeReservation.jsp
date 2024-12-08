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

    String lineId = request.getParameter("reserve");
    LineSchedule sched = (LineSchedule) session.getAttribute("line: " + lineId);

    int originStopId = (int) sched.getStops().get(sched.getOriginIndex())[0];
    int destinationStopId = (int) sched.getStops().get(sched.getDestinationIndex())[0];

    String tripType = request.getParameter("tripType") != null ? request.getParameter("tripType") : "oneway";
    String age = request.getParameter("age") != null ? request.getParameter("age") : "21";
    String disability = request.getParameter("disability") != null ? request.getParameter("disability") : "no";
    
    int discount = 0;
	if (disability.equals("yes")) {
		discount = 50;
	} else if (((int) Integer.valueOf(age)) >= 65) {
		discount = 35;
	} else if (((int) Integer.valueOf(age)) <= 12) {
		discount = 25;
	}
    
    Connection conn = null;
    PreparedStatement ps = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        
        String reservationInsertion = 	"INSERT INTO Reservation (customerId, transitLineId, originStopId, destinationStopId, reservationDateTime, isRoundTrip, discount) " +
        								"VALUES ((SELECT customerId FROM Customer WHERE username = ?), ?, ?, ?, ?, ?, ?)";
        		
        ps = conn.prepareStatement(reservationInsertion);
       	ps.setString(1, username);
       	ps.setInt(2, sched.getLineId());
       	ps.setInt(3, originStopId);
       	ps.setInt(4, destinationStopId);
       	ps.setString(5, LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
       	ps.setBoolean(6, tripType.equals("round") ? true : false); 
       	ps.setInt(7, discount);

        int rowsUpdated = ps.executeUpdate();

        if (rowsUpdated > 0) {
            response.sendRedirect("customerWelcome.jsp?reservation=success");
        } else {
            response.sendRedirect("customerWelcome.jsp?reservation=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("customerWelcome.jsp?reservation=error");
    } finally {
        try {
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
