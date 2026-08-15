<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Welcome</title>
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
        
		table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
            border: 1px solid #ddd;
            padding: 8px;
        }

        th, td {
            padding: 8px;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }
        
		tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        tr:hover {
            background-color: #f1f1f1;
        }

        .bottom-half {
            flex: 0.5;
            overflow-y: visible;
            margin-top: 20px;
			display: block;
			margin: auto;
		    justify-content: center;
		    align-items: center;
        }
        
        .search-container input[type="text"] {
            padding: 8px 20px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            width: 260px;
            margin-bottom: 5px;
            box-sizing: border-box;
        }

        .search-container input[type="submit"] {
            padding: 8px 16px;
            font-size: 16px;
            border: none;
            background-color: #4CAF50;
            color: white;
            border-radius: 4px;
            cursor: pointer;
        }

        .search-container input[type="submit"]:hover {
            background-color: #45a049;
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

        .label-bold {
            font-weight: bold;
        }

        .cancel-reservation {
            padding: 6px 12px;
            border: none;
            cursor: pointer;
            background-color: #f44336;
            color: white;
        }

        .viewQuestions {
            padding: 6px 12px;
            border: none;
            cursor: pointer;
            background-color: #2196F3;
            color: white;
        }
        
        .h3 {
       	    font-size: 1.17em;
		    font-weight: bold;
		    margin-top: 1em; 
		    margin-bottom: 1em;
		    line-height: 1.5;
        }
    </style>
</head>
<body>

<%
    if (!Auth.requireRole(request, response, Roles.CUSTOMER)) {
        return;
    }
    String username = Auth.username(session);

    String reservationStatus = request.getParameter("reservation");
    String cancellationStatus = request.getParameter("cancellation");

    String errorMessage = null;
    List<Station> uniqueStations = new ArrayList<>();
    List<Reservation> currentReservations = new ArrayList<>();
    List<Reservation> pastReservations = new ArrayList<>();

    ApplicationDB appdb = new ApplicationDB();
    Connection conn = null;
    try {
        conn = appdb.getConnection();
        uniqueStations = new StationDao().listDistinctStopStations(conn);
        for (Reservation reservation : new ReservationDao().listForUsername(conn, username)) {
            if (reservation.isPastReservation()) {
                pastReservations.add(reservation);
            } else {
                currentReservations.add(reservation);
            }
        }
    } catch (SQLException e) {
        errorMessage = "Error loading stations: " + e.getMessage();
    } finally {
        appdb.closeConnection(conn);
    }
%>

<div class="header">
    <div class="username">Hello, <%= Html.escape(username) %>!</div>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= Html.escape(errorMessage) %></div>
<% } %>

<div class="main-container">
    <div class="top-half">
    	<% if (reservationStatus != null) { 
    			if (reservationStatus.equals("success")) { %>
    			
    				<p style="color: green">Reservation Secured</p>
    				
    			<% } else if (reservationStatus.equals("failure")) { %>
    				   	
    				<p style="color: red">Could not place reservation. Please try again.</p>
    				
    			<% } else if (reservationStatus.equals("error")) { %>
    			
    				<p style="color: red">500: Internal server error while placing reservation. Please try again.</p>
    	<% 		} 
    		} 
    	
    		if (cancellationStatus != null) { 
    				if (cancellationStatus.equals("success")) { %>
    			
					<p style="color: red">Reservation Canceled</p>
				
				<% } else if (cancellationStatus.equals("failure")) { %>
				   	
					<p style="color: red">Could not cancel reservation. Please try again.</p>
				
				<% } else if (cancellationStatus.equals("error")) { %>
			
					<p style="color: red">500: Internal server error while canceling reservation. Please try again.</p>
		<% 		} 	
			} 
		%>
    
		<!--  book reservations  -->
		<h3>Book Reservation</h3>
        <div class="search-container">
			<form method="POST" action="viewSchedules.jsp" style="display: inline">
				<label>Origin: </label>
				<select name="originStationId" required>
					<option value=""></option>
					<% for (Station station : uniqueStations) { %>
						<option value="<%= station.getStationId() %>"><%= Html.escape(station.toString()) %></option>
					<% } %>
				</select>
				
				<label>Destination: </label>
				<select name="destinationStationId" required>
					<option value=""></option>
					<% for (Station station : uniqueStations) { %>
						<option value="<%= station.getStationId() %>"><%= Html.escape(station.toString()) %></option>
					<% } %>
				</select>
				
				<label>Date of Departure: </label>	            
	            <input type="date" name="reservationDate" required value="<%= Html.escape(request.getParameter("reservationDate")) %>">
				
	            <input type="submit" value="View Schedules" />
			</form>
		</div>
		
		<!--  view reservations  -->
		<h3>Upcoming Reservations</h3>

		<div class="reservation-container">
			<% if (currentReservations.isEmpty()) { %> 
				<p>No upcoming reservations.</p>
			<% } else { %>
				<table>
					<thead>
						<tr>
							<th>Reservation</th>
							<th>Passenger</th>
							<th>Transit Line</th>
							<th>Origin</th>
							<th>Time</th>
							<th>Destination</th>
							<th>Time</th>
							<th>Cost</th>
							<th></th>
						</tr>
					</thead>
					<tbody>
						<% for (Reservation reservation : currentReservations) {
						    request.setAttribute("reservation", reservation);
						    request.setAttribute("showCancel", Boolean.TRUE);
						%>
						    <jsp:include page="/WEB-INF/jspf/reservation-row.jspf" />
						<% } %>
					</tbody>
				</table>
			<% } %>
		</div>
		
		<details>
			<summary class="h3">Past Reservations</summary>
			
			<div class="reservation-container">
				<% if (pastReservations.isEmpty()) { %> 
					<p>No previous reservations.</p>
				<% } else { %>
					<table>
						<thead>
							<tr>
								<th>Reservation</th>
								<th>Passenger</th>
								<th>Transit Line</th>
								<th>Origin</th>
								<th>Time</th>
								<th>Destination</th>
								<th>Time</th>
								<th>Cost</th>
							</tr>
						</thead>
						<tbody>
							<% for (Reservation reservation : pastReservations) {
							    request.setAttribute("reservation", reservation);
							    request.setAttribute("showCancel", Boolean.FALSE);
							%>
							    <jsp:include page="/WEB-INF/jspf/reservation-row.jspf" />
							<% } %>
						</tbody>
					</table>
				<% } %>
			</div>
		</details>
    </div>
 

    <div class="bottom-half">	        
		<form method="POST" action="askQuestion.jsp" style="display: inline">
			<button type="submit" class="viewQuestions">Speak with a Representative</button>
		</form>
    </div>
</div>

</body>
</html>
