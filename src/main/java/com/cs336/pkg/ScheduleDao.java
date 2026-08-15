package com.cs336.pkg;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

public class ScheduleDao {
    public LineSchedule loadLine(Connection conn, int lineId, Integer originStationId, Integer destinationStationId)
            throws SQLException {
        String query = "SELECT tl.lineId AS LineId, tl.lineName AS LineName, tl.trainId AS TrainId, "
                + "s1.stationId AS OriginStationId, s1.name AS OriginStationName, s1.city AS OriginCity, s1.state AS OriginState, "
                + "COALESCE(stop1.departureDateTime, tl.departureDateTime) AS DepartureDateTime, "
                + "s2.stationId AS DestinationStationId, s2.name AS DestinationStationName, s2.city AS DestinationCity, s2.state AS DestinationState, "
                + "COALESCE(stop2.arrivalDateTime, tl.arrivalDateTime) AS ArrivalDateTime, tl.fare AS Fare "
                + "FROM TransitLine tl "
                + "JOIN Station s1 ON s1.stationId = COALESCE(?, tl.origin) "
                + "LEFT JOIN Stop stop1 ON stop1.stopLine = tl.lineId AND stop1.stopStation = s1.stationId "
                + "JOIN Station s2 ON s2.stationId = COALESCE(?, tl.destination) "
                + "LEFT JOIN Stop stop2 ON stop2.stopLine = tl.lineId AND stop2.stopStation = s2.stationId "
                + "WHERE tl.lineId = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            if (originStationId == null) {
                ps.setNull(1, java.sql.Types.INTEGER);
            } else {
                ps.setInt(1, originStationId);
            }
            if (destinationStationId == null) {
                ps.setNull(2, java.sql.Types.INTEGER);
            } else {
                ps.setInt(2, destinationStationId);
            }
            ps.setInt(3, lineId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                LineSchedule sched = fromRow(rs);
                fillStops(conn, sched);
                return sched;
            }
        }
    }

    public Map<Integer, LineSchedule> search(Connection conn, int originStationId, int destinationStationId,
            LocalDate reservationDate) throws SQLException {
        String query = "SELECT tl.lineId AS LineId, tl.lineName AS LineName, tl.trainId AS TrainId, "
                + "s1.stationId AS OriginStationId, s1.name AS OriginStationName, s1.city AS OriginCity, s1.state AS OriginState, "
                + "stop1.departureDateTime AS DepartureDateTime, "
                + "s2.stationId AS DestinationStationId, s2.name AS DestinationStationName, s2.city AS DestinationCity, s2.state AS DestinationState, "
                + "stop2.arrivalDateTime AS ArrivalDateTime, tl.fare AS Fare "
                + "FROM Station s1 "
                + "JOIN Stop stop1 ON s1.stationId = stop1.stopStation "
                + "JOIN TransitLine tl ON stop1.stopLine = tl.lineId "
                + "JOIN Stop stop2 ON tl.lineId = stop2.stopLine "
                + "JOIN Station s2 ON stop2.stopStation = s2.stationId "
                + "WHERE s1.stationId = ? AND s2.stationId = ? "
                + "AND stop1.departureDateTime >= ? AND stop1.departureDateTime < ? "
                + "AND stop1.departureDateTime < stop2.arrivalDateTime";
        Map<Integer, LineSchedule> schedules = new LinkedHashMap<>();
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setInt(1, originStationId);
            ps.setInt(2, destinationStationId);
            ps.setDate(3, Date.valueOf(reservationDate));
            ps.setDate(4, Date.valueOf(reservationDate.plusDays(1)));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LineSchedule sched = fromRow(rs);
                    schedules.put(sched.getLineId(), sched);
                }
            }
        }
        fillStops(conn, schedules);
        return schedules;
    }

    private static LineSchedule fromRow(ResultSet rs) throws SQLException {
        return new LineSchedule(
                rs.getInt("LineId"), rs.getString("LineName"), rs.getInt("TrainId"),
                rs.getInt("OriginStationId"), rs.getString("OriginStationName"), rs.getString("OriginCity"),
                rs.getString("OriginState"), rs.getString("DepartureDateTime"),
                rs.getInt("DestinationStationId"), rs.getString("DestinationStationName"),
                rs.getString("DestinationCity"), rs.getString("DestinationState"),
                rs.getString("ArrivalDateTime"), rs.getFloat("Fare"));
    }

    private static void fillStops(Connection conn, LineSchedule sched) throws SQLException {
        Map<Integer, LineSchedule> one = new LinkedHashMap<>();
        one.put(sched.getLineId(), sched);
        fillStops(conn, one);
    }

    private static void fillStops(Connection conn, Map<Integer, LineSchedule> schedules) throws SQLException {
        if (schedules.isEmpty()) {
            return;
        }
        StringJoiner placeholders = new StringJoiner(",");
        for (int i = 0; i < schedules.size(); i++) {
            placeholders.add("?");
        }
        String query = "SELECT tl.lineId AS LineId, stop.stopId as StopId, s.stationId AS StationId, "
                + "s.name AS StationName, s.city AS StationCity, s.state AS StationState, "
                + "stop.arrivalDateTime AS ArrivalDateTime, stop.departureDateTime AS DepartureDateTime "
                + "FROM TransitLine tl "
                + "JOIN Stop stop ON tl.lineId = stop.stopLine "
                + "JOIN Station s ON stop.stopStation = s.stationId "
                + "WHERE tl.lineId IN (" + placeholders + ") "
                + "ORDER BY DepartureDateTime ASC";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            int i = 1;
            for (Integer lineId : schedules.keySet()) {
                ps.setInt(i++, lineId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LineSchedule sched = schedules.get(rs.getInt("LineId"));
                    if (sched != null) {
                        sched.addStop(rs.getInt("StopId"), rs.getInt("StationId"), rs.getString("StationName"),
                                rs.getString("StationCity"), rs.getString("StationState"),
                                rs.getString("ArrivalDateTime"), rs.getString("DepartureDateTime"));
                    }
                }
            }
        }
    }

    public List<String> distinctLineNames(Connection conn) throws SQLException {
        List<String> names = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement("SELECT DISTINCT lineName FROM TransitLine ORDER BY lineName");
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                names.add(rs.getString("lineName"));
            }
        }
        return names;
    }
}
