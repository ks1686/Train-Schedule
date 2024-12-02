package com.cs336.pkg;

public class LineSchedule {
	private int lineId;
	private String lineName;
	
	private Station origin;
	private String departureDateTime;
	
	private Station destination;
	private String arrivalDateTime;
	
	private float lineFare;
	
	public LineSchedule(int lineId, String lineName, int originStationId, String originStationName, String originCity, String originState, String departureDateTime,
			int destinationStationId, String destinationStationName, String destinationCity, String destinationState, String arrivalDateTime, float lineFare) {
		this.lineId = lineId;
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

	public int getLineId() { return lineId; }
	
	public String getLineName() { return lineName; }
	
	public String getOrigin() { return origin.toString(); }

	public String getDepartureDateTime() { return departureDateTime; }

	public String getDestination() { return destination.toString(); }

	public String getArrivalDateTime() { return arrivalDateTime; }
	
	public float getLineFare() { return lineFare; }	
}