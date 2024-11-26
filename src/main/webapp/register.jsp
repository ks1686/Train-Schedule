<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
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

        .register-container {
            width: 300px;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2);
            border-radius: 8px;
            text-align: center;
        }

        .register-container h1 {
            font-size: 24px;
            color: #333;
            margin-bottom: 20px;
        }

        .register-container input[type="text"],
        .register-container input[type="password"],
        .register-container input[type="email"] {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .register-container input[type="submit"] {
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

        .register-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .error-message, .success-message {
            color: red;
            font-size: 14px;
            margin-bottom: 10px;
        }

        .success-message {
            color: green;
        }

        .register-container a {
            display: inline-block;
            margin-top: 10px;
            color: #4CAF50;
            text-decoration: none;
            font-size: 16px;
        }

        .register-container a:hover {
            color: #45a049;
        }
    </style>
</head>
<body>
    <div class="register-container">
        <h1>Register</h1>

        <% 
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String errorMessage = null;
            String successMessage = null;

            if (username != null && password != null && firstName != null && lastName != null && email != null) {
                if (username.length() > 10) {
                    errorMessage = "Username must be 10 characters or fewer.";
                } else if (firstName.length() > 25) {
                    errorMessage = "First name must be 25 characters or fewer.";
                } else if (lastName.length() > 25) {
                    errorMessage = "Last name must be 25 characters or fewer.";
                } else if (password.length() > 50) {
                    errorMessage = "Password must be 50 characters or fewer.";
                } else if (email.length() > 100) {
                    errorMessage = "Email must be 100 characters or fewer.";
                } else {
                    Connection conn = null;
                    PreparedStatement ps = null;
                    ResultSet rs = null;

                    try {
                        ApplicationDB appdb = new ApplicationDB();
                        conn = appdb.getConnection();

                        String checkQuery = "SELECT * FROM Customer WHERE username = ? OR email = ?";
                        ps = conn.prepareStatement(checkQuery);
                        ps.setString(1, username);
                        ps.setString(2, email);
                        rs = ps.executeQuery();

                        if (rs.next()) {
                            errorMessage = "Username or email already exists!";
                        } else {
                            String insertQuery = "INSERT INTO Customer (username, password, firstName, lastName, email) VALUES (?, ?, ?, ?, ?)";
                            ps = conn.prepareStatement(insertQuery);
                            ps.setString(1, username);
                            ps.setString(2, password);
                            ps.setString(3, firstName);
                            ps.setString(4, lastName);
                            ps.setString(5, email);

                            int rowsAffected = ps.executeUpdate();

                            if (rowsAffected > 0) {
                                successMessage = "Account created successfully! You can now log in.";
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                        errorMessage = "Error occurred while processing your request.";
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) {}
                        if (ps != null) try { ps.close(); } catch (SQLException e) {}
                        if (conn != null) try { conn.close(); } catch (SQLException e) {}
                    }
                }
            }
        %>

        <% if (errorMessage != null) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>

        <% if (successMessage != null) { %>
            <div class="success-message"><%= successMessage %></div>
        <% } %>

        <form method="POST" action="register.jsp">
            <input type="text" name="firstName" placeholder="First Name" required /><br>
            <input type="text" name="lastName" placeholder="Last Name" required /><br>
            <input type="text" name="username" placeholder="Username" required /><br>
            <input type="password" name="password" placeholder="Password" required /><br>
            <input type="email" name="email" placeholder="Email" required /><br>
            <input type="submit" value="Register" />
        </form>

        <a href="login.jsp">Go back to Login</a>
    </div>
</body>
</html>