<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f9;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .login-container {
            width: 300px;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            border-radius: 8px;
            text-align: center;
        }

        .login-container h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
        }

        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .login-container input[type="submit"] {
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            background-color: #4CAF50;
            border: none;
            color: white;
            font-size: 16px;
            border-radius: 4px;
            cursor: pointer;
        }

        .login-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .error-message {
            color: red;
            font-size: 14px;
            margin-bottom: 10px;
        }

        .logout-message {
            color: green;
            font-size: 14px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <h1>Login</h1>

        <%
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String errorMessage = null;

            // Check for a logout success parameter
            String logout = request.getParameter("logout");
            if ("true".equals(logout)) {
        %>
            <div class="logout-message">You have been successfully logged out.</div>
        <%
            }

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
                        errorMessage = "Invalid login credentials!";
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                    errorMessage = "Error occurred while processing your request.";
                } finally {
                    if (rs != null) rs.close();
                    if (ps != null) ps.close();
                    if (conn != null) appdb.closeConnection(conn);  // Added null check for conn
                }
            }
        %>

        <% if (errorMessage != null) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>

        <form method="POST" action="login.jsp">
            <input type="text" name="username" placeholder="Username" required /><br>
            <input type="password" name="password" placeholder="Password" required /><br>
            <input type="submit" value="Login" />
        </form>
    </div>
</body>
</html>
