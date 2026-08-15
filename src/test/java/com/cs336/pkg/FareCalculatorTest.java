package com.cs336.pkg;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import org.junit.Test;

public class FareCalculatorTest {

    @Test
    public void fullLineEqualsLineFare() {
        LineSchedule sched = sampleLine(80f, 15);
        assertEquals(80.00f, sched.getEstimatedFare(), 0.01f);
    }

    @Test
    public void destBeforeOriginIsRejected() {
        LineSchedule sched = sampleLineFrom(80f, 15, 5, 15);
        assertTrue(sched.getEstimatedFare(0) < 0);
    }

    @Test
    public void chargedAmountAppliesRoundTripAndDiscountOnce() {
        float charged = FareCalculator.chargedAmount(17.14f, true, 50);
        assertEquals(17.14f, charged, 0.01f);
        assertEquals(34.28f, FareCalculator.chargedAmount(17.14f, true, 0), 0.01f);
        assertEquals(17.14f, FareCalculator.chargedAmount(17.14f, false, 0), 0.01f);
    }

    @Test
    public void reservationUsesStoredChargedTotal() {
        Reservation reservation = new Reservation(
                1, "2024-12-09 01:42:15", true, 50,
                1, "Alice", "Green", "alice@example.com",
                49, "NEC", 3818, 17.14f,
                1, 1, "A", "Trenton", "NJ", "2024-12-09 06:11:00", "2024-12-09 06:12:00",
                2, 2, "B", "Hamilton", "NJ", "2024-12-09 06:17:00", "2024-12-09 06:18:00");
        assertEquals(17.14f, reservation.getCustomerFare(), 0.01f);
        assertEquals(34.28f, reservation.getOriginalFare(), 0.02f);
        assertEquals(17.14f, reservation.getCustomerDiscount(), 0.02f);
    }

    private static LineSchedule sampleLine(float fare, int stopCount) {
        return sampleLineFrom(fare, stopCount, 1, stopCount);
    }

    private static LineSchedule sampleLineFrom(float fare, int stopCount, int originId, int destId) {
        LineSchedule sched = new LineSchedule(
                1, "NEC", 3818,
                originId, "Origin", "Trenton", "NJ", "2024-12-01 06:11:00",
                destId, "Dest", "New York", "NY", "2024-12-01 07:50:00",
                fare);
        for (int i = 1; i <= stopCount; i++) {
            String minute = String.format("%02d", 10 + i);
            sched.addStop(i, i, "S" + i, "City", "NJ",
                    "2024-12-01 06:" + minute + ":00",
                    "2024-12-01 06:" + minute + ":30");
        }
        return sched;
    }
}
