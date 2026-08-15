package com.cs336.pkg;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

public final class Auth {
    public static final String USERNAME = "username";
    public static final String ROLE = "role";

    private Auth() {
    }

    public static String username(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(USERNAME);
        return value instanceof String ? (String) value : null;
    }

    public static String role(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(ROLE);
        return value instanceof String ? (String) value : null;
    }

    public static boolean hasRole(HttpSession session, String expected) {
        return expected != null && expected.equals(role(session));
    }

    public static boolean requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (username(session) == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return false;
        }
        return true;
    }

    public static boolean requireRole(HttpServletRequest request, HttpServletResponse response, String expected)
            throws IOException {
        if (!requireLogin(request, response)) {
            return false;
        }
        if (!hasRole(request.getSession(false), expected)) {
            response.sendRedirect(request.getContextPath() + "/403.jsp");
            return false;
        }
        return true;
    }

    public static void establish(HttpServletRequest request, String username, String role) {
        HttpSession old = request.getSession(false);
        if (old != null) {
            old.invalidate();
        }
        HttpSession session = request.getSession(true);
        session.setAttribute(USERNAME, username);
        session.setAttribute(ROLE, role);
        Csrf.token(session);
    }
}
