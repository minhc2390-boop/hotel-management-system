package com.hotel.controller;

import com.hotel.dao.SystemSettingDAO;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

@WebServlet(name = "SettingServlet", urlPatterns = {"/admin/settings", "/admin/setting-update"})
public class SettingServlet extends HttpServlet {

    private final SystemSettingDAO settingDAO = new SystemSettingDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Kiểm tra phân quyền truy cập (Admin hoặc Receptionist)
        User currentUser = AuthUtil.getUser(request);
        if (currentUser == null || (!"Admin".equalsIgnoreCase(currentUser.getRole()) && !"Receptionist".equalsIgnoreCase(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Nạp tất cả cài đặt từ CSDL
        Map<String, String> settings = settingDAO.getAllSettings();
        for (Map.Entry<String, String> entry : settings.entrySet()) {
            request.setAttribute(entry.getKey(), entry.getValue());
        }

        // Forward tới trang settings.jsp
        request.setAttribute("settingsControllerRequest", Boolean.TRUE);
        request.getRequestDispatcher("/admin/settings.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = AuthUtil.getUser(request);
        if (currentUser == null || (!"Admin".equalsIgnoreCase(currentUser.getRole()) && !"Receptionist".equalsIgnoreCase(currentUser.getRole()))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác này.");
            return;
        }

        // Đọc các giá trị cài đặt từ Form POST
        String hotelName = ParamUtil.getString(request, "hotel_name", "");
        if (hotelName.isEmpty()) hotelName = ParamUtil.getString(request, "hotelName", "Nestora");

        String hotelAddress = ParamUtil.getString(request, "hotel_address", "");
        if (hotelAddress.isEmpty()) hotelAddress = ParamUtil.getString(request, "hotelAddress", "");

        String hotelPhone = ParamUtil.getString(request, "hotel_phone", "");
        if (hotelPhone.isEmpty()) hotelPhone = ParamUtil.getString(request, "hotelPhone", "");

        String hotelEmail = ParamUtil.getString(request, "hotel_email", "");
        if (hotelEmail.isEmpty()) hotelEmail = ParamUtil.getString(request, "hotelEmail", "");

        String bankId = ParamUtil.getString(request, "hotel_bank_id", "");
        if (bankId.isEmpty()) bankId = ParamUtil.getString(request, "bankId", "MB");

        String bankAccount = ParamUtil.getString(request, "hotel_bank_account", "");
        if (bankAccount.isEmpty()) bankAccount = ParamUtil.getString(request, "bankAccount", "");

        String bankName = ParamUtil.getString(request, "hotel_bank_name", "");
        if (bankName.isEmpty()) bankName = ParamUtil.getString(request, "bankName", "");

        String theme = ParamUtil.getString(request, "nestora_theme", "");
        if (theme.isEmpty()) theme = ParamUtil.getString(request, "theme", "light");

        // Lưu vào CSDL thông qua SystemSettingDAO
        settingDAO.saveSetting("hotel_name", hotelName);
        settingDAO.saveSetting("hotel_address", hotelAddress);
        settingDAO.saveSetting("hotel_phone", hotelPhone);
        settingDAO.saveSetting("hotel_email", hotelEmail);

        settingDAO.saveSetting("hotel_bank_id", bankId);
        settingDAO.saveSetting("hotel_bank_account", bankAccount);
        settingDAO.saveSetting("hotel_bank_name", bankName);

        settingDAO.saveSetting("nestora_theme", theme);

        // Kiểm tra xem request có phải là AJAX không
        String requestedWith = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equalsIgnoreCase(requestedWith)) {
            response.setContentType("application/json;charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.print("{\"status\":\"success\", \"message\":\"Lưu cài đặt hệ thống vào CSDL thành công!\"}");
            out.flush();
            return;
        }

        // Chuyển hướng lại trang settings kèm thông báo thành công
        request.setAttribute("success", "Lưu cài đặt hệ thống vào CSDL thành công!");
        doGet(request, response);
    }
}
