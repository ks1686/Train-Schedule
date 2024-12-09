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
    
    String reservationStatus = request.getParameter("reservation");
    String cancellationStatus = request.getParameter("cancellation");

    String errorMessage = null;
    List<Station> uniqueStations = new ArrayList<>();
    List<Reservation> currentReservations = new ArrayList<>();
    List<Reservation> pastReservations = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps1 = null, ps2 = null;
    ResultSet rs1 = null, rs2 = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String query = "SELECT DISTINCT s.stationId, s.name, s.city, s.state FROM Stop " + 
                       "JOIN Station s ON Stop.stopStation = s.stationId";
        
        ps1 = conn.prepareStatement(query);
        rs1 = ps1.executeQuery();

        while (rs1.next()) {        	
        	uniqueStations.add(new Station(rs1.getInt("stationId"), rs1.getString("name"), rs1.getString("city"), rs1.getString("state")));
        }
        // Collections.sort(uniqueStations, (a, b) -> Integer.compare(a.getStationId(), b.getStationId()));
            
        String reservationQuery = 	"SELECT r.reservationNo, r.reservationDateTime, r.isRoundTrip, r.discount, " +
        							"c.customerId, c.firstName AS customerFirstName, c.lastName AS customerLastName, c.email AS customerEmail, " + 
        							"tl.lineId AS transitLineId, tl.lineName AS transitLineName, r.totalFare AS transitLineFare, " + 
        							"r.originStopId AS reservationOriginStopId, s1.stopStation AS reservationOriginStationId, rs1.name AS reservationOriginStationName, " + 
        							"rs1.city AS reservationOriginCity, rs1.state AS reservationOriginState, s1.departureDateTime AS originStationDepartureTime, s1.arrivalDateTime AS originStationArrivalTime, " + 
        							"r.destinationStopId AS reservationDestinationStopId, s2.stopStation AS reservationDestinationStationId, rs2.name AS reservationDestinationStationName, " + 
        							"rs2.city AS reservationDestinationCity, rs2.state AS reservationDestinationState, s2.departureDateTime AS destinationStationDepartureTime, s2.arrivalDateTime AS destinationStationArrivalTime " +
        							"FROM Reservation r JOIN Customer c ON r.customerId = c.customerId JOIN TransitLine tl ON r.transitLineId = tl.lineId " +
        							"JOIN Stop s1 ON r.originStopId = s1.stopId	JOIN Stop s2 ON r.destinationStopId = s2.stopId JOIN Station rs1 ON s1.stopStation = rs1.stationId JOIN Station rs2 ON s2.stopStation = rs2.stationId " +
        							"WHERE c.customerId = (SELECT customerId FROM Customer WHERE username = ?)";
            
        ps2 = conn.prepareStatement(reservationQuery);
       	ps2.setString(1, username);
      
       	rs2 = ps2.executeQuery();
       	
        while (rs2.next()) {
            int reservationNo = rs2.getInt("reservationNo");
            String reservationDateTime = rs2.getString("reservationDateTime");
            boolean isRoundTrip = rs2.getBoolean("isRoundTrip");
            int discount = rs2.getInt("discount");
            
            int customerId = rs2.getInt("customerId");
            String customerFirstName = rs2.getString("customerFirstName");
            String customerLastName = rs2.getString("customerLastName");
            String customerEmail = rs2.getString("customerEmail");

            int transitLineId = rs2.getInt("transitLineId");
            String transitLineName = rs2.getString("transitLineName");
            float transitLineFare = rs2.getFloat("transitLineFare");
            
            int reservationOriginStopId = rs2.getInt("reservationOriginStopId");
            int reservationOriginStationId = rs2.getInt("reservationOriginStationId");
            String reservationOriginStationName = rs2.getString("reservationOriginStationName");
            String reservationOriginCity = rs2.getString("reservationOriginCity");
            String reservationOriginState = rs2.getString("reservationOriginState");
            String originStationArrivalTime = rs2.getString("originStationArrivalTime");
            String originStationDepartureTime = rs2.getString("originStationDepartureTime");

            int reservationDestinationStopId = rs2.getInt("reservationDestinationStopId");
            int reservationDestinationStationId = rs2.getInt("reservationDestinationStationId");
            String reservationDestinationStationName = rs2.getString("reservationDestinationStationName");
            String reservationDestinationCity = rs2.getString("reservationDestinationCity");
            String reservationDestinationState = rs2.getString("reservationDestinationState");
            String destinationStationArrivalTime = rs2.getString("destinationStationArrivalTime");
            String destinationStationDepartureTime = rs2.getString("destinationStationDepartureTime");
            
            Reservation reservation = new Reservation(reservationNo, reservationDateTime, isRoundTrip, discount, customerId, customerFirstName, customerLastName, customerEmail, transitLineId, transitLineName, transitLineFare, 
            											reservationOriginStopId, reservationOriginStationId, reservationOriginStationName, reservationOriginCity, reservationOriginState, originStationArrivalTime, originStationDepartureTime,
									            		reservationDestinationStopId, reservationDestinationStationId, reservationDestinationStationName, reservationDestinationCity, reservationDestinationState, destinationStationArrivalTime, destinationStationDepartureTime);
        

			if (reservation.isPastReservation()) {
				pastReservations.add(reservation);
			} else {
				currentReservations.add(reservation);
			}
        }
    } catch (SQLException e) {
        errorMessage = "Error loading stations: " + e.getMessage();
    } finally {
        try {
            if (rs2 != null) rs2.close();
            if (ps2 != null) ps2.close();
            if (rs1 != null) rs1.close();
            if (ps1 != null) ps1.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
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
		<form method="POST" action="viewSchedules.jsp" style="display: inline">
			<label>Origin: </label>
			<select name="originStationId" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"><%= station.toString() %></option>
				<% } %>
			</select>
			
			<label>Destination: </label>
			<select name="destinationStationId" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"><%= station.toString() %></option>
				<% } %>
			</select>
			
			<label>Date of Departure: </label>	            
            <input type="date" name="reservationDate" required value="<%= request.getParameter("reservationDate") %>">
			
			<button type="submit">View Schedules</button>
		</form>
		
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
						<% for (Reservation reservation : currentReservations) { %>
							<tr>
								<td>
									<b>Reserved At:</b> <%= reservation.getFormattedReservationDateTime() %> <br>
									<b>Round Trip:</b> <%= reservation.isRoundTrip() ? "Yes" : "No" %>
	 							</td>
								<td>
									<b>Name:</b> <%= reservation.getCustomerFirstName() %> <%= reservation.getCustomerLastName() %><br>
									<b>Email:</b> <%= reservation.getCustomerEmail() %>
	 							</td>
								<td>
									<%= reservation.getTransitLineName() %>
	 							</td>
	 							<td>
									<b>Name:</b> <%= reservation.getOrigin().getName() %> <br>
									<b>Location:</b> <%= reservation.getOrigin().getCity() %>, <%= reservation.getOrigin().getState() %> 
	 							</td>
	 							<td>
	 								<b>Arrival:</b> <%= reservation.getFormattedOriginStationArrivalTime() %> <br>
	 								<b>Departure:</b> <%= reservation.getFormattedOriginStationDepartureTime() %>
	 							</td>
	 							 <td>
									<b>Name:</b> <%= reservation.getDestination().getName() %> <br>
									<b>Location:</b> <%= reservation.getDestination().getCity() %>, <%= reservation.getDestination().getState() %> 
	 							</td>
	 							 <td>
	 								<b>Arrival:</b> <%= reservation.getFormattedDestinationStationArrivalTime() %> <br>
	 								<b>Departure:</b> <%= reservation.getFormattedDestinationStationDepartureTime() %>
	 							</td>
	 							<td>
	 								<b>Total Cost:</b> <%= String.format("$%.2f", reservation.getOriginalFare()) %> <br>
	 								<b>Discount <span style="color:green">(-<%= reservation.getDiscountRate() %>%)</span>:</b> <%= String.format("-$%.2f", reservation.getCustomerDiscount()) %> <br>
	 								<b>Final Cost: <%= String.format("$%.2f", reservation.getCustomerFare()) %></b>
	 							</td>
			                    <td>
					                <form action="cancelReservation.jsp" method="POST" style="display:inline">	                	
					                	<input type="hidden" name="cancel" value="<%= reservation.getReservationNo() %>">
									    <button type="submit">Cancel</button>
									</form>
			                    </td>
							</tr>
						<% } %>
					</tbody>
				</table>
			<% } %>
		</div>
		
		<details>
			<summary><h3>Past Reservations</h3></summary>
			
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
							<% for (Reservation reservation : pastReservations) { %>
								<tr>
									<td>
										<b>Reserved At:</b> <%= reservation.getFormattedReservationDateTime() %> <br>
										<b>Round Trip:</b> <%= reservation.isRoundTrip() ? "Yes" : "No" %>
		 							</td>
									<td>
										<b>Name:</b> <%= reservation.getCustomerFirstName() %> <%= reservation.getCustomerLastName() %><br>
										<b>Email:</b> <%= reservation.getCustomerEmail() %>
		 							</td>
									<td>
										<%= reservation.getTransitLineName() %>
		 							</td>
		 							<td>
										<b>Name:</b> <%= reservation.getOrigin().getName() %> <br>
										<b>Location:</b> <%= reservation.getOrigin().getCity() %>, <%= reservation.getOrigin().getState() %> 
		 							</td>
		 							<td>
		 								<b>Arrival:</b> <%= reservation.getFormattedOriginStationArrivalTime() %> <br>
		 								<b>Departure:</b> <%= reservation.getFormattedOriginStationDepartureTime() %>
		 							</td>
		 							 <td>
										<b>Name:</b> <%= reservation.getDestination().getName() %> <br>
										<b>Location:</b> <%= reservation.getDestination().getCity() %>, <%= reservation.getDestination().getState() %> 
		 							</td>
		 							 <td>
		 								<b>Arrival:</b> <%= reservation.getFormattedDestinationStationArrivalTime() %> <br>
		 								<b>Departure:</b> <%= reservation.getFormattedDestinationStationDepartureTime() %>
		 							</td>
		 							<td>
		 								<b>Total Cost:</b> <%= String.format("$%.2f", reservation.getOriginalFare()) %> <br>
		 								<b>Discount <span style="color:green">(-<%= reservation.getDiscountRate() %>%)</span>:</b> <%= String.format("-$%.2f", reservation.getCustomerDiscount()) %> <br>
		 								<b>Final Cost: <%= String.format("$%.2f", reservation.getCustomerFare()) %></b>
		 							</td>
								</tr>
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
