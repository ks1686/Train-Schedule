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
	private int trainId;
	private float transitLineFare;

	private float originalFare;
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
	public Reservation(int reservationNo, String reservationDateTime, boolean isRoundTrip, int discountRate, int customerId, String customerFirstName, String customerLastName, String customerEmail, int transitLineId, String transitLineName, int trainId, float transitLineFare, 
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
		this.trainId = trainId;
		this.customerFare = transitLineFare;
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
		// totalFare is the charged amount already. Recover display fields from it.
		float remainingRate = 1f - (discountRate / 100f);
		if (remainingRate <= 0f) {
			this.originalFare = customerFare;
			this.customerDiscount = 0f;
			return;
		}
		this.originalFare = customerFare / remainingRate;
		this.customerDiscount = originalFare - customerFare;
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

	public int getTrainId() { return trainId; }
	
	public float getTransitLineFare() { return transitLineFare; }

	public float getOriginalFare() { return originalFare; }
	
	public float getCustomerDiscount() { return customerDiscount; }
	
	public float getCustomerFare() { return customerFare; }
		
	public int getOriginStopId() { return originStopId; }
	
	public Station getOrigin() { return origin; }

	public LocalDateTime getOriginStationArrivalTime() { return originStationArrivalTime; }

	public String getFormattedOriginStationArrivalTime() { return formatTime(originStationArrivalTime); }

	public LocalDateTime getOriginStationDepartureTime() { return originStationDepartureTime; }

	public String getFormattedOriginStationDepartureTime() { return formatTime(originStationDepartureTime); }
	
	public int getDestinationStopId() { return destinationStopId; }

	public Station getDestination() { return destination; }

	public LocalDateTime getDestinationStationArrivalTime() { return destinationStationArrivalTime; }

	public String getFormattedDestinationStationArrivalTime() { return formatTime(destinationStationArrivalTime); }

	public LocalDateTime getDestinationStationDepartureTime() { return destinationStationDepartureTime; }

	public String getFormattedDestinationStationDepartureTime() { return formatTime(destinationStationDepartureTime); }

	public boolean isPastReservation() {
		LocalDateTime destinationArrival = destinationStationDepartureTime != null ? destinationStationDepartureTime : destinationStationArrivalTime;
		if (destinationArrival == null) {
			return false;
		}
		return LocalDateTime.now().isAfter(destinationArrival);
	}

	private static String formatTime(LocalDateTime value) {
		return value == null ? "" : value.format(DateTimeConversion.dateTimeFormatter);
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
				"Transit Line Name: " + transitLineName + "\n" + 
				"Transit Line Fare: " + transitLineFare + "\n" + 
				"Total Original Fare: " + originalFare + "\n" + 
				"Customer Discount: " + customerDiscount + "\n" + 
				"Customer Fare: " + customerFare + "\n";
	}
}