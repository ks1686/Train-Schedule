package com.cs336.pkg;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ReservationDao {
    private static final String SELECT_DETAILS = "SELECT r.reservationNo, r.reservationDateTime, r.isRoundTrip, r.discount, "
            + "c.customerId, c.firstName AS customerFirstName, c.lastName AS customerLastName, c.email AS customerEmail, "
            + "tl.lineId AS transitLineId, tl.lineName AS transitLineName, tl.trainId as trainId, r.totalFare AS transitLineFare, "
            + "r.originStopId AS reservationOriginStopId, s1.stopStation AS reservationOriginStationId, rs1.name AS reservationOriginStationName, "
            + "rs1.city AS reservationOriginCity, rs1.state AS reservationOriginState, s1.departureDateTime AS originStationDepartureTime, s1.arrivalDateTime AS originStationArrivalTime, "
            + "r.destinationStopId AS reservationDestinationStopId, s2.stopStation AS reservationDestinationStationId, rs2.name AS reservationDestinationStationName, "
            + "rs2.city AS reservationDestinationCity, rs2.state AS reservationDestinationState, s2.departureDateTime AS destinationStationDepartureTime, s2.arrivalDateTime AS destinationStationArrivalTime "
            + "FROM Reservation r JOIN Customer c ON r.customerId = c.customerId JOIN TransitLine tl ON r.transitLineId = tl.lineId "
            + "JOIN Stop s1 ON r.originStopId = s1.stopId JOIN Stop s2 ON r.destinationStopId = s2.stopId "
            + "JOIN Station rs1 ON s1.stopStation = rs1.stationId JOIN Station rs2 ON s2.stopStation = rs2.stationId ";

    public List<Reservation> listForUsername(Connection conn, String username) throws SQLException {
        String query = SELECT_DETAILS + "WHERE c.username = ?";
        List<Reservation> reservations = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, username);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    reservations.add(fromRow(rs));
                }
            }
        }
        return reservations;
    }

    public int insert(Connection conn, String username, LineSchedule sched, boolean roundTrip, int discount)
            throws SQLException {
        if (sched == null || sched.getOriginIndex() < 0 || sched.getDestinationIndex() < 0) {
            return 0;
        }
        int originStopId = (int) sched.getStops().get(sched.getOriginIndex())[0];
        int destinationStopId = (int) sched.getStops().get(sched.getDestinationIndex())[0];
        float charged = FareCalculator.chargedAmount(sched.getEstimatedFare(), roundTrip, discount);
        if (charged < 0) {
            return 0;
        }
        String sql = "INSERT INTO Reservation (customerId, transitLineId, originStopId, destinationStopId, reservationDateTime, isRoundTrip, discount, totalFare) "
                + "VALUES ((SELECT customerId FROM Customer WHERE username = ?), ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setInt(2, sched.getLineId());
            ps.setInt(3, originStopId);
            ps.setInt(4, destinationStopId);
            ps.setTimestamp(5, Timestamp.valueOf(LocalDateTime.now().withNano(0)));
            ps.setBoolean(6, roundTrip);
            ps.setInt(7, discount);
            ps.setFloat(8, charged);
            return ps.executeUpdate();
        }
    }

    public int deleteOwned(Connection conn, int reservationNo, String username) throws SQLException {
        String sql = "DELETE FROM Reservation WHERE reservationNo = ? "
                + "AND customerId = (SELECT customerId FROM Customer WHERE username = ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, reservationNo);
            ps.setString(2, username);
            return ps.executeUpdate();
        }
    }

    public static Reservation fromRow(ResultSet rs) throws SQLException {
        return new Reservation(
                rs.getInt("reservationNo"), rs.getString("reservationDateTime"), rs.getBoolean("isRoundTrip"),
                rs.getInt("discount"), rs.getInt("customerId"), rs.getString("customerFirstName"),
                rs.getString("customerLastName"), rs.getString("customerEmail"), rs.getInt("transitLineId"),
                rs.getString("transitLineName"), rs.getInt("trainId"), rs.getFloat("transitLineFare"),
                rs.getInt("reservationOriginStopId"), rs.getInt("reservationOriginStationId"),
                rs.getString("reservationOriginStationName"), rs.getString("reservationOriginCity"),
                rs.getString("reservationOriginState"), rs.getString("originStationArrivalTime"),
                rs.getString("originStationDepartureTime"), rs.getInt("reservationDestinationStopId"),
                rs.getInt("reservationDestinationStationId"), rs.getString("reservationDestinationStationName"),
                rs.getString("reservationDestinationCity"), rs.getString("reservationDestinationState"),
                rs.getString("destinationStationArrivalTime"), rs.getString("destinationStationDepartureTime"));
    }
}
