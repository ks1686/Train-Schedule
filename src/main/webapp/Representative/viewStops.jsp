<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.REPRESENTATIVE)) {
        return;
    }

    String lineIdString = request.getParameter("lineId");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");

    if (lineIdString == null || lineIdString.trim().isEmpty()) {
        out.print("Invalid input. Please provide Line ID.");
        return;
    }

    int lineId;
    try {
        lineId = Integer.parseInt(lineIdString.trim());
    } catch (NumberFormatException e) {
        out.print("Invalid input. Please provide Line ID.");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String sql = "SELECT st.stationId, st.name, st.city, st.state, sp.departureDateTime, sp.arrivalDateTime "
                + "FROM Stop sp "
                + "JOIN Station st ON sp.stopStation = st.stationId "
                + "WHERE sp.stopLine = ? "
                + "ORDER BY sp.departureDateTime";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, lineId);
        rs = ps.executeQuery();
%>
<!DOCTYPE html>
<html>
<head>
    <title>View Stops</title>
    <link rel="stylesheet" href="../css/app.css">
</head>
<body>
    <h2>Stops between <%= Html.escape(origin) %> and <%= Html.escape(destination) %> on Line: <%= lineId %></h2>
    <table>
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
                <td><%= Html.escape(rs.getString("name")) %></td>
                <td><%= Html.escape(rs.getString("city")) %></td>
                <td><%= Html.escape(rs.getString("state")) %></td>
                <td><%= Html.escape(rs.getString("departureDateTime")) %></td>
                <td><%= Html.escape(rs.getString("arrivalDateTime")) %></td>
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
        out.print("An error occurred while retrieving the stops.");
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            // ignore close errors
        }
        new ApplicationDB().closeConnection(conn);
    }
%>
