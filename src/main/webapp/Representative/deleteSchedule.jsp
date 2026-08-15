<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
    pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<%@ page import="java.io.*,java.util.*,java.sql.*,javax.servlet.http.*,javax.servlet.*"%>

<%
    if (!Auth.requireRole(request, response, Roles.REPRESENTATIVE)) {
        return;
    }

    if (!"POST".equalsIgnoreCase(request.getMethod()) || !Csrf.isValid(request)) {
        out.print("Invalid request.");
        return;
    }

    String lineId = request.getParameter("lineId");
    if (lineId == null || lineId.trim().isEmpty()) {
        out.print("invalid lineId");
        return;
    }

    int parsedLineId;
    try {
        parsedLineId = Integer.parseInt(lineId.trim());
    } catch (NumberFormatException e) {
        out.print("invalid lineId");
        return;
    }

    Connection conn = null;
    PreparedStatement ps = null;
    try {
        ApplicationDB appdb = new ApplicationDB();
        conn = appdb.getConnection();

        ps = conn.prepareStatement("DELETE FROM TransitLine WHERE lineId = ?");
        ps.setInt(1, parsedLineId);

        int result = ps.executeUpdate();
        if (result > 0) {
            response.sendRedirect("repWelcome.jsp");
        } else {
            out.print("Schedule not found.");
        }
    } catch (SQLException e) {
        String sqlState = e.getSQLState();
        boolean referenced = "23000".equals(sqlState) || e.getErrorCode() == 1451 || e.getErrorCode() == 1217;
        if (referenced) {
            out.print("Cannot delete this schedule because tickets already exist for it.");
        } else {
            out.print("Error deleting schedule.");
        }
    } finally {
        if (ps != null) {
            try {
                ps.close();
            } catch (SQLException ignored) {
                // ignore close errors
            }
        }
        new ApplicationDB().closeConnection(conn);
    }
%>
