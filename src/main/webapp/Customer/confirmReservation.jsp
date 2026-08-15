<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*,java.time.*"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>View Schedules</title>
    <link rel="stylesheet" href="../css/app.css">
</head>
<body>

<%
    if (!Auth.requireRole(request, response, Roles.CUSTOMER)) {
        return;
    }
    String username = Auth.username(session);
    String errorMessage = null;

    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("reserve") != null && !Csrf.isValid(request)) {
        response.sendRedirect("viewSchedules.jsp");
        return;
    }

    String lineId = request.getParameter("reserve");
    if (lineId == null) {
        lineId = (String) session.getAttribute("reserveLineId");
    }
    Integer originStationId = null;
    Integer destinationStationId = null;
    try {
        String origin = (String) session.getAttribute("originStationId");
        String dest = (String) session.getAttribute("destinationStationId");
        if (origin != null && !origin.isEmpty()) originStationId = Integer.valueOf(origin);
        if (dest != null && !dest.isEmpty()) destinationStationId = Integer.valueOf(dest);
    } catch (NumberFormatException ignored) {}

    LineSchedule sched = null;
    ApplicationDB appdb = new ApplicationDB();
    Connection conn = null;
    try {
        if (lineId != null) {
            session.setAttribute("reserveLineId", lineId);
            conn = appdb.getConnection();
            sched = new ScheduleDao().loadLine(conn, Integer.parseInt(lineId), originStationId, destinationStationId);
        }
    } catch (Exception e) {
        errorMessage = "Error loading schedule: " + e.getMessage();
    } finally {
        appdb.closeConnection(conn);
    }
    if (sched == null) {
        response.sendRedirect("viewSchedules.jsp");
        return;
    }
%>

<div class="header">
    <div class="username">Hello, <%= Html.escape(username) %>!</div>
    <form class="clear-button" method="POST" action="viewSchedules.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= Html.escape(errorMessage) %></div>
<% } %>

<div class="main-container">
	<h2>Confirm Reservation</h2>
	<div class="table-container">
		<table class="reservation-table">
        <thead>
            <tr>
                <th>Train</th>
                <th>Transit Line</th>
                <th>Origin</th>
                <th>Departure Time</th>
                <th>Destination</th>
                <th>Arrival Time</th>
                <th>Estimated Fare</th>
            </tr>
        </thead>
        <tbody>
		    <tr>
                <td><%= sched.getTrainId() %></td>
		        <td><%= Html.escape(sched.getLineName()) %></td>
		        <td><%= Html.escape(sched.getOrigin().toString()) %></td>
		        <td><%= Html.escape(sched.getFormattedDepartureDateTime()) %></td>
		        <td><%= Html.escape(sched.getDestination().toString()) %></td>
		        <td><%= Html.escape(sched.getFormattedArrivalDateTime()) %></td>
		        <td><b>$<%= String.format("%.02f", sched.getEstimatedFare()) %></b></td>
		    </tr>
        </tbody>      
	    </table>
	</div>
	
	<br>
    <details>
        <summary>View Stops</summary>
        
		<div class="table-container">
	        <table class="reservation-table">
	        <thead>
	            <tr>
	                <th>Station</th>
	                <th>Arrival Time</th>
	                <th>Departure Time</th>
	                <th>Estimated Fare</th>
	            </tr>
	        </thead>
	        <tbody>
	            <%
	            List<Object[]> lineStops = sched.getStops();
	            for (int ii = 0; ii < lineStops.size(); ii++) {
	                Object[] stop = lineStops.get(ii);
	                String stationName = Html.escape(stop[1].toString());
	                String arrivalTime = Html.escape((String) stop[2]), departureTime = Html.escape((String) stop[3]);
	                String color = Html.escape((String) stop[4]);
	                boolean bold = (boolean) stop[5];
	                
	                float estimatedFare = sched.getEstimatedFare(ii);
	                String estFareStr = String.format("$%.2f", estimatedFare);
	                if (estimatedFare == -1) estFareStr = "N/A";
	                
	                if (bold) {
	                    stationName = "<b>" + stationName + "</b>";
	                    arrivalTime = "<b>" + arrivalTime + "</b>";
	                    departureTime = "<b>" + departureTime + "</b>";
	                    estFareStr = "<b>" + estFareStr + "</b>";
	                }
	            %>
	            <tr>
	                <td style="color:<%= color %>"><%= stationName %></td>
	                <td style="color:<%= color %>"><%= arrivalTime %></td>
	                <td style="color:<%= color %>"><%= departureTime %></td>
	                <td style="color:<%= color %>"><%= estFareStr %></td>
	            </tr>
	        <% } %>
	        </tbody>
	        </table>
        </div>
    </details>    
    
    
    <br>
    
   	<h2>Finalize Reservation</h2>
   	<details>
   		<summary>Discounts Available</summary>
   		<p>Discounts don't stack! (eg. A child with a disability will have a 50% discount)
	   	<table class="reservation-table">
	   		<thead>
	   			<tr>
	   				<th>Status</th>
	   				<th>Discount</th>
	   		</thead>
	   		<tbody>
	   			<tr>
	   				<td>Children (0-12)</td>
	   				<td>25%</td>
	   			</tr>
	   			<tr>
	   				<td>Senior (65+)</td>
	   				<td>35%</td>
	   			</tr>
	   			<tr>
	   				<td>Disabled</td>
	   				<td>50%</td>
	   			</tr>
	   		</tbody>
	   	</table>
   	</details>
   	<br>
   	<div class="finalizeForm">
	    <form method="POST" action="placeReservation.jsp">
	    	<%= Csrf.hiddenField(session) %>
	    	<input type="hidden" name="reserve" value="<%= Html.escape(lineId) %>">
	    
	    	<label>Trip Type:</label>
	        <label>
	    		<input type="radio" name="tripType" value="oneway" required>One Way
	    	</label>
	    	<label>
	    		<input type="radio" name="tripType" value="round" required>Round Trip
	    	</label>
	    	<label class="info-text"><br>(return fare for round trip is same as departure - total price 2x final price)<br><br></label>
	    	
	    	<label>Age:</label>
	    	<input type="number" name="age" placeholder="Age" required min="0" />
	    	<label class="info-text"><br>(discount applicable for children 12 and under or seniors 65 and over)<br><br></label>
	    	
	       	<label>Do you have a disability?</label>
	       	<label>
	    		<input type="radio" name="disability" value="yes" required>Yes
	    	</label>
	    	<label>
	    		<input type="radio" name="disability" value="no" required>No
	    	</label>
	    	
	    	<br><br>
			<input type="submit" value="Reserve" class="reserve-button"/>
	    </form>
    </div>
</div>

</body>
</html>
