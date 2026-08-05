package com.hotel.filter;

import com.hotel.model.User;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

// @WebFilter(filterName = "AuthenticationFilter", urlPatterns = {"/admin/*", "/rooms/manage", "/services/manage", "/bills/manage"})
public class AuthenticationFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        HttpSession session = httpRequest.getSession(false);

        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            // User not logged in, redirect to login page
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
        } else if ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole())) {
            // User is admin/receptionist, allow access
            chain.doFilter(request, response);
        } else {
            // User is customer but trying to access admin area, redirect to home page
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
        }
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}
