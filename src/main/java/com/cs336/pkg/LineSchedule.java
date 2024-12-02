package com.cs336.pkg;

import java.util.*;

public class LineSchedule {
	private int lineId;
	private String lineName;
	
	private Station origin;
	private String departureDateTime;
	private int originIndex;
	
	private Station destination;
	private String arrivalDateTime;
	private int destinationIndex;
	
	private float lineFare;
	
	private List<Object[]> stops;
	
	public LineSchedule(int lineId, String lineName, int originStationId, String originStationName, String originCity, String originState, String departureDateTime,
			int destinationStationId, String destinationStationName, String destinationCity, String destinationState, String arrivalDateTime, float lineFare) {
		this.lineId = lineId;
		this.lineName = lineName;
		this.origin = new Station(originStationId, originStationName, originCity, originState);
		this.departureDateTime = departureDateTime;
		this.originIndex = -1;
		this.destination = new Station(destinationStationId, destinationStationName, destinationCity, destinationState);
		this.arrivalDateTime = arrivalDateTime;
		this.destinationIndex = -1;
		this.lineFare = lineFare;
		this.stops = new ArrayList<>();
	}
	
	public void addStop(int stationId, String stationName, String stationCity, String stationState, String arrivalDateTime, String departureDateTime) {
		Station station = new Station(stationId, stationName, stationCity, stationState);
		Object[] stop = new Object[] {station, arrivalDateTime, departureDateTime, "black", false}; // stop[3] = css color, stop[4] = html bolding
		
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

	public String getDepartureDateTime() { return departureDateTime; }
	
	public int getOriginIndex() { return originIndex; }

	public String getDestination() { return destination.toString(); }

	public String getArrivalDateTime() { return arrivalDateTime; }
	
	public int getDestinationIndex() { return destinationIndex; }
	
	public float getLineFare() { return lineFare; }	
	
	public float getEstimatedFare(int index) {
		float pricePerStop = lineFare/(stops.size() - 1);
		int traveledStops = index - getOriginIndex();
		if (traveledStops <= 0) return -1;
		
		return pricePerStop * traveledStops;
	}
	
	public float getEstimatedFare() {
		return getEstimatedFare(getDestinationIndex());
	}
	
	public List<Object[]> getStops() { return stops; }
}