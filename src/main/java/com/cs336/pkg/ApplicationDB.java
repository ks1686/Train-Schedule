package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ApplicationDB {

	// Database connection parameters
	private static final String DB_URL = "jdbc:mysql://localhost:3306/trains"; // change the port number if necessary
	private static final String DB_USER = "root"; // set your MySQL username here
	private static final String DB_PASSWORD = ""; // set your MySQL password here
	private static final Logger LOGGER = Logger.getLogger(ApplicationDB.class.getName());
	
	// Constructor
	public ApplicationDB(){
	}

	// Connect to the database
	public Connection getConnection(){
		//Create a connection string
		Connection connection = null;
		
		try {
			//Load JDBC driver - the interface standardizing the connection procedure. Look at WEB-INF\lib for a mysql connector jar file, otherwise it fails.
			Class.forName("com.mysql.jdbc.Driver").newInstance();
		} catch (InstantiationException | IllegalAccessException | ClassNotFoundException e) {
			LOGGER.log(Level.SEVERE, "Error loading MySQL driver", e);
		}
		try {
			//Create a connection to your DB
			connection = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
		} catch (SQLException e) {
			LOGGER.log(Level.SEVERE, "Error connecting to database", e);
		}
		
		return connection;
	}
	
	// Close the database connection
	public void closeConnection(Connection connection){
		try {
			connection.close();
		} catch (SQLException e) {
			LOGGER.log(Level.SEVERE, "Error closing database connection", e);
		}
	}
	
	// Test the database connection
	public static void main(String[] args) {
		ApplicationDB dao = new ApplicationDB();
		Connection connection = dao.getConnection();
		
		System.out.println(connection);		
		dao.closeConnection(connection);
	}
}
