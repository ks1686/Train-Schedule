<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*,java.time.LocalDateTime"%>

<%
    if (!Auth.requireRole(request, response, Roles.REPRESENTATIVE)) {
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        out.print("Invalid request.");
        return;
    }

    String lineIdParam = request.getParameter("lineId");
    String departure = request.getParameter("departure");
    String arrival = request.getParameter("arrival");
    String lineName = request.getParameter("lineName");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String fare = request.getParameter("fare");

    if (lineIdParam == null || lineName == null || origin == null || destination == null
            || departure == null || arrival == null || fare == null
            || lineName.trim().isEmpty() || origin.trim().isEmpty() || destination.trim().isEmpty()
            || departure.trim().isEmpty() || arrival.trim().isEmpty() || fare.trim().isEmpty()) {
        out.print("Error: All schedule fields are required.");
        return;
    }

    int lineId;
    float fareValue;
    LocalDateTime departureDateTime;
    LocalDateTime arrivalDateTime;
    try {
        lineId = Integer.parseInt(lineIdParam.trim());
        fareValue = Float.parseFloat(fare.trim());
        departureDateTime = DateTimeConversion.strToDateTime(departure);
        arrivalDateTime = DateTimeConversion.strToDateTime(arrival);
    } catch (RuntimeException e) {
        out.print("Error: Invalid schedule values.");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();
        StationDao stations = new StationDao();

        Integer originStationId = stations.findIdByName(conn, origin.trim());
        if (originStationId == null) {
            out.print("Error: Origin station not found.");
            return;
        }
        Integer destinationStationId = stations.findIdByName(conn, destination.trim());
        if (destinationStationId == null) {
            out.print("Error: Destination station not found.");
            return;
        }

        conn.setAutoCommit(false);

        ps = conn.prepareStatement(
                "UPDATE TransitLine SET lineName = ?, origin = ?, destination = ?, departureDateTime = ?, arrivalDateTime = ?, fare = ? WHERE lineId = ?");
        ps.setString(1, lineName.trim());
        ps.setInt(2, originStationId);
        ps.setInt(3, destinationStationId);
        ps.setTimestamp(4, DateTimeConversion.toTimestamp(departureDateTime));
        ps.setTimestamp(5, DateTimeConversion.toTimestamp(arrivalDateTime));
        ps.setFloat(6, fareValue);
        ps.setInt(7, lineId);
        ps.executeUpdate();
        ps.close();
        ps = null;

        ps = conn.prepareStatement(
                "UPDATE Stop SET departureDateTime = ? WHERE stopLine = ? AND stopStation = ?");
        ps.setTimestamp(1, DateTimeConversion.toTimestamp(departureDateTime));
        ps.setInt(2, lineId);
        ps.setInt(3, originStationId);
        ps.executeUpdate();
        ps.close();
        ps = null;

        ps = conn.prepareStatement(
                "UPDATE Stop SET arrivalDateTime = ? WHERE stopLine = ? AND stopStation = ?");
        ps.setTimestamp(1, DateTimeConversion.toTimestamp(arrivalDateTime));
        ps.setInt(2, lineId);
        ps.setInt(3, destinationStationId);
        ps.executeUpdate();
        ps.close();
        ps = null;

        conn.commit();
        response.sendRedirect("repWelcome.jsp");
    } catch (SQLException e) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignored) {
                // ignore rollback errors
            }
        }
        out.print("Error updating schedule.");
    } finally {
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException ignored) {
                // ignore close errors
            }
        }
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
            } catch (SQLException ignored) {
                // ignore reset errors
            }
        }
        new ApplicationDB().closeConnection(conn);
    }
%>
