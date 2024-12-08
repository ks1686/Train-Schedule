package com.cs336.pkg;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Conversion of MySQL DB DateTime in format `yyyy-MM-dd HH:mm:ss.ns` to Java LocalDateTime.
 */
public class DateTimeConversion {
    public static final DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("EEE, MMM d, yyyy, h:mm a");
    
	public static LocalDateTime strToDateTime(String str) {
		String[] date_time = str.split("\\s+");
		
        if (date_time.length != 2) {
            throw new IllegalArgumentException("Invalid date-time format");
        }
        
		LocalDate date = strToDate(date_time[0]);
		LocalTime time = strToTime(date_time[1]);
		
		return LocalDateTime.of(date, time);
	}
	
	public static LocalDate strToDate(String str) {
		String[] yyyy_MM_dd = str.split("-");
		
        if (yyyy_MM_dd.length != 3) {
            throw new IllegalArgumentException("Invalid date format");
        }
        
		int year = Integer.valueOf(yyyy_MM_dd[0]);
		int month = Integer.valueOf(yyyy_MM_dd[1]);
		int day = Integer.valueOf(yyyy_MM_dd[2]);
		
		return LocalDate.of(year, month, day);
	}
	
	public static LocalTime strToTime(String str) {
		String[] HH_mm_ssns = str.split(":");
		
        if (HH_mm_ssns.length != 3) {
            throw new IllegalArgumentException("Invalid time format");
        }
		
		int hour = Integer.valueOf(HH_mm_ssns[0]);
		int minute = Integer.valueOf(HH_mm_ssns[1]);
		
		String[] ss_ns = HH_mm_ssns[2].split("\\.");
		
		int second = Integer.valueOf(ss_ns[0]);
		int nano = Integer.valueOf(ss_ns[1]) * (int) 1e9;
		
		return LocalTime.of(hour, minute, second, nano);
	}
}