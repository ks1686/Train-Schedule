<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<!DOCTYPE html>
<html>
<head>
    <title>Customer Welcome</title>
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
        }

        .top-half {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            flex-direction: column;
        }

        .bottom-half {
            flex: 2;
            overflow-y: auto;
            margin-top: 20px;
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

        .search-container {
            margin-top: 20px;
            margin-bottom: 20px;
        }

        .search-container input[type="text"] {
            width: 260px;
            padding: 10px;
            font-size: 14px;
            border-radius: 4px;
            border: 1px solid #ccc;
            margin-right: 10px;
        }

        .search-container input[type="submit"] {
            padding: 10px 20px;
            font-size: 14px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        .search-container input[type="submit"]:hover {
            background-color: #45a049;
        }

        .form-container textarea {
            font-size: 14px;
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

        .question-text {
            font-size: 16px;
            margin-bottom: 8px;
        }

        .label-bold {
            font-weight: bold;
        }

    </style>
</head>
<body>

<% 
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
    String errorMessage = null;
    List<String> questions = new ArrayList<>();
    List<String> answers = new ArrayList<>();
    List<String> questionUsernames = new ArrayList<>();
    List<Integer> questionIds = new ArrayList<>();

    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        String searchKeyword = request.getParameter("searchKeyword");
        String query = "SELECT q.questionId, q.questionText, a.answerText, c.username FROM Questions q " + 
                       "LEFT JOIN Answers a ON q.questionId = a.questionId " +
                       "JOIN Customer c ON q.customerId = c.customerId " +
                       "WHERE q.customerId = (SELECT customerId FROM Customer WHERE username = ?)";
        
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            query += " AND LOWER(q.questionText) LIKE LOWER(?)";
        }
        
        ps = conn.prepareStatement(query);
        ps.setString(1, username);
        if (searchKeyword != null && !searchKeyword.trim().isEmpty()) {
            ps.setString(2, "%" + searchKeyword.toLowerCase() + "%");
        }
        
        rs = ps.executeQuery();

        while (rs.next()) {
            questionIds.add(rs.getInt("questionId"));
            questions.add(rs.getString("questionText"));
            answers.add(rs.getString("answerText") != null ? rs.getString("answerText") : "");
            questionUsernames.add(rs.getString("username"));
        }

        String newQuestion = request.getParameter("newQuestion");
        if (newQuestion != null && !newQuestion.isEmpty()) {
            PreparedStatement ps2 = null;
            try {
                String insertQuestionQuery = "INSERT INTO Questions (customerId, questionText) " +
                                             "VALUES ((SELECT customerId FROM Customer WHERE username = ?), ?)";
                ps2 = conn.prepareStatement(insertQuestionQuery);
                ps2.setString(1, username);
                ps2.setString(2, newQuestion);
                ps2.executeUpdate();
                response.sendRedirect("customerWelcome.jsp");
            } catch (SQLException e) {
                errorMessage = "Error submitting your question: " + e.getMessage();
            } finally {
                if (ps2 != null) ps2.close();
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
    <div class="username">Hello, <%= username %>!</div>
    <a href="logout.jsp" class="logout-button">Logout</a>
</div>

<% if (errorMessage != null) { %>
    <div style="color: red; margin-bottom: 20px;"><%= errorMessage %></div>
<% } %>

<div class="main-container">
    <div class="top-half">
        <h2>Welcome to Your Dashboard</h2>
    </div>

    <div class="bottom-half">
        <h3>Questions and Answers Section:</h3>
        
        <div class="form-container">
            <h3>Ask a New Question:</h3>
            <form method="POST" action="customerWelcome.jsp">
                <textarea name="newQuestion" rows="4" placeholder="Write your question here" required></textarea><br>
                <input type="submit" value="Submit Question" />
            </form>
        </div>

        <div class="search-container">
            <form method="GET" action="customerWelcome.jsp">
                <input type="text" name="searchKeyword" placeholder="Search by question keyword" value="<%= (request.getParameter("searchKeyword") != null) ? request.getParameter("searchKeyword") : "" %>" />
                <input type="submit" value="Search" />
            </form>
        </div>

        <div class="question-section">
            <% for (int i = 0; i < questions.size(); i++) { %>
                <div class="question-item">
                    <h3 class="question-text">Q: <%= questions.get(i) %></h3>
                    <p><strong class="label-bold">Posted by:</strong> <%= questionUsernames.get(i) %></p>
                    <p><strong class="label-bold">A:</strong> <%= (answers.get(i) != null && !answers.get(i).isEmpty()) ? answers.get(i) : "" %></p>
                </div>
            <% } %>
        </div>
    </div>
</div>

</body>
</html>