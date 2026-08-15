<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*,java.time.LocalDate,java.time.LocalDateTime,java.time.format.DateTimeFormatter"%>

<%
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (!Auth.requireRole(request, response, Roles.REPRESENTATIVE)) {
        return;
    }

    String username = Auth.username(session);
    String errorMessage = null;
    List<String> questions = new ArrayList<>();
    List<String> answers = new ArrayList<>();
    List<String> questionUsernames = new ArrayList<>();
    List<Integer> questionIds = new ArrayList<>();
    List<String> lineNames = new ArrayList<>();
    List<Station> stations = new ArrayList<>();
    List<String[]> customers = new ArrayList<String[]>();
    List<String[]> schedules = new ArrayList<String[]>();

    String searchUsername = request.getParameter("searchUsername");
    String searchKeyword = request.getParameter("searchKeyword");
    String selectedLineName = request.getParameter("lineName");
    String selectedDate = request.getParameter("reservationDate");
    String searchStation = request.getParameter("station");
    String editLineIdParam = request.getParameter("editLineId");
    Integer editLineId = null;
    if (editLineIdParam != null && !editLineIdParam.trim().isEmpty()) {
        try {
            editLineId = Integer.valueOf(editLineIdParam.trim());
        } catch (NumberFormatException ignored) {
            editLineId = null;
        }
    }

    DateTimeFormatter localInput = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        if ("POST".equalsIgnoreCase(request.getMethod())
                && request.getParameter("replyQuestionId") != null
                && request.getParameter("replyText") != null
                && !request.getParameter("replyText").trim().isEmpty()) {
            if (!Csrf.isValid(request)) {
                errorMessage = "Invalid request.";
            } else {
                PreparedStatement psReply = null;
                ResultSet rsCheck = null;
                try {
                    int replyQuestionId = Integer.parseInt(request.getParameter("replyQuestionId").trim());
                    String replyText = request.getParameter("replyText").trim();

                    psReply = conn.prepareStatement("SELECT answerId FROM Answers WHERE questionId = ?");
                    psReply.setInt(1, replyQuestionId);
                    rsCheck = psReply.executeQuery();
                    boolean exists = rsCheck.next();
                    rsCheck.close();
                    rsCheck = null;
                    psReply.close();
                    psReply = null;

                    if (exists) {
                        psReply = conn.prepareStatement(
                                "UPDATE Answers SET answerText = ?, employeeSSN = (SELECT ssn FROM Employee WHERE username = ?) WHERE questionId = ?");
                        psReply.setString(1, replyText);
                        psReply.setString(2, username);
                        psReply.setInt(3, replyQuestionId);
                        psReply.executeUpdate();
                    } else {
                        psReply = conn.prepareStatement(
                                "INSERT INTO Answers (questionId, employeeSSN, answerText) "
                                        + "VALUES (?, (SELECT ssn FROM Employee WHERE username = ?), ?)");
                        psReply.setInt(1, replyQuestionId);
                        psReply.setString(2, username);
                        psReply.setString(3, replyText);
                        psReply.executeUpdate();
                    }
                    response.sendRedirect("repWelcome.jsp");
                    return;
                } catch (NumberFormatException e) {
                    errorMessage = "Invalid question.";
                } catch (SQLException e) {
                    errorMessage = "Error replying to the question.";
                } finally {
                    if (rsCheck != null) {
                        try { rsCheck.close(); } catch (SQLException ignored) {}
                    }
                    if (psReply != null) {
                        try { psReply.close(); } catch (SQLException ignored) {}
                    }
                }
            }
        }

        String query = "SELECT q.questionId, q.questionText, a.answerText, c.username FROM Questions q "
                + "LEFT JOIN Answers a ON q.questionId = a.questionId "
                + "JOIN Customer c ON q.customerId = c.customerId";
        if (searchUsername != null && !searchUsername.isEmpty()) {
            query += " WHERE c.username LIKE ?";
        } else if (searchKeyword != null && !searchKeyword.isEmpty()) {
            query += " WHERE q.questionText LIKE ?";
        }
        query += " ORDER BY q.questionId DESC";

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
        rs.close();
        rs = null;
        ps.close();
        ps = null;

        lineNames.addAll(new ScheduleDao().distinctLineNames(conn));
        stations.addAll(new StationDao().listDistinctStopStations(conn));

        if (selectedLineName != null && !selectedLineName.trim().isEmpty()
                && selectedDate != null && !selectedDate.trim().isEmpty()) {
            try {
                LocalDate travelDate = DateTimeConversion.strToDate(selectedDate);
                String customerQuery = "SELECT DISTINCT c.username, c.firstName, c.lastName, c.email "
                        + "FROM Reservation r "
                        + "JOIN TransitLine tl ON r.transitLineId = tl.lineId "
                        + "JOIN Customer c ON r.customerId = c.customerId "
                        + "JOIN Stop origin ON r.originStopId = origin.stopId "
                        + "WHERE tl.lineName = ? AND origin.departureDateTime >= ? AND origin.departureDateTime < ?";
                ps = conn.prepareStatement(customerQuery);
                ps.setString(1, selectedLineName);
                ps.setTimestamp(2, DateTimeConversion.toTimestamp(travelDate.atStartOfDay()));
                ps.setTimestamp(3, DateTimeConversion.toTimestamp(travelDate.plusDays(1).atStartOfDay()));
                rs = ps.executeQuery();
                while (rs.next()) {
                    customers.add(new String[] {
                            rs.getString("username"),
                            rs.getString("firstName"),
                            rs.getString("lastName"),
                            rs.getString("email")
                    });
                }
                rs.close();
                rs = null;
                ps.close();
                ps = null;
            } catch (IllegalArgumentException e) {
                errorMessage = "Invalid reservation date.";
            }
        }

        String scheduleQuery =
                "SELECT TL.lineName, S1.name AS Origin, S2.name AS Destination, "
                + "TL.departureDateTime, TL.arrivalDateTime, TL.fare, TL.lineId "
                + "FROM TransitLine TL "
                + "JOIN Station S1 ON TL.origin = S1.stationId "
                + "JOIN Station S2 ON TL.destination = S2.stationId ";
        if (searchStation != null && !searchStation.trim().isEmpty()) {
            scheduleQuery += "WHERE S1.name LIKE ? OR S2.name LIKE ? ";
        }
        scheduleQuery += "ORDER BY TL.departureDateTime";
        ps = conn.prepareStatement(scheduleQuery);
        if (searchStation != null && !searchStation.trim().isEmpty()) {
            String searchPattern = "%" + searchStation + "%";
            ps.setString(1, searchPattern);
            ps.setString(2, searchPattern);
        }
        rs = ps.executeQuery();
        while (rs.next()) {
            String departure = rs.getString("departureDateTime");
            String arrival = rs.getString("arrivalDateTime");
            String departureLocal = "";
            String arrivalLocal = "";
            try {
                departureLocal = DateTimeConversion.strToDateTime(departure).format(localInput);
            } catch (RuntimeException ignored) {
                departureLocal = departure == null ? "" : departure.replace(' ', 'T');
            }
            try {
                arrivalLocal = DateTimeConversion.strToDateTime(arrival).format(localInput);
            } catch (RuntimeException ignored) {
                arrivalLocal = arrival == null ? "" : arrival.replace(' ', 'T');
            }
            schedules.add(new String[] {
                    rs.getString("lineName"),
                    rs.getString("Origin"),
                    rs.getString("Destination"),
                    departure,
                    arrival,
                    String.valueOf(rs.getFloat("fare")),
                    String.valueOf(rs.getInt("lineId")),
                    departureLocal,
                    arrivalLocal
            });
        }
        rs.close();
        rs = null;
        ps.close();
        ps = null;
    } catch (SQLException e) {
        if (errorMessage == null) {
            errorMessage = "Error loading representative data.";
        }
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException ignored) {
            // ignore close errors
        }
        new ApplicationDB().closeConnection(conn);
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Rep Welcome</title>
    <link rel="stylesheet" href="../css/app.css">
