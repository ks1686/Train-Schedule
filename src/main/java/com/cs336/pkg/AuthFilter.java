package com.cs336.pkg;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class AuthFilter implements Filter {
    @Override
    public void init(FilterConfig filterConfig) {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        String path = req.getServletPath();
        if (path == null) {
            path = "";
        }

        String requiredRole = null;
        if (path.startsWith("/Customer/")) {
            requiredRole = Roles.CUSTOMER;
        } else if (path.startsWith("/Manager/")) {
            requiredRole = Roles.MANAGER;
        } else if (path.startsWith("/Representative/")) {
            requiredRole = Roles.REPRESENTATIVE;
        }

        if (requiredRole != null && !Auth.requireRole(req, resp, requiredRole)) {
            return;
        }
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
