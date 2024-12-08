package com.cs336.pkg;

import java.time.*;

public class Reservation {
    
	private int reservationNo;
	private LocalDateTime reservationDateTime;
	private boolean isRoundTrip;
	private int discountRate;

	private int customerId;
	private String customerFirstName;
	private String customerLastName;
	private String customerEmail;

	private int transitLineId;
	private String transitLineName;
	private float transitLineFare;

	private float customerDiscount;
	private float customerFare;

	private int originStopId;
	private Station origin;
	private LocalDateTime originStationArrivalTime;
	private LocalDateTime originStationDepartureTime;
	
	private int destinationStopId;
	private Station destination;
	private LocalDateTime destinationStationArrivalTime;
	private LocalDateTime destinationStationDepartureTime;
	

	// TODO: validate null inputs
	public Reservation(int reservationNo, String reservationDateTime, boolean isRoundTrip, int discountRate, int customerId, String customerFirstName, String customerLastName, String customerEmail, int transitLineId, String transitLineName, float transitLineFare, 
						int reservationOriginStopId, int reservationOriginStationId, String reservationOriginStationName, String reservationOriginCity, String reservationOriginState, String originStationArrivalTime, String originStationDepartureTime,
						int reservationDestinationStopId, int reservationDestinationStationId, String reservationDestinationStationName, String reservationDestinationCity, String reservationDestinationState, String destinationStationArrivalTime, String destinationStationDepartureTime) {
		this.reservationNo = reservationNo;
		this.reservationDateTime = DateTimeConversion.strToDateTime(reservationDateTime);
		this.isRoundTrip = isRoundTrip;
		this.discountRate = discountRate;
		
		this.customerId = customerId;
		this.customerFirstName = customerFirstName;
		this.customerLastName = customerLastName;
		this.customerEmail = customerEmail;
		
		this.transitLineId = transitLineId;
		this.transitLineName = transitLineName;
		this.transitLineFare = transitLineFare;
		
		this.originStopId = reservationOriginStopId;
		this.origin = new Station(reservationOriginStationId, reservationOriginStationName, reservationOriginCity, reservationOriginState);
		this.originStationArrivalTime = originStationArrivalTime == null ? null : DateTimeConversion.strToDateTime(originStationArrivalTime);
		this.originStationDepartureTime = originStationDepartureTime == null ? null : DateTimeConversion.strToDateTime(originStationDepartureTime);
		
		this.destinationStopId = reservationDestinationStopId;
		this.destination = new Station(reservationDestinationStationId, reservationDestinationStationName, reservationDestinationCity, reservationDestinationState);
		this.destinationStationArrivalTime = destinationStationArrivalTime == null ? null : DateTimeConversion.strToDateTime(destinationStationArrivalTime);
		this.destinationStationDepartureTime = destinationStationDepartureTime == null ? null : DateTimeConversion.strToDateTime(destinationStationDepartureTime);
		
		calculateCustomerFareAndDiscount();
	}
	
	private void calculateCustomerFareAndDiscount() {
		int multiplier = isRoundTrip ? 2 : 1;
		
		float fare = transitLineFare * multiplier;
		this.customerDiscount = transitLineFare * discountRate;
		this.customerFare = fare - customerDiscount;
	}

	public int getReservationNo() { return reservationNo; }
	
	public LocalDateTime getReservationDateTime() { return reservationDateTime; }
	
	public String getFormattedReservationDateTime() { return reservationDateTime.format(DateTimeConversion.dateTimeFormatter); }
	
	public boolean isRoundTrip() { return isRoundTrip; }
	
	public int getDiscountRate() { return discountRate; }

	public int getCustomerId() { return customerId; }

	public String getCustomerFirstName() { return customerFirstName; }

	public String getCustomerLastName() { return customerLastName; }

	public String getCustomerEmail() { return customerEmail; }

	public int getTransitLineId() { return transitLineId; }

	public String getTransitLineName() { return transitLineName; }

	public float getTransitLineFare() { return transitLineFare; }
	
	public float getCustomerDiscount() { return customerDiscount; }
	
	public float getCustomerFare() { return customerFare; }
		
	public int getOriginStopId() { return originStopId; }
	
	public Station getOrigin() { return origin; }

	public LocalDateTime getOriginStationArrivalTime() { return originStationArrivalTime; }

	public String getFormattedOriginStationArrivalTime() { return originStationArrivalTime.format(DateTimeConversion.dateTimeFormatter); }

	public LocalDateTime getOriginStationDepartureTime() { return originStationDepartureTime; }

	public String getFormattedOriginStationDepartureTime() { return originStationDepartureTime.format(DateTimeConversion.dateTimeFormatter); }
	
	public int getDestinationStopId() { return destinationStopId; }

	public Station getDestination() { return destination; }

	public LocalDateTime getDestinationStationArrivalTime() { return destinationStationArrivalTime; }

	public String getFormattedDestinationStationArrivalTime() { return destinationStationArrivalTime.format(DateTimeConversion.dateTimeFormatter); }

	public LocalDateTime getDestinationStationDepartureTime() { return destinationStationDepartureTime; }

	public String getFormattedDestinationStationDepartureTime() { return destinationStationDepartureTime.format(DateTimeConversion.dateTimeFormatter); }

	public boolean isPastReservation() {
		LocalDateTime destinationArrival = destinationStationDepartureTime != null ? destinationStationDepartureTime : destinationStationArrivalTime;
		
		return LocalDateTime.now().isAfter(destinationArrival);
	}
	
	public String toString() {
		return "Reservation No: " + reservationNo + "\n" +
				"Reservation Date Time: " + reservationDateTime.format(DateTimeConversion.dateTimeFormatter) + "\n" +
				"Round Trip: " + isRoundTrip + "\n" +
				"Discount Rate: " + discountRate + "\n" +
				"Customer ID: " + customerId + "\n" +
				"Customer First Name: " + customerFirstName + "\n" +
				"Customer Last Name: " + customerLastName + "\n" +
				"Customer Email: " + customerEmail + "\n" +
				"Transit Line ID: " + transitLineId + "\n" +
				"Transit Line Name: " + transitLineName + "\n";
	}
}