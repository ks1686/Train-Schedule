<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" import="java.io.*, java.sql.*"%>
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

    String month = request.getParameter("month");
    String year = request.getParameter("year");

    if (month == null || year == null) {
        out.println("<p>Error: Please provide the month and year to generate the sales report.</p>");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB db = new ApplicationDB();
        conn = db.getConnection();

        // SQL query to get the sales report data for the given month and year
        String query = "SELECT t.lineName AS 'Line Name', " +
                       "COUNT(r.reservationNo) AS 'Total Reservations', " +
                       "SUM(CASE WHEN r.isRoundTrip = TRUE " +
                       "         THEN (r.totalFare * 2 * (1 - r.discount / 100)) " +
                       "         ELSE (r.totalFare * (1 - r.discount / 100)) " +
                       "	END) AS 'Total Revenue' " +
                       "FROM Reservation r " +
                       "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                       "WHERE MONTH(r.reservationDateTime) = ? AND YEAR(r.reservationDateTime) = ? " +
                       "GROUP BY t.lineName";
        
        ps = conn.prepareStatement(query);
        ps.setInt(1, Integer.parseInt(month));
        ps.setInt(2, Integer.parseInt(year));
        rs = ps.executeQuery();

        // Displaying the report table
        out.println("<html>");
        out.println("<head><title>Sales Report</title></head>");
        out.println("<body>");
        out.println("<div class='header'>Sales Report</div>");
        out.println("<h2>Sales Report for " + new java.text.DateFormatSymbols().getMonths()[Integer.parseInt(month) - 1] + " " + year + "</h2>");
        out.println("<table border='1'>");
        out.println("<thead>");
        out.println("<tr>");
        out.println("<th>Line Name</th>");
        out.println("<th>Total Reservations</th>");
        out.println("<th>Total Revenue</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");

        int companyReservations = 0;
        double companyRevenue = 0;
        
        while (rs.next()) {
            String lineName = rs.getString("Line Name");
            int totalReservations = rs.getInt("Total Reservations");
            double totalRevenue = rs.getDouble("Total Revenue");
            companyReservations += totalReservations;
            companyRevenue += totalRevenue;
            out.println("<tr>");
            out.println("<td>" + lineName + "</td>");
            out.println("<td>" + totalReservations + "</td>");
            out.println("<td>" + String.format("$%.2f", totalRevenue) + "</td>");
            out.println("</tr>");
        }

        out.println("<tr>");
        out.println("<td></td>");
        out.println("<td><b>" + companyReservations + "</b></td>");
        out.println("<td><b>" + String.format("$%.2f", companyRevenue) + "</b></td>");
        out.println("</tr>");
        
        out.println("</tbody>");
        out.println("</table>");
        out.println("<br><button class='compact-button' onclick=\"window.location.href='managerWelcome.jsp'\">Back to Dashboard</button>");
        out.println("</body>");
        out.println("</html>");

    } catch (SQLException e) {
        e.printStackTrace();
        out.println("<p>Error: Unable to retrieve sales report data. Please try again later.</p>");
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>
