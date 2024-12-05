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

    String lineIdString = request.getParameter("lineId");
    int lineId = Integer.parseInt(lineIdString);
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");

    // Check if lineId is valid
    if (lineIdString != null && origin != null && destination != null &&
        !lineIdString.isEmpty() && !origin.isEmpty() && !destination.isEmpty()) {

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB appdb = new ApplicationDB();
            conn = appdb.getConnection();

            String sql = "SELECT st.stationId, st.name, st.city, st.state, sp.departureDateTime, sp.arrivalDateTime " +
                         "FROM Stop sp " +
                         "JOIN Station st ON sp.stopStation = st.stationId " +
                         "WHERE sp.stopLine = ? " +
                         "AND st.stationId IN ( " +
                         "    SELECT origin FROM TransitLine WHERE lineId = ? " +
                         "    UNION " +
                         "    SELECT destination FROM TransitLine WHERE lineId = ? " +
                         "    UNION " +
                         "    SELECT stopStation FROM Stop WHERE stopLine = ? " +
                         "      AND stopStation BETWEEN " +
                         "          (SELECT origin FROM TransitLine WHERE lineId = ?) " +
                         "          AND " +
                         "          (SELECT destination FROM TransitLine WHERE lineId = ?) " +
                         ") " +
                         "ORDER BY sp.departureDateTime";
    
            ps = conn.prepareStatement(sql);
            ps.setInt(1, lineId);
            ps.setInt(2, lineId);
            ps.setInt(3, lineId);
            ps.setInt(4, lineId);
            ps.setInt(5, lineId);
            ps.setInt(6, lineId);
            rs = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Stops</title>
    <link rel="stylesheet" type="text/css" href="../styles.css">
</head>
<body>
    <h2>Stops between <%= origin %> and <%= destination %> on Line: <%= lineId %></h2>
    <table border="1">
        <thead>
            <tr>
                <th>Station ID</th>
                <th>Name</th>
                <th>City</th>
                <th>State</th>
                <th>Departure Time</th>
                <th>Arrival Time</th>
            </tr>
        </thead>
        <tbody>
        <%
            while (rs.next()) {
        %>
            <tr>
                <td><%= rs.getInt("stationId") %></td>
                <td><%= rs.getString("name") %></td>
                <td><%= rs.getString("city") %></td>
                <td><%= rs.getString("state") %></td>
                <td><%= rs.getTimestamp("departureDateTime") %></td>
                <td><%= rs.getTimestamp("arrivalDateTime") %></td>
            </tr>
        <%
            }
        %>
        </tbody>
    </table>
</body>
</html>
<%
        } catch (SQLException e) {
            e.printStackTrace();
            out.print("An error occurred while retrieving the stops.");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    } else {
        out.print("Invalid input. Please provide Line ID, Origin, and Destination.");
    }
%>
