package com.cs336.pkg;

import java.util.*;
import java.time.*;
import java.time.format.DateTimeFormatter;

public class LineSchedule {
    private final DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("EEE, MMM d, yyyy, h:mm a");
    
	private int lineId;
	private String lineName;
	
	private Station origin;
	private LocalDateTime departureDateTime;
	private int originIndex;
	
	private Station destination;
	private LocalDateTime arrivalDateTime;
	private int destinationIndex;
	
	private float lineFare;
	
	private List<Object[]> stops;
	
	public LineSchedule(int lineId, String lineName, int originStationId, String originStationName, String originCity, String originState, String departureDateTime,
			int destinationStationId, String destinationStationName, String destinationCity, String destinationState, String arrivalDateTime, float lineFare) {
		this.lineId = lineId;
		this.lineName = lineName;
		
		this.origin = new Station(originStationId, originStationName, originCity, originState);
		this.departureDateTime = strToDateTime(departureDateTime);
		this.originIndex = -1;
		
		this.destination = new Station(destinationStationId, destinationStationName, destinationCity, destinationState);
		this.arrivalDateTime = strToDateTime(arrivalDateTime);
		this.destinationIndex = -1;
		
		this.lineFare = lineFare;
		this.stops = new ArrayList<>();
	}
	
	public void addStop(int stationId, String stationName, String stationCity, String stationState, String arrivalDateTime, String departureDateTime) {
		Station station = new Station(stationId, stationName, stationCity, stationState);
		Object[] stop = new Object[] 
				{station, 
				strToDateTime(arrivalDateTime).format(dateTimeFormatter), 
				strToDateTime(departureDateTime).format(dateTimeFormatter), 
				"black", 
				false}; // stop[3] = css color, stop[4] = html bolding
		
		if (stationId == origin.getStationId()) {
			stop[3] = "orange";
			stop[4] = true;
			originIndex = stops.size();
		} else if (stationId == destination.getStationId()) {
			stop[3] = "green";
			stop[4] = true;
			destinationIndex = stops.size();
		}
			
		stops.add(stop);
	}

	public int getLineId() { return lineId; }
	
	public String getLineName() { return lineName; }
	
	public String getOrigin() { return origin.toString(); }

	public LocalDateTime getDepartureDateTime() { return departureDateTime; }
	
	public String getFormattedDepartureDateTime() { return departureDateTime.format(dateTimeFormatter); }
	
	public int getOriginIndex() { return originIndex; }

	public String getDestination() { return destination.toString(); }

	public LocalDateTime getArrivalDateTime() { return arrivalDateTime; }
	
	public String getFormattedArrivalDateTime() { return arrivalDateTime.format(dateTimeFormatter); }
	
	public int getDestinationIndex() { return destinationIndex; }
	
	public float getLineFare() { return lineFare; }	
	
	public float getEstimatedFare(int index) {
		float pricePerStop = lineFare/(stops.size() - 1);
		int traveledStops = index - getOriginIndex();
		if (traveledStops < 0) return -1;
		
		return pricePerStop * traveledStops;
	}
	
	public float getEstimatedFare() {
		return getEstimatedFare(getDestinationIndex());
	}
	
	public List<Object[]> getStops() { return stops; }
	
	private LocalDateTime strToDateTime(String str) {
		String[] date_time = str.split("\\s+");
		
		LocalDate date = strToDate(date_time[0]);
		LocalTime time = strToTime(date_time[1]);
		
		return LocalDateTime.of(date, time);
	}
	
	private LocalDate strToDate(String str) {
		String[] yyyy_MM_dd = str.split("-");
		
		int year = Integer.valueOf(yyyy_MM_dd[0]);
		int month = Integer.valueOf(yyyy_MM_dd[1]);
		int day = Integer.valueOf(yyyy_MM_dd[2]);
		
		return LocalDate.of(year, month, day);
	}
	
	private LocalTime strToTime(String str) {
		String[] HH_mm_ssns = str.split(":");
		
		int hour = Integer.valueOf(HH_mm_ssns[0]);
		int minute = Integer.valueOf(HH_mm_ssns[1]);
		
		String[] ss_ns = HH_mm_ssns[2].split("\\.");
		
		int second = Integer.valueOf(ss_ns[0]);
		int nano = Integer.valueOf(ss_ns[1]) * (int) 1e9;
		
		return LocalTime.of(hour, minute, second, nano);
	}
}