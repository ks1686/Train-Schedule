<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
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
            StringBuilder query = new StringBuilder();

            // Check if both transitLine and customerName are provided
            if (transitLine != null && !transitLine.isEmpty() && customerName != null && !customerName.isEmpty()) {
                // Query for revenue by transit line and customer name
                query.append("SELECT t.lineName, CONCAT(c.firstName, ' ', c.lastName) AS customerName, " +
	                         "SUM(r.totalFare) AS totalRevenue " +
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
                query.append("SELECT t.lineName, " +
	                         "SUM(r.totalFare) AS totalRevenue " +
                             "FROM Reservation r " +
                             "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                             "WHERE t.lineName = ? " +
                             "GROUP BY t.lineName"
                );

                ps = conn.prepareStatement(query.toString());
                ps.setString(1, transitLine);
            } else if (customerName != null && !customerName.isEmpty()) {
                // Query for revenue by customer name only
                query.append("SELECT CONCAT(c.firstName, ' ', c.lastName) AS customerName, " +
                        	 "SUM(r.totalFare) AS totalRevenue " +
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
                    out.println("<td>" + Html.escape(rs.getString("lineName")) + "</td>");
                    out.println("<td>" + Html.escape(rs.getString("customerName")) + "</td>");
                } else if (transitLine != null && !transitLine.isEmpty()) {
                    out.println("<td>" + Html.escape(rs.getString("lineName")) + "</td>");
                } else if (customerName != null && !customerName.isEmpty()) {
                    out.println("<td>" + Html.escape(rs.getString("customerName")) + "</td>");
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
