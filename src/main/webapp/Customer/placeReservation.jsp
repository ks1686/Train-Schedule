<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.CUSTOMER)) {
        return;
    }
    String username = Auth.username(session);

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        response.sendRedirect("customerWelcome.jsp?reservation=failure");
        return;
    }

    String lineId = request.getParameter("reserve");
    String tripType = request.getParameter("tripType");
    String ageParam = request.getParameter("age");
    String disability = request.getParameter("disability");
    if (lineId == null || tripType == null || ageParam == null || disability == null) {
        response.sendRedirect("customerWelcome.jsp?reservation=failure");
        return;
    }

    int age;
    try {
        age = Integer.parseInt(ageParam);
    } catch (NumberFormatException e) {
        response.sendRedirect("customerWelcome.jsp?reservation=failure");
        return;
    }
    int discount = FareCalculator.discountFor(age, "yes".equals(disability));
    boolean roundTrip = "round".equals(tripType);

    Integer originStationId = null;
    Integer destinationStationId = null;
    try {
        String origin = (String) session.getAttribute("originStationId");
        String dest = (String) session.getAttribute("destinationStationId");
        if (origin != null && !origin.isEmpty()) originStationId = Integer.valueOf(origin);
        if (dest != null && !dest.isEmpty()) destinationStationId = Integer.valueOf(dest);
    } catch (NumberFormatException ignored) {
    }

    Connection conn = null;
    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();
        LineSchedule sched = new ScheduleDao().loadLine(conn, Integer.parseInt(lineId), originStationId, destinationStationId);
        int rowsUpdated = new ReservationDao().insert(conn, username, sched, roundTrip, discount);
        if (rowsUpdated > 0) {
            response.sendRedirect("customerWelcome.jsp?reservation=success");
        } else {
            response.sendRedirect("customerWelcome.jsp?reservation=failure");
        }
    } catch (Exception e) {
        e.printStackTrace();
        response.sendRedirect("customerWelcome.jsp?reservation=error");
    } finally {
        if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
    }
%>
