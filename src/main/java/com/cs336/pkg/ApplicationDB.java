package com.cs336.pkg;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ApplicationDB {

	private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/trains";
	private static final String DEFAULT_USER = "root";
	private static final String DEFAULT_PASSWORD = "";
	private static final Logger LOGGER = Logger.getLogger(ApplicationDB.class.getName());

	public ApplicationDB(){
	}

	public Connection getConnection(){
		String url = envOr("DB_URL", DEFAULT_URL);
		String user = envOr("DB_USER", DEFAULT_USER);
		String password = envOr("DB_PASSWORD", DEFAULT_PASSWORD);

		try {
			Class.forName("com.mysql.cj.jdbc.Driver");
		} catch (ClassNotFoundException e) {
			LOGGER.log(Level.SEVERE, "Error loading MySQL driver", e);
			throw new IllegalStateException("MySQL driver not found", e);
		}

		try {
			return DriverManager.getConnection(url, user, password);
		} catch (SQLException e) {
			LOGGER.log(Level.SEVERE, "Error connecting to database", e);
			throw new IllegalStateException("Unable to connect to database", e);
		}
	}

	public void closeConnection(Connection connection){
		if (connection == null) {
			return;
		}
		try {
			connection.close();
		} catch (SQLException e) {
			LOGGER.log(Level.SEVERE, "Error closing database connection", e);
		}
	}

	private static String envOr(String name, String fallback) {
		String value = System.getenv(name);
		return value == null || value.isEmpty() ? fallback : value;
	}

	public static void main(String[] args) {
		ApplicationDB dao = new ApplicationDB();
		Connection connection = dao.getConnection();
		System.out.println(connection);
		dao.closeConnection(connection);
	}
}
