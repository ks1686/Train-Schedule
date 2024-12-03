<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
<%@ page import="com.cs336.pkg.*"%>

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

<%
    // Check if the session is valid and the user is a manager
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    if (!"Manager".equals(session.getAttribute("role"))) {
        response.sendRedirect("../403.jsp");
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
                "SELECT r.reservationNo, r.customerId, r.transitLineId, r.originStationId, r.destinationStationId, " +
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
            out.println("<th>Origin Station</th>");
            out.println("<th>Destination Station</th>");
            out.println("<th>Reservation Date/Time</th>");
            out.println("<th>Round Trip</th>");
            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");

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
