<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*,java.text.SimpleDateFormat,java.util.Date"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Rep Welcome</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f9;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        .header {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header .username {
            color: black;
            font-size: 20px;
            font-weight: bold;
        }

        .main-container {
            display: flex;
            flex-direction: column;
            height: 100%;
            padding: 20px;
            flex-grow: 1;
        }

        .top-half {
            flex: 6;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            overflow-y: visible;
        }

        .bottom-half {
            flex: 4;
            overflow-y: visible;
            margin-top: 20px;
        }

        .search-container input[type="text"] {
            padding: 8px 20px;
            font-size: 16px;
            border: 1px solid #ddd;
            border-radius: 4px;
            width: 260px;
            margin-bottom: 5px;
            box-sizing: border-box;
        }

        .search-container input[type="submit"] {
            padding: 10px 20px;
            font-size: 16px;
            border: none;
            background-color: #4CAF50;
            color: white;
            border-radius: 4px;
            cursor: pointer;
        }

        .search-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .search-section {
            margin-bottom: 15px;
        }

        .form-container {
            margin-top: 20px;
        }

        .form-container input, .form-container textarea {
            width: 100%;
            padding: 10px;
            margin: 8px 0;
            border: 1px solid #ddd;
            border-radius: 4px;
        }

        .question-item, .answer-item {
            background-color: #fff;
            padding: 15px;
            border: 1px solid #ddd;
            margin-bottom: 10px;
            font-size: 16px;
        }

        .answer-item {
            background-color: #e8f5e9;
            padding: 10px;
            margin-top: 10px;
            border-left: 5px solid #4CAF50;
        }

        .logout-button {
            padding: 8px 16px;
            background-color: #f44336;
            color: white;
            font-size: 14px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }

        .logout-button:hover {
            background-color: #d32f2f;
        }

        .answer-container {
            margin-top: 15px;
        }

        .answer-container textarea {
            font-size: 14px;
            border: 1px solid #ccc;
            padding: 10px;
            width: 90%;
            border-radius: 4px;
            box-sizing: border-box;
            height: 100px;
            margin-bottom: 10px;
        }

        .answer-container input[type="submit"] {
            padding: 10px 20px;
            background-color: #4CAF50;
            border: none;
            color: white;
            font-size: 14px;
            cursor: pointer;
            border-radius: 4px;
        }

        .answer-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .reply-section {
            margin-top: 15px;
        }

        .reply-section textarea {
            width: 100%;
            padding: 10px;
            margin-top: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            box-sizing: border-box;
        }

        .reply-section input[type="submit"] {
            margin-top: 10px;
            padding: 10px 20px;
            background-color: #4CAF50;
            color: white;
            font-size: 14px;
            cursor: pointer;
            border-radius: 4px;
            border: none;
        }

        .reply-section input[type="submit"]:hover {
            background-color: #45a049;
        }

        .question-text {
            font-size: 16px;
            margin-bottom: 8px;
        }

        .label-bold {
            font-weight: bold;
        }

        .search-container {
            margin-top: 20px;
        }
        
        .question-item {
            margin-top: 15px;
        }

        .questions-answers-header {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 15px;
        }  
        
        .customer-header {
            font-size: 20px;
            font-weight: bold;
        }  
        
        .s-header {
            font-size: 20px;
            font-weight: bold;
        }  
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table, th, td {
            border: 1px solid #ddd;
        }

        th, td {
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        .edit-button, .delete-button, .save-button, .view-button {
            padding: 6px 12px;
            border: none;
            cursor: pointer;
        }

        .edit-button {
            background-color: #2196F3;
            color: white;
        }

        .delete-button {
            background-color: #f44336;
            color: white;
        }

        .save-button {
            background-color: #4CAF50;
            color: white;
        }
        
        .view-button {
            background-color: #4CAF50;
            color: white;
        }
        
               
    </style>
</head>
<body>

<%
    String username = (String) session.getAttribute("username");
    
    if (session == null || username == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String role = (String) session.getAttribute("role");
    if (!role.equals("Representative")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String errorMessage = null;
    List<String> questions = new ArrayList<>();
    List<String> answers = new ArrayList<>();
    List<String> questionUsernames = new ArrayList<>();
    List<Integer> questionIds = new ArrayList<>();
    String searchUsername = request.getParameter("searchUsername");
    String searchKeyword = request.getParameter("searchKeyword");

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String query = "SELECT q.questionId, q.questionText, a.answerText, c.username FROM Questions q " + 
                       "LEFT JOIN Answers a ON q.questionId = a.questionId " +
                       "JOIN Customer c ON q.customerId = c.customerId";
        if (searchUsername != null && !searchUsername.isEmpty()) {
            query += " WHERE c.username LIKE ?";
        } else if (searchKeyword != null && !searchKeyword.isEmpty()) {
            query += " WHERE q.questionText LIKE ?";
        }

        ps = conn.prepareStatement(query);
        if (searchUsername != null && !searchUsername.isEmpty()) {
            ps.setString(1, "%" + searchUsername + "%");
        } else if (searchKeyword != null && !searchKeyword.isEmpty()) {
            ps.setString(1, "%" + searchKeyword + "%");
        }
        rs = ps.executeQuery();

        while (rs.next()) {
            questionIds.add(rs.getInt("questionId"));
            questions.add(rs.getString("questionText"));
            answers.add(rs.getString("answerText") != null ? rs.getString("answerText") : "");
            questionUsernames.add(rs.getString("username"));
        }

        String replyQuestionId = request.getParameter("replyQuestionId");
        String replyText = request.getParameter("replyText");

        if (replyQuestionId != null && replyText != null && !replyText.isEmpty()) {
            PreparedStatement ps3 = null;
            try {
                String checkQuery = "SELECT answerId FROM Answers WHERE questionId = ? AND employeeSSN = (SELECT ssn FROM Employee WHERE username = ?)";
                ps3 = conn.prepareStatement(checkQuery);
                ps3.setInt(1, Integer.parseInt(replyQuestionId));
                ps3.setString(2, username);
                ResultSet rsCheck = ps3.executeQuery();

                if (rsCheck.next()) {
                    String updateQuery = "UPDATE Answers SET answerText = ? WHERE questionId = ? AND employeeSSN = (SELECT ssn FROM Employee WHERE username = ?)";
                    ps3 = conn.prepareStatement(updateQuery);
                    ps3.setString(1, replyText);
                    ps3.setInt(2, Integer.parseInt(replyQuestionId));
                    ps3.setString(3, username);
                    ps3.executeUpdate();
                } else {
                    String insertReplyQuery = "INSERT INTO Answers (questionId, employeeSSN, answerText) " +
                                              "VALUES (?, (SELECT ssn FROM Employee WHERE username = ?), ?)";
                    ps3 = conn.prepareStatement(insertReplyQuery);
                    ps3.setInt(1, Integer.parseInt(replyQuestionId));
                    ps3.setString(2, username);
                    ps3.setString(3, replyText);
                    ps3.executeUpdate();
                }
                response.sendRedirect("repWelcome.jsp");
            } catch (SQLException e) {
                errorMessage = "Error replying to the question: " + e.getMessage();
            } finally {
                if (ps3 != null) ps3.close();
            }
        }

    } catch (SQLException e) {
        errorMessage = "Error loading questions and answers: " + e.getMessage();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
            if (conn != null) conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
%>

<div class="header">
    <span class="username">Hello, <%= username %></span>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<div class="main-container">
    <div class="top-half">
        <div class="customer-header">
            <p>Customer List By Transit and Reservation Booking Date:</p>
        </div>
		<div class="search-container">
			<form method="GET" action="repWelcome.jsp">
                <label for="lineName">Select Transit Line:</label>
                <select name="lineName" id="lineName" required>
                    <%
                        Connection conn2 = null;
                        PreparedStatement ps2 = null;
                        ResultSet rs2 = null;
                    
                    
                        // Get all transit lines and display them in the dropdown
                        try {
                            ApplicationDB appdb2 = new ApplicationDB();
                            conn2 = appdb2.getConnection();
                            ps2 = conn2.prepareStatement("SELECT DISTINCT lineName FROM TransitLine");
                            rs2 = ps2.executeQuery();
                            
                            while (rs2.next()) {
                                String lineName = rs2.getString("lineName");
                    %>        
                            <option value="<%= lineName %>"><%= lineName %></option>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        } finally {
                            try {
                                if (rs2 != null) rs2.close();
                                if (ps2 != null) ps2.close();
                                if (conn2 != null) conn2.close();
                            } catch (SQLException ex) {
                                ex.printStackTrace();
                            }
                        }
                    %>
                </select>
                <label for="reservationDate">Select Date:</label>
                <input type="date" name="reservationDate" id="reservationDate" required />
                <input type="submit" value="Search" />
            </form>
    	</div>
		<table>
            <thead>
                <tr>
                    <th>Username</th>
                    <th>First Name</th>
                    <th>Last Name</th>
                    <th>Email</th>
                </tr>
            </thead>
            <tbody>
                <%
                
                Connection conn3 = null;
                PreparedStatement ps3 = null;
                ResultSet rs3 = null;
                
                try {
                    ApplicationDB appdb3 = new ApplicationDB();
                    conn3 = appdb3.getConnection();
                    
                    String lineName = request.getParameter("lineName");
                    String date = request.getParameter("reservationDate");
                    
                    String query = "SELECT c.username, c.firstName, c.lastName, c.email " +
                                   "FROM Reservation r " +
                                   "JOIN TransitLine tl ON r.transitLineId = tl.lineId " +
                                   "JOIN Customer c ON r.customerId = c.customerId " +
                                   "WHERE tl.lineName = ? AND DATE(r.reservationDateTime) = ?";
                    
                    ps3 = conn3.prepareStatement(query);
                    ps3.setString(1, lineName);
                    ps3.setString(2, date);

                    rs3 = ps3.executeQuery();

                    while (rs3.next()) {
                        String cUsername = rs3.getString("username");
                        String firstName = rs3.getString("firstName");
                        String lastName = rs3.getString("lastName");
                        String email = rs3.getString("email");
            %>
                        <tr>
                            <td><%= cUsername %></td>
                            <td><%= firstName %></td>
                            <td><%= lastName %></td>
                            <td><%= email %></td>
                        </tr>
            <%
                    }
                } catch (SQLException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (rs3 != null) rs3.close();
                        if (ps3 != null) ps3.close();
                        if (conn3 != null) conn3.close();
                    } catch (SQLException ex) {
                        ex.printStackTrace();
                    }
                }
                %>
            </tbody>
        </table>
        
        <div class="s-header">
            <p>Schedule:</p>
        </div>
        
        <!-- Search Form -->
        <div class="search-container">
            <form method="GET" action="repWelcome.jsp">
                <label for="station">Select Station:</label>
                <select name="station" id="station" required>
                    <%
                        Connection conn1 = null;
                        PreparedStatement ps1 = null;
                        ResultSet rs1 = null;
                    
                    
                        // Get all stations and display them in the dropdown
                        try {
                            ApplicationDB appdb1 = new ApplicationDB();
                            conn1 = appdb1.getConnection();
                            ps1 = conn1.prepareStatement("SELECT * FROM Station");
                            rs1 = ps1.executeQuery();
                            
                            while (rs1.next()) {
                                String stationName = rs1.getString("name");
                    %>        
                            <option value="<%= stationName %>"><%= stationName %></option>
                    <%
                            }
                        } catch (SQLException e) {
                            e.printStackTrace();
                        } finally {
                            try {
                                if (rs1 != null) rs1.close();
                                if (ps1 != null) ps1.close();
                                if (conn1 != null) conn1.close();
                            } catch (SQLException ex) {
                                ex.printStackTrace();
                            }
                        }
                    %>
                </select>
                <input type="submit" value="Search" />
            </form>
        </div>


	    <!-- Train Schedules Table -->
        <table>
            <thead>
                <tr>
                    <th>Line Name</th>
                    <th>Origin</th>
                    <th>Destination</th>
                    <th>Departure</th>
                    <th>Arrival</th>
                    <th>Fare</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <%
                    Connection conn4 = null;
                    PreparedStatement ps4 = null;
                    ResultSet rs4 = null;
        
                    try {    
                        ApplicationDB appdb4 = new ApplicationDB();
                        conn4 = appdb4.getConnection();
                        
                        String searchStation = request.getParameter("station");
                        String query = 
                            "SELECT TL.lineName, S1.name AS Origin, S2.name AS Destination, " +
                            "TL.departureDateTime, TL.arrivalDateTime, TL.fare, TL.lineId " +
                            "FROM TransitLine TL " +
                            "JOIN Station S1 ON TL.origin = S1.stationId " +
                            "JOIN Station S2 ON TL.destination = S2.stationId ";
        
                        if (searchStation != null && !searchStation.trim().isEmpty()) {
                            query += "WHERE S1.name LIKE ? OR S2.name LIKE ?";
                        }
        
                        ps4 = conn4.prepareStatement(query);
        
                        if (searchStation != null && !searchStation.trim().isEmpty()) {
                            String searchPattern = "%" + searchStation + "%";
                            ps4.setString(1, searchPattern);
                            ps4.setString(2, searchPattern);
                        }
        
                        rs4 = ps4.executeQuery();
        
                        while (rs4.next()) {
                            String lineName = rs4.getString("lineName");
                            String origin = rs4.getString("Origin");
                            String destination = rs4.getString("Destination");
                            String departure = rs4.getString("departureDateTime");
                            String arrival = rs4.getString("arrivalDateTime");
                            float fare = rs4.getFloat("fare");
                            int lineId = rs4.getInt("lineId");
        
                            // Display the train schedules
                %>
                            <tr id="row-<%= lineId %>">
                                <td><%= lineName %></td>
                                <td><%= origin %></td>
                                <td><%= destination %></td>
                                <td><%= departure %></td>
                                <td><%= arrival %></td>
                                <td><%= fare %></td>
                                <td>
                                    <!-- Edit Form -->
                                    <form method="POST" action="repWelcome.jsp">
                                        <input type="hidden" name="editLineId" value="<%= lineId %>">
                                        <input type="submit" value="Edit" class="edit-button">
                                    </form>
                                    
                                    <!-- Delete Form -->
                                    <form method="POST" action="deleteSchedule.jsp">
                                        <input type="hidden" name="lineId" value="<%= lineId %>" />
                                        <input type="submit" value="Delete" class="delete-button" onclick="return confirm('Are you sure you want to delete this schedule?');" />
                                    </form>
                                    
                                    <!-- View Form -->
                                    <form method="GET" action="viewStops.jsp">
                                        <input type="hidden" name="lineId" value="<%= lineId %>">
                                        <input type="hidden" name="origin" value="<%= origin %>">
                                        <input type="hidden" name="destination" value="<%= destination %>">
                                        <input type="submit" value="View" class="view-button">
                                    </form>
                                </td>
                            </tr>
        
                            <!-- Conditional Edit Form Display -->
                            <% if (request.getParameter("editLineId") != null && Integer.parseInt(request.getParameter("editLineId")) == lineId) { %>
                                <tr>
                                    <td colspan="7">
                                        <form method="POST" action="updateSchedule.jsp">
                                            <input type="hidden" name="lineId" value="<%= lineId %>">
                                            
                                            <!-- Update Line Name -->
                                            <label for="lineName-<%= lineId %>">Line Name:</label>
                                            <input type="text" name="lineName" id="lineName-<%= lineId %>" value="<%= lineName %>"><br>
                                            
                                            <!-- Update Origin -->
                                            <label for="origin-<%= lineId %>">Origin:</label>
                                            <input type="text" name="origin" id="origin-<%= lineId %>" value="<%= origin %>"><br>

                                            <!-- Update Destination --> 
                                            <label for="destination-<%= lineId %>">Destination:</label>
                                            <input type="text" name="destination" id="destination-<%= lineId %>" value="<%= destination %>"><br>
                                            
                                            <label for="departure-<%= lineId %>">Departure:</label>
                                            <input type="datetime-local" name="departure" id="departure-<%= lineId %>" value="<%= departure %>"><br>
                                            
                                            <label for="arrival-<%= lineId %>">Arrival:</label>
                                            <input type="datetime-local" name="arrival" id="arrival-<%= lineId %>" value="<%= arrival %>"><br>
                                            
                                            <label for="fare-<%= lineId %>">Fare:</label>
                                            <input type="number" step="0.01" name="fare" id="fare-<%= lineId %>" value="<%= fare %>"><br>
                                            
                                            <input type="submit" value="Update">
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    } finally {
                        if (rs4 != null) try { rs4.close(); } catch (SQLException e) {}
                        if (ps4 != null) try { ps4.close(); } catch (SQLException e) {}
                        if (conn4 != null) try { conn4.close(); } catch (SQLException e) {}
                    }
                %>
            </tbody>
        </table>
	</div>
    <div class="bottom-half">
        <% if (errorMessage != null) { %>
            <p style="color:red;"><%= errorMessage %></p>
        <% } %>

        <!-- Questions and Answers Section -->
        <div class="questions-answers-header">
            <p>Questions and Answers Section:</p>
        </div>

        <!-- Search Bar Section -->
        <div class="search-section">
            <form method="GET" action="repWelcome.jsp" class="search-container">
                <input type="text" name="searchKeyword" placeholder="Search by question keyword" />
                <input type="submit" value="Search" />
            </form>

            <form method="GET" action="repWelcome.jsp" class="search-container">
                <input type="text" name="searchUsername" placeholder="Search by customer username" />
                <input type="submit" value="Search" />
            </form>
        </div>

        <!-- Question and Answer Display -->
        <div class="question-section">
            <% for (int i = 0; i < questions.size(); i++) { %>
                <div class="question-item">
                    <p><span class="label-bold">Q:</span> <%= questions.get(i) %></p>
                    <p><span class="label-bold">Posted By:</span> <%= questionUsernames.get(i) %></p>
                    <p><span class="label-bold">A:</span> <%= (answers.get(i).isEmpty() ? "" : answers.get(i)) %></p>
                    <form method="POST" action="repWelcome.jsp">
                        <input type="hidden" name="replyQuestionId" value="<%= questionIds.get(i) %>">
                        <div class="reply-section">
                            <textarea name="replyText" placeholder="Write your reply here..."></textarea>
                            <input type="submit" value="Reply" />
                        </div>
                    </form>
                </div>
            <% } %>
        </div>
    </div>
</div>

</body>
</html>
