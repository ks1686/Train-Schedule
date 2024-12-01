package com.cs336.pkg;

public class Station {
	private int stationId;
	private String name;
	private String city;
	private String state;
	
	public Station (int stationId, String name, String city, String state) {
		this.stationId = stationId;
		this.name = name;
		this.city = city;
		this.state = state;
	}
	
	public int getStationId() { return stationId; }
	
	public String getname() { return name; }
	
	public String getCity() { return city; }
	
	public String getState() { return state; }
	
	public String toString() { return name + " - " + city + ", " + state; }
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + stationId;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((city == null) ? 0 : city.hashCode());
		result = prime * result + ((state == null) ? 0 : state.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Station other = (Station) obj;
		if (stationId != other.stationId)
			return false;
		if (name == null) {
			if (other.name != null)
				return false;
		} else if (!name.equals(other.name))
			return false;
		if (city == null) {
			if (other.city != null)
				return false;
		} else if (!city.equals(other.city))
			return false;
		if (state == null) {
			if (other.state != null)
				return false;
		} else if (!state.equals(other.state))
			return false;
		return true;
	}
}