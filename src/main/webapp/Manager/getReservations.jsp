<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
<%@ page import="com.cs336.pkg.*"%>

<%
    String transitLine = request.getParameter("transitLine");
    String customerName = request.getParameter("customerName");

    if ((transitLine == null || transitLine.isEmpty()) && (customerName == null || customerName.isEmpty())) {
        out.println("<p style='color: red;'>Please select either a transit line or a customer name to generate the report.</p>");
    } else {
        // Proceed with retrieving the report based on the criteria.
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();
            StringBuilder query = new StringBuilder(
                "SELECT r.reservationNo, r.customerId, r.transitLineId, r.originStationId, r.destinationStationId, " +
                "r.reservationDateTime, r.isRoundTrip, t.lineName, c.firstName, c.lastName " +
                "FROM Reservation r " +
                "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                "JOIN Customer c ON r.customerId = c.customerId " +
                "WHERE ");

            if (transitLine != null && !transitLine.isEmpty()) {
                query.append("t.lineName = ? ");
                if (customerName != null && !customerName.isEmpty()) {
                    query.append("OR ");
                }
            }
            if (customerName != null && !customerName.isEmpty()) {
                query.append("CONCAT(c.firstName, ' ', c.lastName) = ?");
            }

            ps = conn.prepareStatement(query.toString());

            int parameterIndex = 1;
            if (transitLine != null && !transitLine.isEmpty()) {
                ps.setString(parameterIndex++, transitLine);
            }
            if (customerName != null && !customerName.isEmpty()) {
                ps.setString(parameterIndex, customerName);
            }

            rs = ps.executeQuery();
            // Output the report results here (e.g., display in a table)
            out.println("<table border='1'>");
            out.println("<tr><th>Reservation No</th><th>Customer Name</th><th>Transit Line</th><th>Origin Station</th><th>Destination Station</th><th>Reservation Date/Time</th><th>Round Trip</th></tr>");

            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("reservationNo") + "</td>");
                out.println("<td>" + rs.getString("firstName") + " " + rs.getString("lastName") + "</td>");
                out.println("<td>" + rs.getString("lineName") + "</td>");
                out.println("<td>" + rs.getInt("originStationId") + "</td>");
                out.println("<td>" + rs.getInt("destinationStationId") + "</td>");
                out.println("<td>" + rs.getTimestamp("reservationDateTime") + "</td>");
                out.println("<td>" + (rs.getBoolean("isRoundTrip") ? "Yes" : "No") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");

        } catch (SQLException e) {
            e.printStackTrace();
            out.println("<p style='color: red;'>An error occurred while retrieving the report.</p>");
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
