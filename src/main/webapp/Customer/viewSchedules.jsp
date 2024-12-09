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
            justify-content: flex-start;
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
    
    List<Station> uniqueStations = new ArrayList<>();
    Map<Integer, LineSchedule> scheduleRes = new HashMap<>();
    List<Integer> keyOrder = new ArrayList<>();
    
    String originStationId = request.getParameter("originStationId") != null ? request.getParameter("originStationId") : (String) session.getAttribute("originStationId");
    String destinationStationId = request.getParameter("destinationStationId") != null ? request.getParameter("destinationStationId") : (String) session.getAttribute("destinationStationId");
    String reservationDate = request.getParameter("reservationDate") != null ? request.getParameter("reservationDate") : (String) session.getAttribute("reservationDate");
    
    session.setAttribute("originStationId", originStationId);
    session.setAttribute("destinationStationId", destinationStationId);
    session.setAttribute("reservationDate", reservationDate);
        
    String departureTimeSort = request.getParameter("departureTimeSort") != null ? request.getParameter("departureTimeSort") : "";
    String arrivalTimeSort = request.getParameter("arrivalTimeSort") != null ? request.getParameter("arrivalTimeSort") : "";
    String fareSort = request.getParameter("fareSort") != null ? request.getParameter("fareSort") : "";
    
    // System.out.println(departureTimeSort + " - " + arrivalTimeSort + " - " + fareSort);

    Connection conn = null;
    PreparedStatement ps1 = null, ps2 = null, ps3 = null;
    ResultSet rs1 = null, rs2 = null, rs3 = null;

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
        
        
        // Get all transit lines that are operating on the user's provided stations and date
        String query2 = "SELECT tl.lineId AS LineId, tl.lineName AS LineName, tl.trainId AS TrainId, s1.stationId AS OriginStationId, s1.name AS OriginStationName, s1.city AS OriginCity, s1.state AS OriginState, stop1.departureDateTime AS DepartureDateTime, " +
        				"s2.stationId AS DestinationStationId, s2.name AS DestinationStationName, s2.city AS DestinationCity, s2.state AS DestinationState, stop2.arrivalDateTime AS ArrivalDateTime, tl.fare AS Fare " +
		        		"FROM Station s1 " +
		        		"JOIN Stop stop1 ON s1.stationId = stop1.stopStation " +
		        		"JOIN TransitLine tl ON stop1.stopLine = tl.lineId " +
		        		"JOIN Stop stop2 ON tl.lineId = stop2.stopLine " +
		        		"JOIN Station s2 ON stop2.stopStation = s2.stationId " +
		        		"WHERE s1.stationId = ? AND s2.stationId = ? AND CAST(stop1.departureDateTime AS DATE) = ? AND stop1.departureDateTime < stop2.arrivalDateTime";
        
        
        ps2 = conn.prepareStatement(query2);
        ps2.setString(1, originStationId);
        ps2.setString(2, destinationStationId);
        ps2.setString(3, reservationDate);
        rs2 = ps2.executeQuery();
        
        while (rs2.next()) {
        	int lineId = rs2.getInt("LineId");
        	scheduleRes.put(lineId, new LineSchedule(lineId, rs2.getString("LineName"), rs2.getInt("TrainId"),
        			rs2.getInt("OriginStationId"), rs2.getString("OriginStationName"), rs2.getString("OriginCity"), rs2.getString("OriginState"), rs2.getString("DepartureDateTime"), 
        			rs2.getInt("DestinationStationId"), rs2.getString("DestinationStationName"), rs2.getString("DestinationCity"), rs2.getString("DestinationState"), rs2.getString("ArrivalDateTime"), 
        			rs2.getFloat("Fare")));
        	keyOrder.add(lineId);
        }
        
        
        // Get all stops on a transit line and their respective station
        String query3 = "SELECT tl.lineId AS LineId, stop.stopId as StopId, s.stationId AS StationId, s.name AS StationName, s.city AS StationCity, s.state AS StationState, stop.arrivalDateTime AS ArrivalDateTime, stop.departureDateTime AS DepartureDateTime " + 
		        		"FROM TransitLine tl " +
		        		"JOIN Stop stop ON tl.lineId = stop.stopLine " +
		        		"JOIN Station s ON stop.stopStation = s.stationId " +
		        		"ORDER BY DepartureDateTime ASC";
        
        ps3 = conn.prepareStatement(query3);
        rs3 = ps3.executeQuery();
        
        while (rs3.next()) {
        	int lineId = rs3.getInt("LineId");
        	if (scheduleRes.containsKey(lineId)) {        	
        		scheduleRes.get(lineId).addStop(rs3.getInt("StopId"), rs3.getInt("StationId"), rs3.getString("StationName"), rs3.getString("StationCity"), rs3.getString("StationState"), rs3.getString("ArrivalDateTime"), rs3.getString("DepartureDateTime"));
        	}
        }
        
        if (departureTimeSort.equals("desc")) {
        	Collections.sort(keyOrder, (a, b) -> {
        		LocalDateTime ldtA = scheduleRes.get(a).getDepartureDateTime(), ldtB = scheduleRes.get(b).getDepartureDateTime();
        		return ldtB.compareTo(ldtA);
        	});
        } else if (departureTimeSort.equals("asc")) {
        	Collections.sort(keyOrder, (a, b) -> {
        		LocalDateTime ldtA = scheduleRes.get(a).getDepartureDateTime(), ldtB = scheduleRes.get(b).getDepartureDateTime();
        		return ldtA.compareTo(ldtB);
        	});
        } else if (arrivalTimeSort.equals("desc")) {
        	Collections.sort(keyOrder, (a, b) -> {
        		LocalDateTime ldtA = scheduleRes.get(a).getArrivalDateTime(), ldtB = scheduleRes.get(b).getArrivalDateTime();
        		return ldtB.compareTo(ldtA);
        	});
        } else if (arrivalTimeSort.equals("asc")) {
        	Collections.sort(keyOrder, (a, b) -> {
        		LocalDateTime ldtA = scheduleRes.get(a).getArrivalDateTime(), ldtB = scheduleRes.get(b).getArrivalDateTime();
        		return ldtA.compareTo(ldtB);
        	});
        } else if (fareSort.equals("desc")) {
        	Collections.sort(keyOrder, (a, b) -> {
        		float fareA = scheduleRes.get(a).getEstimatedFare(), fareB = scheduleRes.get(b).getEstimatedFare();
        		return Float.compare(fareB, fareA);
        	});
        } else {
        	Collections.sort(keyOrder, (a, b) -> {
        		float fareA = scheduleRes.get(a).getEstimatedFare(), fareB = scheduleRes.get(b).getEstimatedFare();
        		return Float.compare(fareA, fareB);
        	});
        }
    } catch (SQLException e) {
        errorMessage = "Error loading stations: " + e.getMessage();
    } finally {
        try {
            if (rs1 != null) rs1.close();
            if (ps1 != null) ps1.close();
            if (rs2 != null) rs2.close();
            if (ps2 != null) ps2.close();
            if (rs3 != null) rs3.close();
            if (ps3 != null) ps3.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<div class="header">
    <div class="username">Hello, <%= username %>!</div>
    <form method="POST" action="customerWelcome.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
	<!--  book reservations  -->
	<h3>View Alternate Schedules</h3>
	<form method="POST" action="viewSchedules.jsp" style="display: inline">
		<label>Origin: </label>
		<select name="originStationId" required>
			<option value=""></option>
			<% for (Station station : uniqueStations) { %>
				<option value="<%= station.getStationId() %>"
				<%= station.getStationId() == Integer.valueOf(originStationId) ? "selected" : "" %>>
					<%= station.toString() %>
				</option>
			<% } %>
		</select>
		
		<label>Destination: </label>
		<select name="destinationStationId" required>
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
	
	<div class="table-container">
	<h3>Book Reservation</h3>
	<table class="reservation-table">
       <thead>
           <tr>
               <th>Train</th>
               <th>Transit Line</th>
               <th>Origin</th>
               <th>Departure Time 
                <form action="viewSchedules.jsp" method="POST" style="display: inline">	                	
                	<input type="hidden" name="departureTimeSort" value="<%= departureTimeSort.equals("asc") ? "desc" : "asc" %>">
				    <button type="submit">
				        <%= departureTimeSort.equals("asc") ? "&#9650;" : "&#9660;" %>
				    </button>
				</form>
			</th>
               <th>Destination</th>
               <th>Arrival Time 
                <form action="viewSchedules.jsp" method="POST" style="display: inline">	                	
                	<input type="hidden" name="arrivalTimeSort" value="<%= arrivalTimeSort.equals("asc") ? "desc" : "asc" %>">
				    <button type="submit">
				        <%= arrivalTimeSort.equals("asc") ? "&#9650;" : "&#9660;" %>
				    </button>
				</form>
			</th>
               <th>Path</th>
               <th>Fare 
                <form action="viewSchedules.jsp" method="POST" style="display: inline">	                	
                	<input type="hidden" name="fareSort" value="<%= fareSort.equals("asc") ? "desc" : "asc" %>">
				    <button type="submit">
				        <%= fareSort.equals("asc") ? "&#9650;" : "&#9660;" %>
				    </button>
				</form>
               </th>
               <th></th>
           </tr>
       </thead>
       <tbody>
           <%            
           for (Integer lineId : keyOrder) { 
           	LineSchedule sched = scheduleRes.get(lineId);
           	session.setAttribute("line: " + lineId, sched);
           %>
               <tr>
                   <td><%= sched.getTrainId() %></td>
                   <td><%= sched.getLineName() %></td>
                   <td><%= sched.getOrigin().toString() %></td>
                   <td><%= sched.getFormattedDepartureDateTime() %></td>
                   <td><%= sched.getDestination().toString() %></td>
                   <td><%= sched.getFormattedArrivalDateTime() %></td>
                   <td>
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
                   </td>
                   <td>$<%= String.format("%.02f", sched.getEstimatedFare()) %></td>
                   <td>
	                <form action="confirmReservation.jsp" method="POST" style="display: inline">	                	
	                	<input type="hidden" name="reserve" value="<%= lineId %>">
					    <button type="submit">Reserve</button>
					</form>
                   </td>
               </tr>
           <% } %>
       </tbody>      
    </table>
       <% if (scheduleRes.isEmpty()) { %>
       	<p style="color: red">No valid schedules.</p>            
       <% } %>
       </div>
</div>

</body>
</html>
