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

    // Retrieve the parameters sent via POST
    String lineId = request.getParameter("lineId");
    String departure = request.getParameter("departure");
    String arrival = request.getParameter("arrival");
    String lineName = request.getParameter("lineName");
    String origin = request.getParameter("origin");
    String destination = request.getParameter("destination");
    String fare = request.getParameter("fare");

    // Connection setup for the database
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();
        
        // Query to find stationId for origin
        String getOriginIdQuery = "SELECT stationId FROM Station WHERE name = ?";
        ps = conn.prepareStatement(getOriginIdQuery);
        ps.setString(1, origin);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            int originStationId = rs.getInt("stationId");
            
            // Reset the prepared statement to find the stationId for destination
            rs.close();
            ps.close();
            
            String getDestinationIdQuery = "SELECT stationId FROM Station WHERE name = ?";
            ps = conn.prepareStatement(getDestinationIdQuery);
            ps.setString(1, destination);
            rs = ps.executeQuery();

            if (rs.next()) {
                int destinationStationId = rs.getInt("stationId");
                
                // Now, update the TransitLine table using these station IDs
                String updateQuery = "UPDATE TransitLine SET lineName = ?, origin = ?, destination = ?, departureDateTime = ?, arrivalDateTime = ?, fare = ? WHERE lineId = ?";
                ps = conn.prepareStatement(updateQuery);
                ps.setString(1, lineName);
                ps.setInt(2, originStationId); // Set the origin as an integer ID
                ps.setInt(3, destinationStationId); // Set the destination as an integer ID
                ps.setString(4, departure);
                ps.setString(5, arrival);
                ps.setFloat(6, Float.parseFloat(fare));
                ps.setInt(7, Integer.parseInt(lineId));
                
                int result = ps.executeUpdate();
                if (result > 0) {
                    response.sendRedirect("repWelcome.jsp");
                } else {
                    response.sendRedirect("repWelcome.jsp");
                }
            } else {
                out.print("Error: Destination station not found.");
            }
        } else {
            out.print("Error: Origin station not found.");
        }
    } catch (SQLException e) {
        e.printStackTrace();
        out.print("Error: " + e.getMessage());
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
