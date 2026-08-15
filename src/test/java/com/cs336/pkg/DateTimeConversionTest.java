package com.cs336.pkg;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import java.sql.Timestamp;
import java.time.LocalDateTime;

import org.junit.Test;

public class DateTimeConversionTest {

    @Test
    public void parsesMysqlDatetimeWithoutFraction() {
        LocalDateTime got = DateTimeConversion.strToDateTime("2024-12-01 06:11:00");
        assertEquals(LocalDateTime.of(2024, 12, 1, 6, 11, 0), got);
    }

    @Test
    public void parsesMysqlDatetimeWithMillis() {
        LocalDateTime got = DateTimeConversion.strToDateTime("2024-12-01 06:11:00.500");
        assertEquals(LocalDateTime.of(2024, 12, 1, 6, 11, 0, 500_000_000), got);
    }

    @Test
    public void parsesDatetimeLocal() {
        LocalDateTime got = DateTimeConversion.strToDateTime("2024-12-01T06:11");
        assertEquals(LocalDateTime.of(2024, 12, 1, 6, 11), got);
    }

    @Test
    public void fromTimestampNullIsNull() {
        assertNull(DateTimeConversion.fromTimestamp(null));
    }

    @Test
    public void fromTimestampConverts() {
        Timestamp ts = Timestamp.valueOf("2024-12-01 06:11:00");
        assertEquals(LocalDateTime.of(2024, 12, 1, 6, 11, 0), DateTimeConversion.fromTimestamp(ts));
    }

    @Test
    public void rejectsBlank() {
        try {
            DateTimeConversion.strToDateTime("  ");
            fail("expected IllegalArgumentException");
        } catch (IllegalArgumentException expected) {
            // ok
        }
    }
}
