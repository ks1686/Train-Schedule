<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Login</title>
    <link rel="stylesheet" href="css/app.css">
</head>
<body>
    <div class="login-container">
        <h1>Login</h1>

        <%
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String errorMessage = null;
            String logout = request.getParameter("logout");

            if ("true".equals(logout)) {
        %>
            <div class="logout-message">You have been successfully logged out.</div>
        <%
            }

            if ("POST".equalsIgnoreCase(request.getMethod()) && username != null && password != null) {
                ApplicationDB appdb = new ApplicationDB();
                Connection conn = null;
                PreparedStatement ps = null;
                ResultSet rs = null;

                try {
                    conn = appdb.getConnection();

                    String query = "SELECT username, password FROM Customer WHERE BINARY username = ?";
                    ps = conn.prepareStatement(query);
                    ps.setString(1, username);
                    rs = ps.executeQuery();
                    if (rs.next() && Passwords.matches(password, rs.getString("password"))) {
                        String stored = rs.getString("password");
                        rs.close();
                        rs = null;
                        ps.close();
                        ps = null;
                        if (Passwords.needsUpgrade(stored)) {
                            ps = conn.prepareStatement("UPDATE Customer SET password = ? WHERE BINARY username = ?");
                            ps.setString(1, Passwords.hash(password));
                            ps.setString(2, username);
                            ps.executeUpdate();
                            ps.close();
                            ps = null;
                        }
                        Auth.establish(request, username, Roles.CUSTOMER);
                        response.sendRedirect("Customer/customerWelcome.jsp");
                        return;
                    }
                    if (rs != null) { rs.close(); rs = null; }
                    if (ps != null) { ps.close(); ps = null; }

                    query = "SELECT username, password FROM Employee WHERE BINARY username = ? AND role = ?";
                    ps = conn.prepareStatement(query);
                    ps.setString(1, username);
                    ps.setString(2, Roles.REPRESENTATIVE);
                    rs = ps.executeQuery();
                    if (rs.next() && Passwords.matches(password, rs.getString("password"))) {
                        String stored = rs.getString("password");
                        rs.close();
                        rs = null;
                        ps.close();
                        ps = null;
                        if (Passwords.needsUpgrade(stored)) {
                            ps = conn.prepareStatement("UPDATE Employee SET password = ? WHERE BINARY username = ?");
                            ps.setString(1, Passwords.hash(password));
                            ps.setString(2, username);
                            ps.executeUpdate();
                            ps.close();
                            ps = null;
                        }
                        Auth.establish(request, username, Roles.REPRESENTATIVE);
                        response.sendRedirect("Representative/repWelcome.jsp");
                        return;
                    }
                    if (rs != null) { rs.close(); rs = null; }
                    if (ps != null) { ps.close(); ps = null; }

                    query = "SELECT username, password FROM Employee WHERE BINARY username = ? AND role = ?";
                    ps = conn.prepareStatement(query);
                    ps.setString(1, username);
                    ps.setString(2, Roles.MANAGER);
                    rs = ps.executeQuery();
                    if (rs.next() && Passwords.matches(password, rs.getString("password"))) {
                        String stored = rs.getString("password");
                        rs.close();
                        rs = null;
                        ps.close();
                        ps = null;
                        if (Passwords.needsUpgrade(stored)) {
                            ps = conn.prepareStatement("UPDATE Employee SET password = ? WHERE BINARY username = ?");
                            ps.setString(1, Passwords.hash(password));
                            ps.setString(2, username);
                            ps.executeUpdate();
                            ps.close();
                            ps = null;
                        }
                        Auth.establish(request, username, Roles.MANAGER);
                        response.sendRedirect("Manager/managerWelcome.jsp");
                        return;
                    }
                    errorMessage = "Invalid login credentials!";
                } catch (SQLException e) {
                    e.printStackTrace();
                    errorMessage = "Error occurred while processing your request.";
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException ignored) {}
                    if (ps != null) try { ps.close(); } catch (SQLException ignored) {}
                    appdb.closeConnection(conn);
                }
            }
        %>

        <% if (errorMessage != null) { %>
            <div class="error-message"><%= Html.escape(errorMessage) %></div>
        <% } %>

        <form method="POST" action="login.jsp">
            <input type="text" name="username" placeholder="Username" required /><br>
            <input type="password" name="password" placeholder="Password" required /><br>
            <input type="submit" value="Login" />
        </form>

        <div class="register-link">
            <p>Don't have an account? <a href="register.jsp">Create one here</a></p>
        </div>
    </div>
</body>
</html>
