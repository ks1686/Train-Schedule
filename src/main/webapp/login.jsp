<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
</head>
<body>
	<%
	    String username = request.getParameter("username");
	    String password = request.getParameter("password");
	
	    if (username != null && password != null) {
	        ApplicationDB appdb = new ApplicationDB();
	        Connection conn = appdb.getConnection();
	        PreparedStatement ps = null;
	        ResultSet rs = null;
	
	        try {
	            String query = "SELECT * FROM trains.customers WHERE username = ? AND password = ?";
	            ps = conn.prepareStatement(query);
	            ps.setString(1, username);
	            ps.setString(2, password);
	            
	            rs = ps.executeQuery();
	
	            if (rs.next()) {
	                session.setAttribute("username", username);
	                response.sendRedirect("welcome.jsp"); 
	            } else {
	                out.println("Invalid login credentials!");
	            }
	        } catch (SQLException e) {
	            e.printStackTrace();
	            out.println("Error occurred while processing your request.");
	        } finally {
	            if (rs != null) rs.close();
	            if (ps != null) ps.close();
	            appdb.closeConnection(conn);
	        }
	    }
	%>
	
	<form method="POST" action="login.jsp">
	    Username: <input type="text" name="username" required /><br>
	    Password: <input type="password" name="password" required /><br>
	    <input type="submit" value="Login" />
	</form>
		
</body>
