package com.hotel.filter;

import com.hotel.model.User;
import com.hotel.util.AuthUtil;

import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/admin/*", "/manager/*", "/rooms/manage", "/services/manage", "/bills/manage", "/roomtypes", "/services", "/bookings", "/equipments", "/users", "/laundry"
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

        // Cho phép truy cập công khai khi đặt phòng hoặc xem phiếu xác nhận đặt phòng
        boolean isPublicBooking = uri.endsWith("/bookings") && ("insert".equals(action) || "receipt".equals(action));
        boolean isPublicLaundry = uri.endsWith("/laundry") && ("clientBook".equals(action) || "clientBookForm".equals(action));

        if (!isPublicBooking && !isPublicLaundry) {
            // 1. Chưa đăng nhập -> redirect về trang đăng nhập
            if (!AuthUtil.isAuthenticated(httpRequest)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/login");
                return;
            }
        }

        User currentUser = AuthUtil.getUser(httpRequest);
        String role = (currentUser != null && currentUser.getRole() != null) ? currentUser.getRole() : "";

        // 2. Quyền quản lý cấp cao
        if (uri.contains("/manager/")) {
            if (!"Admin".equalsIgnoreCase(role) && !"Manager".equalsIgnoreCase(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
                return;
            }
        }

        // 3. Quyền Admin / Quản trị viên
        if (uri.contains("/users") || uri.contains("/settings")) {
            if (!"Admin".equalsIgnoreCase(role)) {
                httpResponse.sendRedirect(httpRequest.getContextPath() + "/home");
                return;
            }
        }

        // 4. Đối với các URL quản trị khác (/admin/*, /equipments, /roomtypes)
        if (uri.contains("/admin/") || uri.contains("/equipments") || uri.contains("/roomtypes")) {
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
