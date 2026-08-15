package com.cs336.pkg;

import java.math.BigDecimal;
import java.math.RoundingMode;

public final class FareCalculator {
    private FareCalculator() {
    }

    public static float chargedAmount(float segmentFare, boolean roundTrip, int discountPercent) {
        if (segmentFare < 0) {
            return -1f;
        }
        int safeDiscount = Math.max(0, Math.min(100, discountPercent));
        BigDecimal segment = BigDecimal.valueOf(segmentFare);
        BigDecimal multiplier = roundTrip ? BigDecimal.valueOf(2) : BigDecimal.ONE;
        BigDecimal rate = BigDecimal.ONE.subtract(BigDecimal.valueOf(safeDiscount).divide(BigDecimal.valueOf(100), 4, RoundingMode.HALF_UP));
        return segment.multiply(multiplier).multiply(rate).setScale(2, RoundingMode.HALF_UP).floatValue();
    }

    public static int discountFor(int age, boolean disabled) {
        if (disabled) {
            return 50;
        }
        if (age >= 65) {
            return 35;
        }
        if (age <= 12) {
            return 25;
        }
        return 0;
    }
}
