package com.cs336.pkg;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Runs the DAOs against an in-memory H2 database (MySQL mode) loaded from
 * tests/sql/schema.sql and tests/sql/table_data.sql.
 */
public class DaoTest {
    private static final Pattern DOUBLE_QUOTED = Pattern.compile("\"([^\"]*)\"");
    private static int dbCounter;

    private Connection conn;

    @Before
    public void loadSeedData() throws Exception {
        conn = DriverManager.getConnection("jdbc:h2:mem:trains" + (dbCounter++)
                + ";MODE=MySQL;DATABASE_TO_LOWER=TRUE;CASE_INSENSITIVE_IDENTIFIERS=TRUE");
        try (Statement st = conn.createStatement()) {
            for (String file : new String[] {"tests/sql/schema.sql", "tests/sql/table_data.sql"}) {
                String sql = new String(Files.readAllBytes(Paths.get(file)), StandardCharsets.UTF_8);
                for (String part : sql.split(";\\s*\\n")) {
                    String trimmed = part.trim();
                    if (trimmed.isEmpty() || trimmed.startsWith("CREATE DATABASE") || trimmed.startsWith("USE ")) {
                        continue;
                    }
                    st.execute(toSingleQuotes(part));
                }
            }
        }
    }

    @After
    public void close() throws SQLException {
        conn.close();
    }

    /** The seed data uses MySQL's double-quoted string literals, which H2 reads as identifiers. */
    static String toSingleQuotes(String sql) {
        StringBuffer out = new StringBuffer();
        Matcher m = DOUBLE_QUOTED.matcher(sql);
        while (m.find()) {
            m.appendReplacement(out, Matcher.quoteReplacement("'" + m.group(1).replace("'", "''") + "'"));
        }
        m.appendTail(out);
        return out.toString();
    }

    @Test
    public void deleteOwnedOnlyRemovesTheCallersReservation() throws SQLException {
        ReservationDao dao = new ReservationDao();
        int before = dao.listForUsername(conn, "aliceg").size();
        assertTrue(before > 0);
        int reservationNo = firstReservationNo("aliceg");

        assertEquals(0, dao.deleteOwned(conn, reservationNo, "bobw"));
        assertEquals(before, dao.listForUsername(conn, "aliceg").size());

        assertEquals(1, dao.deleteOwned(conn, reservationNo, "aliceg"));
        assertEquals(before - 1, dao.listForUsername(conn, "aliceg").size());
    }

    @Test
    public void listForUsernameTreatsInputAsData() throws SQLException {
        assertTrue(new ReservationDao().listForUsername(conn, "x' OR '1'='1").isEmpty());
    }

    @Test
    public void findIdByNameTreatsInputAsData() throws SQLException {
        StationDao dao = new StationDao();
        assertEquals(Integer.valueOf(1), dao.findIdByName(conn, "Trenton Transit Center"));
        assertNull(dao.findIdByName(conn, "x' OR '1'='1"));
    }

    @Test
    public void searchFindsLineInTravelDirectionOnly() throws SQLException {
        ScheduleDao dao = new ScheduleDao();
        LocalDate day = firstDepartureDateOfLine1();

        Map<Integer, LineSchedule> forward = dao.search(conn, 1, 14, day);
        LineSchedule line1 = forward.get(1);
        assertNotNull(line1);
        assertFalse(line1.getStops().isEmpty());

        assertFalse(dao.search(conn, 14, 1, day).containsKey(1));
        assertTrue(dao.search(conn, 1, 14, day.plusDays(1)).get(1) == null);
    }

    @Test
    public void reservationInsertIsTiedToTheCustomer() throws SQLException {
        ScheduleDao schedules = new ScheduleDao();
        ReservationDao reservations = new ReservationDao();
        LineSchedule sched = schedules.loadLine(conn, 1, 1, 14);
        assertNotNull(sched);
        int before = reservations.listForUsername(conn, "bobw").size();

        assertEquals(1, reservations.insert(conn, "bobw", sched, false, 0));
        assertEquals(before + 1, reservations.listForUsername(conn, "bobw").size());
    }

    /** Seed dates move whenever tests/buildMockTransit.py is re-run, so read them from the data. */
    private LocalDate firstDepartureDateOfLine1() throws SQLException {
        try (Statement st = conn.createStatement();
                java.sql.ResultSet rs = st.executeQuery("SELECT MIN(departureDateTime) FROM Stop WHERE stopLine = 1")) {
            rs.next();
            return rs.getTimestamp(1).toLocalDateTime().toLocalDate();
        }
    }

    private int firstReservationNo(String username) throws SQLException {
        try (java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT MIN(r.reservationNo) FROM Reservation r JOIN Customer c ON r.customerId = c.customerId "
                        + "WHERE c.username = ?")) {
            ps.setString(1, username);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1);
            }
        }
    }
}
