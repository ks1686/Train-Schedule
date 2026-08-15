<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Register</title>
    <link rel="stylesheet" href="css/app.css">
</head>
<body>
    <div class="register-container">
        <h1>Register</h1>

        <%
            session = request.getSession(true);
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String firstName = request.getParameter("firstName");
            String lastName = request.getParameter("lastName");
            String email = request.getParameter("email");
            String errorMessage = null;
            String successMessage = null;

            if ("POST".equalsIgnoreCase(request.getMethod())
                    && username != null && password != null && firstName != null && lastName != null && email != null) {
                if (!Csrf.isValid(request)) {
                    errorMessage = "Invalid request. Please try again.";
                } else if (username.length() > 10) {
                    errorMessage = "Username must be 10 characters or fewer.";
                } else if (firstName.length() > 25) {
                    errorMessage = "First name must be 25 characters or fewer.";
                } else if (lastName.length() > 25) {
                    errorMessage = "Last name must be 25 characters or fewer.";
                } else if (password.length() > 72) {
                    errorMessage = "Password must be 72 characters or fewer.";
                } else if (email.length() > 100) {
                    errorMessage = "Email must be 100 characters or fewer.";
                } else {
                    ApplicationDB appdb = new ApplicationDB();
                    Connection conn = null;
                    PreparedStatement checkPs = null;
                    PreparedStatement insertPs = null;
                    ResultSet rs = null;

                    try {
                        conn = appdb.getConnection();

                        checkPs = conn.prepareStatement("SELECT username FROM Customer WHERE username = ?");
                        checkPs.setString(1, username);
                        rs = checkPs.executeQuery();

                        if (rs.next()) {
                            errorMessage = "Username or email already exists!";
                        } else {
                            rs.close();
                            rs = null;
                            checkPs.close();
                            checkPs = null;

                            insertPs = conn.prepareStatement(
                                    "INSERT INTO Customer (username, password, firstName, lastName, email) VALUES (?, ?, ?, ?, ?)");
                            insertPs.setString(1, username);
                            insertPs.setString(2, Passwords.hash(password));
                            insertPs.setString(3, firstName);
                            insertPs.setString(4, lastName);
                            insertPs.setString(5, email);

                            int rowsAffected = insertPs.executeUpdate();
                            if (rowsAffected > 0) {
                                successMessage = "Account created successfully! You can now log in.";
                            }
                        }
                    } catch (SQLException e) {
                        e.printStackTrace();
                        if (e.getErrorCode() == 1062) {
                            errorMessage = "Username or email already exists!";
                        } else {
                            errorMessage = "Error occurred while processing your request.";
                        }
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                        if (checkPs != null) try { checkPs.close(); } catch (SQLException ignored) {}
                        if (insertPs != null) try { insertPs.close(); } catch (SQLException ignored) {}
                        appdb.closeConnection(conn);
                    }
                }
            }
        %>

        <% if (errorMessage != null) { %>
            <div class="error-message"><%= Html.escape(errorMessage) %></div>
        <% } %>

        <% if (successMessage != null) { %>
            <div class="success-message"><%= Html.escape(successMessage) %></div>
        <% } %>

        <form method="POST" action="register.jsp">
            <%= Csrf.hiddenField(session) %>
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