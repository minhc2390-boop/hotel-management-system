package com.hotel.controller;

import com.hotel.dao.LaundryDAO;
import com.hotel.model.Laundry;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet(name = "LaundryServlet", urlPatterns = {"/laundry"})
public class LaundryServlet extends HttpServlet {

    private final LaundryDAO laundryDAO = new LaundryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = ParamUtil.getString(request, "action", "list");

        // Client-facing laundry order form (No Admin check required)
        if ("clientBook".equals(action)) {
            User currentUser = AuthUtil.getUser(request);
            Laundry laundry = new Laundry();
            if (currentUser != null) {
                laundry.setCustomerName(currentUser.getFullName());
            }
            request.setAttribute("laundry", laundry);
            request.getRequestDispatcher("/client-laundry-form.jsp").forward(request, response);
            return;
        }

        // Admin / Receptionist routes require authorization
        if (!isAuthorized(request)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                String keyword = ParamUtil.getString(request, "keyword", "");
                String status = ParamUtil.getString(request, "status", "");
                List<Laundry> laundries = laundryDAO.searchLaundries(keyword, status);
                request.setAttribute("laundries", laundries);
                request.setAttribute("keyword", keyword);
                request.setAttribute("status", status);
                request.getRequestDispatcher("/admin/laundry-list.jsp").forward(request, response);
                break;
            case "add":
                request.setAttribute("laundry", new Laundry());
                request.setAttribute("isEdit", false);
                request.getRequestDispatcher("/admin/laundry-form.jsp").forward(request, response);
                break;
            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Laundry editItem = laundryDAO.getById(editId);
                if (editItem == null) {
                    response.sendRedirect(request.getContextPath() + "/laundry?action=list");
                    return;
                }
                request.setAttribute("laundry", editItem);
                request.setAttribute("isEdit", true);
                request.getRequestDispatcher("/admin/laundry-form.jsp").forward(request, response);
                break;
            case "detail":
                int detailId = ParamUtil.getInt(request, "id", 0);
                Laundry detailItem = laundryDAO.getById(detailId);
                if (detailItem == null) {
                    response.sendRedirect(request.getContextPath() + "/laundry?action=list");
                    return;
                }
                request.setAttribute("laundry", detailItem);
                request.getRequestDispatcher("/admin/laundry-detail.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/laundry?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        String action = ParamUtil.getString(request, "action", "");

        // Customer submission route (No Admin check required)
        if ("clientInsert".equals(action)) {
            String customerName = ParamUtil.getString(request, "customerName", "");
            String roomNumber = ParamUtil.getString(request, "roomNumber", "");
            String serviceType = ParamUtil.getString(request, "serviceType", "Giặt sấy thông thường");
            int quantity = Math.max(1, ParamUtil.getInt(request, "quantity", 1));
            String notes = ParamUtil.getString(request, "notes", "");

            double unitPrice = getUnitPrice(serviceType);
            double totalPrice = unitPrice * quantity;

            Laundry laundry = new Laundry();
            laundry.setCustomerName(customerName);
            laundry.setRoomNumber(roomNumber);
            laundry.setServiceType(serviceType);
            laundry.setQuantity(quantity);
            laundry.setTotalPrice(totalPrice);
            laundry.setProcessingStatus("Chưa hoàn thành");
            laundry.setNotes(notes);
            laundry.setCreatedDate(LocalDateTime.now());

            String error = validateClientInput(laundry);
            if (error != null) {
                request.setAttribute("laundry", laundry);
                request.setAttribute("error", error);
                request.getRequestDispatcher("/client-laundry-form.jsp").forward(request, response);
                return;
            }

            boolean success = laundryDAO.insert(laundry);
            if (!success) {
                request.setAttribute("laundry", laundry);
                request.setAttribute("error", "Không thể gửi yêu cầu giặt ủi. Vui lòng liên hệ lễ tân.");
                request.getRequestDispatcher("/client-laundry-form.jsp").forward(request, response);
                return;
            }

            response.sendRedirect(request.getContextPath() + "/laundry?action=clientBook&success=1");
            return;
        }

        // Admin / Receptionist routes require authorization
        if (!isAuthorized(request)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("delete".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            laundryDAO.delete(id);
            response.sendRedirect(request.getContextPath() + "/laundry?action=list&deleted=1");
            return;
        }

        if ("updateStatus".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            String rawStatus = request.getParameter("processingStatus");
            String newStatus = (rawStatus != null && !rawStatus.trim().isEmpty()) ? rawStatus.trim() : "Đã hoàn thành";
            laundryDAO.updateProcessingStatus(id, newStatus);
            response.sendRedirect(request.getContextPath() + "/laundry?action=list&statusUpdated=1");
            return;
        }

        int id = ParamUtil.getInt(request, "id", 0);
        Laundry laundry = (id > 0) ? laundryDAO.getById(id) : new Laundry();
        if (laundry == null) {
            laundry = new Laundry();
        }

        String customerName = ParamUtil.getString(request, "customerName", "");
        String roomNumber = ParamUtil.getString(request, "roomNumber", "");
        String serviceType = ParamUtil.getString(request, "serviceType", "Giặt sấy thông thường");
        int quantity = ParamUtil.getInt(request, "quantity", 1);
        double totalPrice = ParamUtil.getDouble(request, "totalPrice", 0.0);
        String processingStatus = ParamUtil.getString(request, "processingStatus", "Chưa hoàn thành");
        String notes = ParamUtil.getString(request, "notes", "");

        laundry.setCustomerName(customerName);
        laundry.setRoomNumber(roomNumber);
        laundry.setServiceType(serviceType);
        laundry.setQuantity(Math.max(1, quantity));
        laundry.setTotalPrice(Math.max(0.0, totalPrice));
        laundry.setProcessingStatus(processingStatus);
        laundry.setNotes(notes);

        String validationError = validateAdminInput(laundry);
        if (validationError != null) {
            request.setAttribute("laundry", laundry);
            request.setAttribute("isEdit", "update".equals(action));
            request.setAttribute("error", validationError);
            request.getRequestDispatcher("/admin/laundry-form.jsp").forward(request, response);
            return;
        }

        try {
            boolean success;
            if ("insert".equals(action) || id == 0) {
                laundry.setCreatedDate(LocalDateTime.now());
                success = laundryDAO.insert(laundry);
            } else {
                success = laundryDAO.update(laundry);
            }

            if (!success) {
                request.setAttribute("laundry", laundry);
                request.setAttribute("isEdit", id > 0);
                request.setAttribute("error", "Không thể lưu đơn giặt ủi. Vui lòng kiểm tra dữ liệu.");
                request.getRequestDispatcher("/admin/laundry-form.jsp").forward(request, response);
                return;
            }
        } catch (Exception ex) {
            ex.printStackTrace();
            String errorMsg = ex.getCause() != null ? ex.getCause().getMessage() : ex.getMessage();
            request.setAttribute("laundry", laundry);
            request.setAttribute("isEdit", id > 0);
            request.setAttribute("error", "Lỗi lưu Database: " + (errorMsg != null ? errorMsg : ex.toString()));
            request.getRequestDispatcher("/admin/laundry-form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/laundry?action=list&saved=1");
    }

    private double getUnitPrice(String serviceType) {
        if ("Giặt khô (Dry Cleaning)".equals(serviceType)) return 120000.0;
        if ("Ủi quần áo".equals(serviceType)) return 30000.0;
        if ("Giặt hấp cao cấp".equals(serviceType)) return 150000.0;
        if ("Tẩy vết bẩn đặc biệt".equals(serviceType)) return 80000.0;
        return 45000.0; // Default: Giặt sấy thông thường
    }

    private String validateClientInput(Laundry item) {
        if (item.getCustomerName() == null || item.getCustomerName().trim().isEmpty()) {
            return "Vui lòng nhập tên khách hàng.";
        }
        if (item.getCustomerName().length() > 150) {
            return "Tên khách hàng không được vượt quá 150 ký tự.";
        }
        if (item.getRoomNumber() == null || item.getRoomNumber().trim().isEmpty()) {
            return "Vui lòng nhập số phòng lưu trú của bạn.";
        }
        if (item.getNotes() != null && item.getNotes().length() > 500) {
            return "Ghi chú (Lưu ý) không được vượt quá 500 ký tự.";
        }
        return null;
    }

    private String validateAdminInput(Laundry item) {
        String error = validateClientInput(item);
        if (error != null) return error;
        String status = item.getProcessingStatus();
        if (!"Chưa hoàn thành".equals(status) && !"Đã hoàn thành".equals(status) &&
            !"Chưa hoàn tất".equals(status) && !"Đã hoàn tất".equals(status)) {
            return "Trạng thái xử lý không hợp lệ.";
        }
        return null;
    }

    private boolean isAuthorized(HttpServletRequest request) {
        User user = AuthUtil.getUser(request);
        return user != null && ("Admin".equalsIgnoreCase(user.getRole()) || "Receptionist".equalsIgnoreCase(user.getRole()));
    }
}
