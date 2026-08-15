package com.cs336.pkg;

import java.security.SecureRandom;
import java.util.Base64;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

public final class Csrf {
    public static final String TOKEN_ATTR = "csrfToken";
    public static final String PARAM = "csrfToken";

    private static final SecureRandom RANDOM = new SecureRandom();

    private Csrf() {
    }

    public static String token(HttpSession session) {
        if (session == null) {
            throw new IllegalStateException("session required");
        }
        Object existing = session.getAttribute(TOKEN_ATTR);
        if (existing instanceof String && !((String) existing).isEmpty()) {
            return (String) existing;
        }
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute(TOKEN_ATTR, token);
        return token;
    }

    public static String hiddenField(HttpSession session) {
        return "<input type=\"hidden\" name=\"" + PARAM + "\" value=\"" + Html.escape(token(session)) + "\">";
    }

    public static boolean isValid(HttpServletRequest request) {
        if (request == null) {
            return false;
        }
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object expected = session.getAttribute(TOKEN_ATTR);
        String provided = request.getParameter(PARAM);
        if (!(expected instanceof String) || provided == null) {
            return false;
        }
        return constantTimeEquals((String) expected, provided);
    }

    public static void requireValid(HttpServletRequest request) {
        if (!isValid(request)) {
            throw new SecurityException("Invalid CSRF token");
        }
    }

    private static boolean constantTimeEquals(String a, String b) {
        if (a.length() != b.length()) {
            return false;
        }
        int result = 0;
        for (int i = 0; i < a.length(); i++) {
            result |= a.charAt(i) ^ b.charAt(i);
        }
        return result == 0;
    }
}
