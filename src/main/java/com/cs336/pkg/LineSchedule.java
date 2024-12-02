package com.cs336.pkg;

public class LineSchedule {
	private String lineName;
	
	private Station origin;
	private String departureDateTime;
	
	private Station destination;
	private String arrivalDateTime;
	
	private int lineFare;
	
	public LineSchedule(String lineName, int originStationId, String originStationName, String originCity, String originState, String departureDateTime,
			int destinationStationId, String destinationStationName, String destinationCity, String destinationState, String arrivalDateTime, int lineFare) {
		this.lineName = lineName;
		this.origin = new Station(originStationId, originStationName, originCity, originState);
		this.departureDateTime = departureDateTime;
		this.destination = new Station(destinationStationId, destinationStationName, destinationCity, destinationState);
		this.arrivalDateTime = arrivalDateTime;
		this.lineFare = lineFare;
	}
	
	public void addStopList() {
		// implement
	}
	
	public String getLineName() { return lineName; }
	
	public String getOrigin() { return origin.toString(); }

	public String getDepartureDateTime() { return departureDateTime; }

	public String getDestination() { return destination.toString(); }

	public String getArrivalDateTime() { return arrivalDateTime; }
	
	public int getLineFare() { return lineFare; }	
}