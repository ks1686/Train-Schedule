<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
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
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");

    if ((transitLine == null || transitLine.isEmpty()) && (customerName == null || customerName.isEmpty())) {
        out.println("<p style='color: red;'>Please select either a transit line or a customer name to generate the report.</p>");
    } else {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            ApplicationDB db = new ApplicationDB();
            conn = db.getConnection();
            StringBuilder query = new StringBuilder();

            // Check if both transitLine and customerName are provided
            if (transitLine != null && !transitLine.isEmpty() && customerName != null && !customerName.isEmpty()) {
                // Query for revenue by transit line and customer name
                query.append("SELECT t.lineName, CONCAT(c.firstName, ' ', c.lastName) AS customerName, SUM(t.fare) AS totalRevenue " +
                             "FROM Reservation r " +
                             "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                             "JOIN Customer c ON r.customerId = c.customerId " +
                             "WHERE t.lineName = ? AND CONCAT(c.firstName, ' ', c.lastName) = ? " +
                             "GROUP BY t.lineName, c.firstName, c.lastName"
                );

                ps = conn.prepareStatement(query.toString());
                ps.setString(1, transitLine);
                ps.setString(2, customerName);
            } else if (transitLine != null && !transitLine.isEmpty()) {
                // Query for revenue by transit line only
                query.append("SELECT t.lineName, SUM(t.fare) AS totalRevenue " +
                             "FROM Reservation r " +
                             "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                             "WHERE t.lineName = ? " +
                             "GROUP BY t.lineName"
                );

                ps = conn.prepareStatement(query.toString());
                ps.setString(1, transitLine);
            } else if (customerName != null && !customerName.isEmpty()) {
                // Query for revenue by customer name only
                query.append("SELECT CONCAT(c.firstName, ' ', c.lastName) AS customerName, SUM(t.fare) AS totalRevenue " +
                             "FROM Reservation r " +
                             "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                             "JOIN Customer c ON r.customerId = c.customerId " +
                             "WHERE CONCAT(c.firstName, ' ', c.lastName) = ? " +
                             "GROUP BY c.firstName, c.lastName"
                );

                ps = conn.prepareStatement(query.toString());
                ps.setString(1, customerName);
            }

            rs = ps.executeQuery();

            // Output the results
            out.println("<html>");
            out.println("<body>");
            out.println("<div class='header'>Revenue Report</div>");
            out.println("<h2>Revenue Report</h2>");
            out.println("<table>");
            out.println("<thead>");
            out.println("<tr>");
            if (transitLine != null && !transitLine.isEmpty() && customerName != null && !customerName.isEmpty()) {
                out.println("<th>Transit Line</th>");
                out.println("<th>Customer Name</th>");
            } else if (transitLine != null && !transitLine.isEmpty()) {
                out.println("<th>Transit Line</th>");
            } else if (customerName != null && !customerName.isEmpty()) {
                out.println("<th>Customer Name</th>");
            }
            out.println("<th>Total Revenue</th>");
            out.println("</tr>");
            out.println("</thead>");
            out.println("<tbody>");

            while (rs.next()) {
                out.println("<tr>");
                if (transitLine != null && !transitLine.isEmpty() && customerName != null && !customerName.isEmpty()) {
                    out.println("<td>" + rs.getString("lineName") + "</td>");
                    out.println("<td>" + rs.getString("customerName") + "</td>");
                } else if (transitLine != null && !transitLine.isEmpty()) {
                    out.println("<td>" + rs.getString("lineName") + "</td>");
                } else if (customerName != null && !customerName.isEmpty()) {
                    out.println("<td>" + rs.getString("customerName") + "</td>");
                }
                out.println("<td>$" + String.format("%.2f", rs.getDouble("totalRevenue")) + "</td>");
                out.println("</tr>");
            }

            out.println("</tbody>");
            out.println("</table>");
            out.println("<br><button class='compact-button' onclick=\"window.location.href='managerWelcome.jsp'\">Back to Dashboard</button>");
            out.println("<div class='footer'>Footer Content</div>");
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
