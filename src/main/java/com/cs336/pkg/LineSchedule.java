package com.cs336.pkg;

import java.util.*;
import java.time.*;

public class LineSchedule {
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
		this.departureDateTime = DateTimeConversion.strToDateTime(departureDateTime);
		this.originIndex = -1;
		
		this.destination = new Station(destinationStationId, destinationStationName, destinationCity, destinationState);
		this.arrivalDateTime = DateTimeConversion.strToDateTime(arrivalDateTime);
		this.destinationIndex = -1;
		
		this.lineFare = lineFare;
		this.stops = new ArrayList<>();
	}
	
	public void addStop(int stopId, int stationId, String stationName, String stationCity, String stationState, String arrivalDateTime, String departureDateTime) {
		Station station = new Station(stationId, stationName, stationCity, stationState);
		Object[] stop = new Object[] 
				{stopId,
				station, 
				DateTimeConversion.strToDateTime(arrivalDateTime).format(DateTimeConversion.dateTimeFormatter), 
				DateTimeConversion.strToDateTime(departureDateTime).format(DateTimeConversion.dateTimeFormatter), 
				"black", 
				false}; // stop[4] = css color, stop[5] = html bolding
		
		if (stationId == origin.getStationId()) {
			stop[4] = "orange";
			stop[5] = true;
			originIndex = stops.size();
		} else if (stationId == destination.getStationId()) {
			stop[4] = "green";
			stop[5] = true;
			destinationIndex = stops.size();
		}
			
		stops.add(stop);
	}

	public int getLineId() { return lineId; }
	
	public String getLineName() { return lineName; }
	
	public Station getOrigin() { return origin; }

	public LocalDateTime getDepartureDateTime() { return departureDateTime; }
	
	public String getFormattedDepartureDateTime() { return departureDateTime.format(DateTimeConversion.dateTimeFormatter); }
	
	public int getOriginIndex() { return originIndex; }

	public Station getDestination() { return destination; }

	public LocalDateTime getArrivalDateTime() { return arrivalDateTime; }
	
	public String getFormattedArrivalDateTime() { return arrivalDateTime.format(DateTimeConversion.dateTimeFormatter); }
	
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
}