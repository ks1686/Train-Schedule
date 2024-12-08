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
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .header {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header .username {
            color: black;
            font-size: 20px;
            font-weight: bold;
        }

        .main-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            padding: 20px;
            flex-grow: 1;
        }

        .top-half {
            flex: 6;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            align-items: center;
            height: 100vh;
            overflow-y: visible;
        }

        .bottom-half {
            flex: 1;
            overflow-y: visible;
            margin-top: 20px;
			display: block;
			margin: auto;
		    justify-content: center;
		    align-items: center;
        }

        .logout-button {
            padding: 8px 16px;
            background-color: #f44336;
            color: white;
            font-size: 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        
        .logout-button:hover {
            background-color: #d32f2f;
        }
        
        .table-container {
        	width: 100%;
            align-items: center;
            text-align: center;
        }
               
        .reservation-table {
            width: 100%;
            border-collapse: collapse;
        }

        .reservation-table th, .employee-table td {
            border: 1px solid #ddd;
            padding: 8px;
        }

        .reservation-table th {
            background-color: #4CAF50;
            color: white;
        }

        .reservation-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        .reservation-table tr:hover {
            background-color: #f1f1f1;
        }

        .label-bold {
            font-weight: bold;
        }

    </style>
</head>
<body>

<% 
	String username = (String) session.getAttribute("username");

    if (session == null || username == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    
    if (!role.equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String errorMessage = null;
    
    String lineId = request.getParameter("reserve");
    LineSchedule sched = (LineSchedule) session.getAttribute("line: " + lineId);
%>

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <form method="POST" action="viewSchedules.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
	<h2>Confirm Reservation</h2>
	<div class="table-container">
		<table class="reservation-table">
        <thead>
            <tr>
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
		        <td><%= sched.getLineName() %></td>
		        <td><%= sched.getOrigin().toString() %></td>
		        <td><%= sched.getFormattedDepartureDateTime() %></td>
		        <td><%= sched.getDestination().toString() %></td>
		        <td><%= sched.getFormattedArrivalDateTime() %></td>
		        <td><b>$<%= String.format("%.02f", sched.getEstimatedFare()) %></b></td>
		    </tr>
        </tbody>      
	    </table>
	</div>
	
    <details>
        <summary>View Stops</summary>
        <table>
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
                String stationName = stop[1].toString();
                String arrivalTime = (String) stop[2], departureTime = (String) stop[3];
                String color = (String) stop[4];
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
    </details>    
    
    
    <br>
    
   	<h2>Finalize Reservation</h2>
   	<details>
   		<summary>Discounts Available</summary>
   		<p>Discounts don't stack! (eg. A child with a disability will have a 50% discount)
	   	<table>
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
    <form method="POST" action="placeReservation.jsp">
    	<input type="hidden" name="reserve" value="<%= lineId %>">
    
    	<label>Trip Type:</label>
        <label>
    		<input type="radio" name="tripType" value="oneway" required>One Way
    	</label>
    	<label>
    		<input type="radio" name="tripType" value="round" required>Round Trip
    	</label>
    	<label style="color:gray">(return fare for round trip is same as departure - total price 2x final price)<br></label>
    	
    	<label>Age:</label>
    	<input type="number" name="age" placeholder="Age" required min="0" />
    	<label style="color:gray">(discount applicable for children 12 and under or seniors 65 and over)<br></label>
    	
       	<label>Do you have a disability?</label>
       	<label>
    		<input type="radio" name="disability" value="yes" required>Yes
    	</label>
    	<label>
    		<input type="radio" name="disability" value="no" required>No
    	</label>
    	
    	<br>
		<input type="submit" value="Reserve" />
    </form>
</div>

</body>
</html>
