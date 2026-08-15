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
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            margin: 0;
            padding: 0;
        }

        .header {
            background-color: #333;
            color: #fff;
            padding: 15px 20px;
            text-align: center;
            font-size: 24px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background-color: #fff;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 10px;
            text-align: left;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        tr:nth-child(even) {
            background-color: #f2f2f2;
        }

        tr:hover {
            background-color: #ddd;
        }

        h2 {
            text-align: center;
            margin-top: 20px;
            color: #333;
        }

        .compact-button {
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 12px;
            cursor: pointer;
            border: none;
            background-color: #4CAF50;
            color: white;
            display: inline-block;
            margin: 10px 0;
        }

        .compact-button:hover {
            background-color: #45a049;
        }

        .footer {
            text-align: center;
            margin-top: 20px;
            padding: 10px;
            background-color: #333;
            color: white;
            position: fixed;
            bottom: 0;
            width: 100%;
        }
    </style>
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
