<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*,java.time.*,java.time.format.DateTimeFormatter"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.CUSTOMER)) {
        return;
    }
    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        response.sendRedirect("customerWelcome.jsp?cancellation=failure");
        return;
    }

    String username = Auth.username(session);
    String cancelParam = request.getParameter("cancel");
    int reservationNo;
    try {
        reservationNo = Integer.parseInt(cancelParam);
    } catch (Exception e) {
        response.sendRedirect("customerWelcome.jsp?cancellation=failure");
        return;
    }

    ApplicationDB db = new ApplicationDB();
    Connection conn = null;
    try {
        conn = db.getConnection();
        int rowsUpdated = new ReservationDao().deleteOwned(conn, reservationNo, username);
        if (rowsUpdated > 0) {
            response.sendRedirect("customerWelcome.jsp?cancellation=success");
        } else {
            response.sendRedirect("customerWelcome.jsp?cancellation=failure");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        response.sendRedirect("customerWelcome.jsp?cancellation=error");
    } finally {
        db.closeConnection(conn);
    }
%>
