<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    // Set cache control headers to prevent caching of the page
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, post-check=0, pre-check=0");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Welcome</title>
    <link rel="stylesheet" href="../css/app.css">
</head>
<body>

<%
    if (!Auth.requireRole(request, response, Roles.CUSTOMER)) {
        return;
    }
    String username = Auth.username(session);

    String errorMessage = request.getParameter("error");
    String posted = request.getParameter("posted");
    List<String> questions = new ArrayList<>();
    List<String> answers = new ArrayList<>();
    List<String> questionUsernames = new ArrayList<>();
    String searchKeyword = request.getParameter("searchKeyword");

    ApplicationDB appdb = new ApplicationDB();
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        conn = appdb.getConnection();

        if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("newQuestion") != null) {
            if (!Csrf.isValid(request)) {
                response.sendRedirect("askQuestion.jsp?error=invalid");
                return;
            }
            String newQuestion = request.getParameter("newQuestion").trim();
            if (!newQuestion.isEmpty()) {
                PreparedStatement ps2 = null;
                try {
                    String insertQuestionQuery = "INSERT INTO Questions (customerId, questionText) " +
                                                 "VALUES ((SELECT customerId FROM Customer WHERE username = ?), ?)";
                    ps2 = conn.prepareStatement(insertQuestionQuery);
                    ps2.setString(1, username);
                    ps2.setString(2, newQuestion);
                    ps2.executeUpdate();
                    response.sendRedirect("askQuestion.jsp?posted=1");
                    return;
                } finally {
                    if (ps2 != null) ps2.close();
                }
            }
        }

        String query = "SELECT q.questionText, a.answerText, c.username FROM Questions q " +
                       "LEFT JOIN Answers a USING (questionId) " +
                       "JOIN Customer c USING (customerId)";
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            query += " WHERE LOWER(q.questionText) LIKE LOWER(?)";
        }
        query += " ORDER BY q.questionDate DESC";

        ps = conn.prepareStatement(query);
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            ps.setString(1, "%" + searchKeyword.trim() + "%");
        }
        rs = ps.executeQuery();

        while (rs.next()) {
            questions.add(rs.getString("questionText"));
            answers.add(rs.getString("answerText") != null ? rs.getString("answerText") : "");
            questionUsernames.add(rs.getString("username"));
        }
    } catch (SQLException e) {
        errorMessage = "Error loading questions and answers: " + e.getMessage();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        appdb.closeConnection(conn);
    }
%>

<div class="header">
    <div class="username">Hello, <%= Html.escape(username) %>!</div>
    <form class="clear-button" method="POST" action="customerWelcome.jsp">
    	<button name="clear">Clear And Go Back</button>
    </form>
    <a href="../logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= Html.escape(errorMessage) %></div>
<% } %>
<% if ("1".equals(posted)) { %>
    <div style="color: green; margin-bottom: 20px;">Question submitted.</div>
<% } %>

<div class="main-container">
    <div class="bottom-half">	        
		<h2>Speak to a Representative</h2>   
        <div class="form-container">
            <h3>Ask a New Question:</h3>
            <form method="POST" action="askQuestion.jsp">
                <%= Csrf.hiddenField(session) %>
                <textarea name="newQuestion" rows="4" placeholder="Write your question here" required></textarea><br>
                <input type="submit" value="Submit Question" />
            </form>
        </div>

		<details>
			<summary>View Previous Questions</summary>
	        <div class="search-container">
	            <form method="GET" action="askQuestion.jsp">
	                <input type="text" name="searchKeyword" placeholder="Search by question keyword" value="<%= Html.escape(searchKeyword) %>" />
	                <input type="submit" value="Search" />
	            </form>
	        </div>
	
	        <div class="question-section">
	            <% for (int i = 0; i < questions.size(); i++) { %>
	                <div class="question-item">
	                    <p><strong class="label-bold">Posted by:</strong> <%= Html.escape(questionUsernames.get(i)) %></p>
	                    <h3 class="question-text">Q: <%= Html.escape(questions.get(i)) %></h3>
	                    <p><strong class="label-bold">A:</strong> <%= Html.escape(answers.get(i)) %></p>
	                </div>
	            <% } %>
	        </div>
		</details>
    </div>
</div>

</body>
</html>
