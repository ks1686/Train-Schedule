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
    List<Station> uniqueStations = new ArrayList<>();
    Map<Integer, LineSchedule> scheduleRes = new LinkedHashMap<>();
    List<Integer> keyOrder = new ArrayList<>();

    String originStationId = request.getParameter("originStationId");
    if (originStationId == null) originStationId = (String) session.getAttribute("originStationId");
    String destinationStationId = request.getParameter("destinationStationId");
    if (destinationStationId == null) destinationStationId = (String) session.getAttribute("destinationStationId");
    String reservationDate = request.getParameter("reservationDate");
    if (reservationDate == null) reservationDate = (String) session.getAttribute("reservationDate");

    session.setAttribute("originStationId", originStationId);
    session.setAttribute("destinationStationId", destinationStationId);
    session.setAttribute("reservationDate", reservationDate);

    Integer originId = null;
    Integer destId = null;
    try {
        if (originStationId != null && !originStationId.isEmpty()) {
            originId = Integer.valueOf(originStationId);
        }
    } catch (NumberFormatException ignored) {}
    try {
        if (destinationStationId != null && !destinationStationId.isEmpty()) {
            destId = Integer.valueOf(destinationStationId);
        }
    } catch (NumberFormatException ignored) {}

    String departureTimeSort = request.getParameter("departureTimeSort") != null ? request.getParameter("departureTimeSort") : "";
    String arrivalTimeSort = request.getParameter("arrivalTimeSort") != null ? request.getParameter("arrivalTimeSort") : "";
    String fareSort = request.getParameter("fareSort") != null ? request.getParameter("fareSort") : "";

    ApplicationDB appdb = new ApplicationDB();
    Connection conn = null;
    try {
        conn = appdb.getConnection();
        uniqueStations = new StationDao().listDistinctStopStations(conn);
        if (originId != null && destId != null && reservationDate != null && !reservationDate.isEmpty()) {
            scheduleRes = new ScheduleDao().search(conn, originId, destId, LocalDate.parse(reservationDate));
            keyOrder.addAll(scheduleRes.keySet());

            if (departureTimeSort.equals("desc")) {
                Collections.sort(keyOrder, (a, b) -> scheduleRes.get(b).getDepartureDateTime().compareTo(scheduleRes.get(a).getDepartureDateTime()));
            } else if (departureTimeSort.equals("asc")) {
                Collections.sort(keyOrder, (a, b) -> scheduleRes.get(a).getDepartureDateTime().compareTo(scheduleRes.get(b).getDepartureDateTime()));
            } else if (arrivalTimeSort.equals("desc")) {
                Collections.sort(keyOrder, (a, b) -> scheduleRes.get(b).getArrivalDateTime().compareTo(scheduleRes.get(a).getArrivalDateTime()));
            } else if (arrivalTimeSort.equals("asc")) {
                Collections.sort(keyOrder, (a, b) -> scheduleRes.get(a).getArrivalDateTime().compareTo(scheduleRes.get(b).getArrivalDateTime()));
            } else if (fareSort.equals("desc")) {
                Collections.sort(keyOrder, (a, b) -> Float.compare(scheduleRes.get(b).getEstimatedFare(), scheduleRes.get(a).getEstimatedFare()));
            } else if (fareSort.equals("asc")) {
                Collections.sort(keyOrder, (a, b) -> Float.compare(scheduleRes.get(a).getEstimatedFare(), scheduleRes.get(b).getEstimatedFare()));
            }
        }
    } catch (Exception e) {
        errorMessage = "Error loading stations: " + e.getMessage();
    } finally {
        appdb.closeConnection(conn);
    }
%>

<div class="header">
    <div class="username">Hello, <%= Html.escape(username) %>!</div>
    <form class="clear-button" method="POST" action="customerWelcome.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= Html.escape(errorMessage) %></div>
<% } %>

<div class="main-container">
	<!--  book reservations  -->
	<h3>View Alternate Schedules</h3>
	
    <div class="search-container">
		<form method="POST" action="viewSchedules.jsp" style="display: inline">
			<label>Origin: </label>
			<select name="originStationId" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= originId != null && station.getStationId() == originId.intValue() ? "selected" : "" %>>
						<%= Html.escape(station.toString()) %>
					</option>
				<% } %>
			</select>
			
			<label>Destination: </label>
			<select name="destinationStationId" required>
				<option value=""></option>
				<% for (Station station : uniqueStations) { %>
					<option value="<%= station.getStationId() %>"
					<%= destId != null && station.getStationId() == destId.intValue() ? "selected" : "" %>>
						<%= Html.escape(station.toString()) %>
					</option>
				<% } %>
			</select>
			
			<label>Date of Departure: </label>	            
	           <input type="date" name="reservationDate" required value="<%= Html.escape(reservationDate) %>">
			
            <input type="submit" value="View Schedules" />
		</form>
	</div>
	
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
				    <button type="submit" class="sort-button">
				        <%= departureTimeSort.equals("asc") ? "&#9650;" : "&#9660;" %>
				    </button>
				</form>
			</th>
               <th>Destination</th>
               <th>Arrival Time 
                <form action="viewSchedules.jsp" method="POST" style="display: inline">	                	
                	<input type="hidden" name="arrivalTimeSort" value="<%= arrivalTimeSort.equals("asc") ? "desc" : "asc" %>">
				    <button type="submit" class="sort-button">
				        <%= arrivalTimeSort.equals("asc") ? "&#9650;" : "&#9660;" %>
				    </button>
				</form>
			</th>
               <th>Path</th>
               <th>Fare 
                <form action="viewSchedules.jsp" method="POST" style="display: inline">	                	
                	<input type="hidden" name="fareSort" value="<%= fareSort.equals("asc") ? "desc" : "asc" %>">
				    <button type="submit" class="sort-button">
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
           %>
               <tr>
                   <td><%= sched.getTrainId() %></td>
                   <td><%= Html.escape(sched.getLineName()) %></td>
                   <td><%= Html.escape(sched.getOrigin().toString()) %></td>
                   <td><%= Html.escape(sched.getFormattedDepartureDateTime()) %></td>
                   <td><%= Html.escape(sched.getDestination().toString()) %></td>
                   <td><%= Html.escape(sched.getFormattedArrivalDateTime()) %></td>
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
                   	</details>
                   </td>
                   <td>$<%= String.format("%.02f", sched.getEstimatedFare()) %></td>
                   <td>
	                <form action="confirmReservation.jsp" method="POST" style="display: inline">
	                	<%= Csrf.hiddenField(session) %>
	                	<input type="hidden" name="reserve" value="<%= lineId %>">
					    <button type="submit" class="reserve-button">Reserve</button>
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
