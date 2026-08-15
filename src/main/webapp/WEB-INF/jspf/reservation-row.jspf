<%@ page import="com.cs336.pkg.*" %>
<%
    Reservation reservation = (Reservation) request.getAttribute("reservation");
    boolean showCancel = Boolean.TRUE.equals(request.getAttribute("showCancel"));
%>
<tr>
    <td>
        <b><i>#<%= reservation.getReservationNo() %></i></b><br><br>
        <b>Reserved At:</b> <%= Html.escape(reservation.getFormattedReservationDateTime()) %> <br>
        <b>Round Trip:</b> <%= reservation.isRoundTrip() ? "Yes" : "No" %>
    </td>
    <td>
        <b>Name:</b> <%= Html.escape(reservation.getCustomerFirstName()) %> <%= Html.escape(reservation.getCustomerLastName()) %><br>
        <b>Email:</b> <%= Html.escape(reservation.getCustomerEmail()) %>
    </td>
    <td>
        <b>Line:</b> <%= Html.escape(reservation.getTransitLineName()) %> <br>
        <b>Train:</b> <%= reservation.getTrainId() %>
    </td>
    <td>
        <b>Name:</b> <%= Html.escape(reservation.getOrigin().getName()) %> <br>
        <b>Location:</b> <%= Html.escape(reservation.getOrigin().getCity()) %>, <%= Html.escape(reservation.getOrigin().getState()) %>
    </td>
    <td>
        <b>Arrival:</b> <%= Html.escape(reservation.getFormattedOriginStationArrivalTime()) %> <br>
        <b>Departure:</b> <%= Html.escape(reservation.getFormattedOriginStationDepartureTime()) %>
    </td>
    <td>
        <b>Name:</b> <%= Html.escape(reservation.getDestination().getName()) %> <br>
        <b>Location:</b> <%= Html.escape(reservation.getDestination().getCity()) %>, <%= Html.escape(reservation.getDestination().getState()) %>
    </td>
    <td>
        <b>Arrival:</b> <%= Html.escape(reservation.getFormattedDestinationStationArrivalTime()) %> <br>
        <b>Departure:</b> <%= Html.escape(reservation.getFormattedDestinationStationDepartureTime()) %>
    </td>
    <td>
        <b>Total Cost:</b> <%= String.format("$%.2f", reservation.getOriginalFare()) %> <br>
        <b>Discount <span style="color:green">(-<%= reservation.getDiscountRate() %>%)</span>:</b> <%= String.format("-$%.2f", reservation.getCustomerDiscount()) %> <br>
        <b>Final Cost: <%= String.format("$%.2f", reservation.getCustomerFare()) %></b>
    </td>
    <% if (showCancel) { %>
    <td>
        <form action="cancelReservation.jsp" method="POST" style="display:inline">
            <%= Csrf.hiddenField(session) %>
            <input type="hidden" name="cancel" value="<%= reservation.getReservationNo() %>">
            <button type="submit" class="cancel-reservation">Cancel</button>
        </form>
    </td>
    <% } %>
</tr>
