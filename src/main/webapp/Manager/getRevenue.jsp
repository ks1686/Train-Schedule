<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="java.io.*, java.util.*, java.sql.*, javax.servlet.http.*, javax.servlet.*"%>
<%@ page import="com.cs336.pkg.*"%>

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
    
        // Building the query for revenue calculation based on input
        if (transitLine != null && !transitLine.isEmpty()) {
            // Query for revenue by transit line
            query.append("SELECT t.lineName, SUM(t.fare) AS totalRevenue " +
                         "FROM Reservation r " +
                         "JOIN TransitLine t ON r.transitLineId = t.lineId " +
                         "WHERE t.lineName = ? " +
                         "GROUP BY t.lineName"
            );
        
            ps = conn.prepareStatement(query.toString());
            ps.setString(1, transitLine);
        } else if (customerName != null && !customerName.isEmpty()) {
            // Query for revenue by customer name
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
        out.println("<head><title>Revenue Report</title></head>");
        out.println("<body>");
        out.println("<h2>Revenue Report</h2>");
        out.println("<table border='1'>");
        out.println("<thead>");
        out.println("<tr>");
        if (transitLine != null && !transitLine.isEmpty()) {
            out.println("<th>Transit Line</th>");
        } else {
            out.println("<th>Customer Name</th>");
        }
        out.println("<th>Total Revenue</th>");
        out.println("</tr>");
        out.println("</thead>");
        out.println("<tbody>");
    
        while (rs.next()) {
            out.println("<tr>");
            if (transitLine != null && !transitLine.isEmpty()) {
                out.println("<td>" + rs.getString("lineName") + "</td>");
            } else {
                out.println("<td>" + rs.getString("customerName") + "</td>");
            }
            out.println("<td>$" + String.format("%.2f", rs.getDouble("totalRevenue")) + "</td>");
            out.println("</tr>");
        }
    
        out.println("</tbody>");
        out.println("</table>");
        out.println("<br><button onclick=\"window.location.href='managerWelcome.jsp'\">Back to Dashboard</button>");
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