</head>
<body>

<div class="header">
    <span class="username">Hello, <%= Html.escape(username) %></span>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<div class="main-container">
    <div class="top-half">
        <div class="customer-header">
            <p>Customer List By Transit and Reservation Date:</p>
        </div>
        <div class="search-container">
            <form method="GET" action="repWelcome.jsp">
                <label for="lineName">Select Transit Line:</label>
                <select name="lineName" id="lineName" required>
                    <%
                        for (String lineName : lineNames) {
                            String selected = lineName.equals(selectedLineName) ? " selected" : "";
                    %>
                            <option value="<%= Html.escape(lineName) %>"<%= selected %>><%= Html.escape(lineName) %></option>
                    <%
                        }
                    %>
                </select>
                <label for="reservationDate">Select Date:</label>
                <input type="date" name="reservationDate" id="reservationDate" value="<%= Html.escape(selectedDate) %>" required />
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
                    for (String[] customer : customers) {
                %>
                        <tr>
                            <td><%= Html.escape(customer[0]) %></td>
                            <td><%= Html.escape(customer[1]) %></td>
                            <td><%= Html.escape(customer[2]) %></td>
                            <td><%= Html.escape(customer[3]) %></td>
                        </tr>
                <%
                    }
                %>
            </tbody>
        </table>

        <div class="s-header">
            <p>Schedule:</p>
        </div>

        <div class="search-container">
            <form method="GET" action="repWelcome.jsp">
                <label for="station">Select Station:</label>
                <select name="station" id="station" required>
                    <%
                        for (Station station : stations) {
                            String stationName = station.getName();
                            String selected = stationName != null && stationName.equals(searchStation) ? " selected" : "";
                    %>
                            <option value="<%= Html.escape(stationName) %>"<%= selected %>><%= Html.escape(stationName) %></option>
                    <%
                        }
                    %>
                </select>
                <input type="submit" value="Search" />
            </form>
        </div>

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
                    for (String[] schedule : schedules) {
                        String lineName = schedule[0];
                        String origin = schedule[1];
                        String destination = schedule[2];
                        String departure = schedule[3];
                        String arrival = schedule[4];
                        String fare = schedule[5];
                        int lineId = Integer.parseInt(schedule[6]);
                        String departureLocal = schedule[7];
                        String arrivalLocal = schedule[8];
                %>
                            <tr id="row-<%= lineId %>">
                                <td><%= Html.escape(lineName) %></td>
                                <td><%= Html.escape(origin) %></td>
                                <td><%= Html.escape(destination) %></td>
                                <td><%= Html.escape(departure) %></td>
                                <td><%= Html.escape(arrival) %></td>
                                <td><%= Html.escape(fare) %></td>
                                <td>
                                    <form method="POST" action="repWelcome.jsp">
                                        <%= Csrf.hiddenField(session) %>
                                        <input type="hidden" name="editLineId" value="<%= lineId %>">
                                        <input type="submit" value="Edit" class="edit-button">
                                    </form>

                                    <form method="POST" action="deleteSchedule.jsp">
                                        <%= Csrf.hiddenField(session) %>
                                        <input type="hidden" name="lineId" value="<%= lineId %>" />
                                        <input type="submit" value="Delete" class="delete-button" onclick="return confirm('Are you sure you want to delete this schedule?');" />
                                    </form>

                                    <form method="GET" action="viewStops.jsp">
                                        <input type="hidden" name="lineId" value="<%= lineId %>">
                                        <input type="hidden" name="origin" value="<%= Html.escape(origin) %>">
                                        <input type="hidden" name="destination" value="<%= Html.escape(destination) %>">
                                        <input type="submit" value="View" class="view-button">
                                    </form>
                                </td>
                            </tr>

                            <% if (editLineId != null && editLineId.intValue() == lineId) { %>
                                <tr>
                                    <td colspan="7">
                                        <form method="POST" action="updateSchedule.jsp">
                                            <%= Csrf.hiddenField(session) %>
                                            <input type="hidden" name="lineId" value="<%= lineId %>">

                                            <label for="lineName-<%= lineId %>">Line Name:</label>
                                            <input type="text" name="lineName" id="lineName-<%= lineId %>" value="<%= Html.escape(lineName) %>"><br>

                                            <label for="origin-<%= lineId %>">Origin:</label>
                                            <input type="text" name="origin" id="origin-<%= lineId %>" value="<%= Html.escape(origin) %>"><br>

                                            <label for="destination-<%= lineId %>">Destination:</label>
                                            <input type="text" name="destination" id="destination-<%= lineId %>" value="<%= Html.escape(destination) %>"><br>

                                            <label for="departure-<%= lineId %>">Departure:</label>
                                            <input type="datetime-local" name="departure" id="departure-<%= lineId %>" value="<%= Html.escape(departureLocal) %>"><br>

                                            <label for="arrival-<%= lineId %>">Arrival:</label>
                                            <input type="datetime-local" name="arrival" id="arrival-<%= lineId %>" value="<%= Html.escape(arrivalLocal) %>"><br>

                                            <label for="fare-<%= lineId %>">Fare:</label>
                                            <input type="number" step="0.01" name="fare" id="fare-<%= lineId %>" value="<%= Html.escape(fare) %>"><br>

                                            <input type="submit" value="Update">
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                <%
                    }
                %>
            </tbody>
        </table>
    </div>
    <div class="bottom-half">
        <% if (errorMessage != null) { %>
            <p style="color:red;"><%= Html.escape(errorMessage) %></p>
        <% } %>

        <div class="questions-answers-header">
            <p>Questions and Answers Section:</p>
        </div>

        <div class="search-section">
            <form method="GET" action="repWelcome.jsp" class="search-container">
                <input type="text" name="searchKeyword" placeholder="Search by question keyword" value="<%= Html.escape(searchKeyword) %>" />
                <input type="submit" value="Search" />
            </form>

            <form method="GET" action="repWelcome.jsp" class="search-container">
                <input type="text" name="searchUsername" placeholder="Search by customer username" value="<%= Html.escape(searchUsername) %>" />
                <input type="submit" value="Search" />
            </form>
        </div>

        <div class="question-section">
            <% for (int i = 0; i < questions.size(); i++) { %>
                <div class="question-item">
                    <p><span class="label-bold">Q:</span> <%= Html.escape(questions.get(i)) %></p>
                    <p><span class="label-bold">Posted By:</span> <%= Html.escape(questionUsernames.get(i)) %></p>
                    <p><span class="label-bold">A:</span> <%= Html.escape(answers.get(i)) %></p>
                    <form method="POST" action="repWelcome.jsp">
                        <%= Csrf.hiddenField(session) %>
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
