<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
<%@ page import="com.cs336.pkg.*"%>

<link rel="stylesheet" href="../css/app.css">

<%
    if (!Auth.requireRole(request, response, Roles.MANAGER)) {
        return;
    }

    String transitLine = request.getParameter("transitLine");
    String customerName = request.getParameter("customerName");

    if ((transitLine == null || transitLine.isEmpty()) && (customerName == null || customerName.isEmpty())) {
        out.println("<p style='color: red;'>Please select either a transit line or a customer name to generate the report.</p>");
    } else {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();
            StringBuilder query = new StringBuilder(
                "SELECT r.reservationNo, r.customerId, r.transitLineId, r.originStopId, r.destinationStopId, " +
                "r.reservationDateTime, r.isRoundTrip, t.lineName, c.firstName, c.lastName " +
                "FROM Reservation r " +
                "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                "JOIN Customer c ON r.customerId = c.customerId " +
                "WHERE ");

            List<String> conditions = new ArrayList<>();
            if (transitLine != null && !transitLine.isEmpty()) {
                conditions.add("t.lineName = ?");
            }
            if (customerName != null && !customerName.isEmpty()) {
                conditions.add("CONCAT(c.firstName, ' ', c.lastName) = ?");
            }

            if (!conditions.isEmpty()) {
                query.append(String.join(" AND ", conditions));
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

            out.println("<html>");
            out.println("<head><title>Reservation Report</title></head>");
            out.println("<body>");
            out.println("<div class='header'>Reservation Report</div>");
            out.println("<h2>Filtered Reservations</h2>");
            out.println("<table border='1'>");
            out.println("<thead>");
            out.println("<tr>");
            out.println("<th>Reservation No</th>");
            out.println("<th>Customer Name</th>");
            out.println("<th>Transit Line</th>");
            out.println("<th>Origin Stop ID</th>");
            out.println("<th>Destination Stop ID</th>");
            out.println("<th>Reservation Date/Time</th>");
            out.println("<th>Round Trip</th>");
            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");

            while (rs.next()) {
                out.println("<tr>");
                out.println("<td>" + rs.getInt("reservationNo") + "</td>");
                out.println("<td>" + Html.escape(rs.getString("firstName") + " " + rs.getString("lastName")) + "</td>");
                out.println("<td>" + Html.escape(rs.getString("lineName")) + "</td>");
                out.println("<td>" + rs.getInt("originStopId") + "</td>");
                out.println("<td>" + rs.getInt("destinationStopId") + "</td>");
                out.println("<td>" + rs.getTimestamp("reservationDateTime") + "</td>");
                out.println("<td>" + (rs.getBoolean("isRoundTrip") ? "Yes" : "No") + "</td>");
                out.println("</tr>");
            }

            out.println("</tbody>");
            out.println("</table>");
            out.println("<br><button class='compact-button' onclick=\"window.location.href='managerWelcome.jsp'\">Back to Dashboard</button>");
            out.println("</body>");
            out.println("</html>");

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
