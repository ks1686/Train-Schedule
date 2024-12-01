<%@ page language="java" contentType="text/html; charset=ISO-8859-1" 
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

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
        }

        .top-half {
            flex: 6;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
        }

        .bottom-half {
            flex: 4;
            overflow-y: auto;
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

    </style>
</head>
<body>

<% 
    if (session == null || session.getAttribute("username") == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    String role = (String) session.getAttribute("role");
    if (!role.equals("Representative")) {
        response.sendRedirect("../403.jsp");
        return;
    }

    String username = (String) session.getAttribute("username");
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
        <h2>Welcome to the Representative Dashboard</h2>
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