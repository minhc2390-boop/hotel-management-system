package com.hotel.filter;

import com.hotel.model.User;
import com.hotel.util.AuthUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/admin/*", "/manager/*", "/rooms/manage", "/services/manage", "/bills/manage", "/roomtypes", "/services", "/bookings"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String uri = httpRequest.getRequestURI();
        String action = httpRequest.getParameter("action");

        // Cho phép truy cập công khai khi đặt phòng (action=insert) hoặc xem hóa đơn đặt phòng (action=receipt)
        boolean isPublicBooking = uri.endsWith("/bookings") && ("insert".equals(action) || "receipt".equals(action));

        if (!isPublicBooking) {
            // 1. Chưa đăng nhập -> redirect về trang đăng nhập
            if (!AuthUtil.isAuthenticated(httpRequest)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
                return;
            }
        }

        User currentUser = AuthUtil.getUser(httpRequest);
        String role = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole() : "";

        // 2. Chỉ user có quyền quản lý mới truy cập được các URL /manager/*
        if (uri.contains("/manager/")) {
            if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
                return;
            }
        }

        // 3. Đối với các URL quản trị khác của khách sạn (như admin, quản lý phòng, dịch vụ, hóa đơn, loại phòng)
        // Yêu cầu tối thiểu là Admin, Receptionist hoặc Manager.
        if (uri.contains("/admin/")) {
            if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
                return;
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
