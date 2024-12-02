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
            justify-content: center;
            align-items: center;
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

        .form-container {
            margin-top: 20px;
        }

        .form-container input, .form-container textarea {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
        }    

        .viewQuestions {
            padding: 10px 20px;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .form-container textarea {
            font-size: 14px;
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
               

        .reservation-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
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
        response.sendRedirect("login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    
    if (!role.equals("Customer")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String errorMessage = null;
    List<Station> uniqueStations = new ArrayList<>();
    List<LineSchedule> scheduleRes = new ArrayList<>();
    
    String originStationId = request.getParameter("origin");
    String destinationStationId = request.getParameter("destination");
    String reservationDate = request.getParameter("reservationDate");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String query = "SELECT DISTINCT s.stationId, s.name, s.city, s.state FROM Stop " + 
                       "JOIN Station s ON Stop.stopStation = s.stationId";
        
        ps = conn.prepareStatement(query);
        rs = ps.executeQuery();

        while (rs.next()) {        	
        	uniqueStations.add(new Station(rs.getInt("stationId"), rs.getString("name"),rs.getString("city"), rs.getString("state")));
        }
        // Collections.sort(uniqueStations, (a, b) -> Integer.compare(a.getStationId(), b.getStationId()));
        
        String query2 = "SELECT tl.lineId AS LineId, tl.lineName AS LineName, s1.stationId AS OriginStationId, s1.name AS OriginStationName, s1.city AS OriginCity, s1.state AS OriginState, stop1.departureDateTime AS DepartureDateTime, " +
        				"s2.stationId AS DestinationStationId, s2.name AS DestinationStationName, s2.city AS DestinationCity, s2.state AS DestinationState, stop2.arrivalDateTime AS ArrivalDateTime, tl.fare AS Fare " +
		        		"FROM Station s1 " +
		        		"JOIN Stop stop1 ON s1.stationId = stop1.stopStation " +
		        		"JOIN TransitLine tl ON stop1.stopLine = tl.lineId " +
		        		"JOIN Stop stop2 ON tl.lineId = stop2.stopLine " +
		        		"JOIN Station s2 ON stop2.stopStation = s2.stationId " +
		        		"WHERE s1.stationId = ? AND s2.stationId = ? AND CAST(stop1.departureDateTime AS DATE) = ? AND stop1.departureDateTime < stop2.arrivalDateTime";
        
        PreparedStatement ps2 = conn.prepareStatement(query2);
        ps2.setString(1, originStationId);
        ps2.setString(2, destinationStationId);
        ps2.setString(3, reservationDate);
        ResultSet rs2 = ps2.executeQuery();
        
        while (rs2.next()) {
        	scheduleRes.add(new LineSchedule(rs2.getInt("LineId"), rs2.getString("LineName"), 
        			rs2.getInt("OriginStationId"), rs2.getString("OriginStationName"), rs2.getString("OriginCity"), rs2.getString("OriginState"), rs2.getString("DepartureDateTime"), 
        			rs2.getInt("DestinationStationId"), rs2.getString("DestinationStationName"), rs2.getString("DestinationCity"), rs2.getString("DestinationState"), rs2.getString("ArrivalDateTime"), 
        			rs2.getFloat("Fare")));
        }
    } catch (SQLException e) {
        errorMessage = "Error loading stations: " + e.getMessage();
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

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
    <div class="top-half">
		<!--  book reservations  -->
		<h3>View Alternate Schedules</h3>
		<form method="POST" action="viewSchedules.jsp" style="display: inline">
			<label>Origin: </label>
			<select name="origin" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= station.getStationId() == Integer.valueOf(originStationId) ? "selected" : "" %>>
						<%= station.toString() %>
					</option>
				<% } %>
			</select>
			
			<label>Destination: </label>
			<select name="destination" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= station.getStationId() == Integer.valueOf(destinationStationId) ? "selected" : "" %>>
						<%= station.toString() %>
					</option>
				<% } %>
			</select>
			
			<label>Date of Departure: </label>	            
            <input type="date" name="reservationDate" required value="<%= reservationDate %>">
			
			<button type="submit">View Schedules</button>
		</form>
		
		<h3>Book Reservation</h3>
		<table class="reservation-table">
        <thead>
            <tr>
                <th>Transit Line</th>
                <th>Origin</th>
                <th>Departure Time</th>
                <th>Destination</th>
                <th>Arrival Time</th>
                <th>Path</th>
                <th>Fare</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
            <% for (LineSchedule sched : scheduleRes) { %>
                <tr>
                    <td><%= sched.getLineName() %></td>
                    <td><%= sched.getOrigin() %></td>
                    <td><%= sched.getDepartureDateTime() %></td>
                    <td><%= sched.getDestination() %></td>
                    <td><%= sched.getArrivalDateTime() %></td>
                    <td></td>
                    <td>$<%= String.format("%.02f", sched.getLineFare()) %></td>
                    <td>
						some action
                    </td>
                </tr>
            <% } %>
        </tbody>
	    </table>
    </div>
 

    <div class="bottom-half">	        
		<form method="POST" action="askQuestion.jsp" style="display: inline">
			<button type="submit" class="viewQuestions">Speak with a Representative</button>
		</form>
    </div>
</div>

</body>
</html>
