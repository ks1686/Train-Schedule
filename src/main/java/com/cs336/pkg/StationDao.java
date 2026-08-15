package com.cs336.pkg;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class StationDao {
    public List<Station> listDistinctStopStations(Connection conn) throws SQLException {
        String query = "SELECT DISTINCT s.stationId, s.name, s.city, s.state "
                + "FROM Stop JOIN Station s ON Stop.stopStation = s.stationId "
                + "ORDER BY s.name";
        List<Station> stations = new ArrayList<>();
        try (PreparedStatement ps = conn.prepareStatement(query); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                stations.add(new Station(rs.getInt("stationId"), rs.getString("name"),
                        rs.getString("city"), rs.getString("state")));
            }
        }
        return stations;
    }

    public Integer findIdByName(Connection conn, String name) throws SQLException {
        String query = "SELECT stationId FROM Station WHERE name = ?";
        try (PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, name);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("stationId") : null;
            }
        }
    }
}
