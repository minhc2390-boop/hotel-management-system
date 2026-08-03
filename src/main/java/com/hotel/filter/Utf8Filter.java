package com.hotel.filter;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class Utf8Filter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Thiết lập encoding UTF-8 cho cả request và response
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        
        // Chỉ định dạng Content-Type text/html với UTF-8 cho các trang động (JSP, HTML, Servlet)
        // tránh ảnh hưởng đến các tài nguyên tĩnh như CSS, JS, ảnh...
        String path = httpRequest.getRequestURI().substring(httpRequest.getContextPath().length());
        if (!path.contains(".") || path.endsWith(".jsp") || path.endsWith(".html")) {
            httpResponse.setContentType("text/html; charset=UTF-8");
        }
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}

