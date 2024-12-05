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
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    
    if (!role.equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }
    
    if (request.getParameter("clear") != null && session.getAttribute("reserving") != null) {
        session.removeAttribute("reserving");
        response.sendRedirect("viewSchedules.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String errorMessage = null;
    
    String lineId = request.getParameter("reserve");
    LineSchedule line = (LineSchedule) session.getAttribute("line: " + lineId);
    
    List<LineSchedule> reservation = session.getAttribute("reserving") != null ? (List<LineSchedule>) session.getAttribute("reserving") : new ArrayList<>();
    
    // can't be on the same transitLine
    boolean checkDupe = true;
    for (LineSchedule sched : reservation) {
    	if (sched.getLineId() == Integer.valueOf(lineId)) {
    		checkDupe = false;
    		break;
    	}
    }
    
    if (checkDupe) {
    	reservation.add(line); 
    	session.setAttribute("reserving", reservation);
    }  
%>

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <form method="POST" action="confirmReservation.jsp">
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
           	<%            
            for (LineSchedule sched : reservation) { 
            %>
               <tr>
                   <td><%= sched.getLineName() %></td>
                   <td><%= sched.getOrigin().toString() %></td>
                   <td><%= sched.getFormattedDepartureDateTime() %></td>
                   <td><%= sched.getDestination().toString() %></td>
                   <td><%= sched.getFormattedArrivalDateTime() %></td>
                   <td><b>$<%= String.format("%.02f", sched.getEstimatedFare()) %></b></td>
               </tr>
            <% } %>
        </tbody>      
	    </table>
	</div>
	
    <details>
        <summary>View Stops</summary>
        <% for (int ss = 0; ss < reservation.size(); ss++) { 
        		LineSchedule sched = reservation.get(ss);
				if (ss == 0) {
        %>
        		<h4>Departure</h4>
        	<% } else if (ss == 1) { %>
        		<h4>Arrival</h4>
        	<% } %>
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
	                String stationName = stop[0].toString();
	                String arrivalTime = (String) stop[1], departureTime = (String) stop[2];
	                String color = (String) stop[3];
	                boolean bold = (boolean) stop[4];
	                
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
        <% } %>
    </details>    
    
    <br>
       
    <% if (reservation.size() == 1) { 
    	LineSchedule sched = reservation.get(0);
    %>
    	<h2>Book Round Trip</h2>
	   	<form method="POST" action="viewSchedules.jsp" style="display: inline">
			<input type="hidden" name="originStationId" value="<%= sched.getDestination().getStationId() %>">
			
			<input type="hidden" name="destinationStationId" value="<%= sched.getOrigin().getStationId() %>">
			
			<input type="hidden" name="arrivalTime" value="<%= reservation.get(0).getArrivalDateTime().toLocalTime() %>"> <!-- TODO: return must be after arrival time in viewschedules -->
			
			<label>Date of Return: </label>	            
	        <input type="date" name="reservationDate" required value="<%= request.getParameter("reservationDate") %>" min="<%= reservation.get(0).getArrivalDateTime().toLocalDate() %>">
			
			<button type="submit">Book Round Trip</button>
		</form>
	<% } %>
    
    <br>
    
    <form method="POST" action="">
    	<label>Age</label>
    	<input type="text" name="age" placeholder="Age" required /><br>
    	<label>(discount applicable for children 12 and under or seniors 65 and over)<br></label>
    	
       	<label>Do you have a disability?</label>
       	<label>
    		<input type="radio" name="disability" value="yes" placeholder="Age">Yes
    	</label>
    	<label>
    		<input type="radio" name="disability" value="no" placeholder="Age">No
    	</label>
    	
    	<br>
		<input type="submit" value="Reserve" />
    </form>
</div>

</body>
</html>
