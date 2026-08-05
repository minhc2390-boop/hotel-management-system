package com.hotel.controller;

import com.hotel.dao.RoomTypeDAO;
import com.hotel.model.RoomType;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomTypeServlet", urlPatterns = {"/roomtypes"})
public class RoomTypeServlet extends HttpServlet {
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "list");

        // Sử dụng AuthUtil kiểm tra phân quyền
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        String role = currentUser.getRole();
        if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("roomTypes", roomTypes);
                request.getRequestDispatcher("/admin/room-types.jsp").forward(request, response);
                break;

            case "add":
                request.getRequestDispatcher("/admin/room-type-form.jsp").forward(request, response);
                break;

            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                RoomType typeToEdit = roomTypeDAO.getRoomTypeById(editId);
                request.setAttribute("roomType", typeToEdit);
                request.getRequestDispatcher("/admin/room-type-form.jsp").forward(request, response);
                break;

            case "delete":
                // Chỉ Admin (Quản lý) mới có quyền xóa loại phòng
                if (AuthUtil.isManager(request)) {
                    int deleteId = ParamUtil.getInt(request, "id", 0);
                    roomTypeDAO.deleteRoomType(deleteId);
                }
                response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "");

        // Sử dụng AuthUtil kiểm tra phân quyền
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        String role = currentUser.getRole();
        if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("insert".equals(action)) {
            String name = ParamUtil.getString(request, "name", "");
            double pricePerDay = ParamUtil.getDouble(request, "pricePerDay", 0.0);
            int capacity = ParamUtil.getInt(request, "capacity", 1);
            String description = ParamUtil.getString(request, "description", "");

            RoomType rt = new RoomType(name, pricePerDay, capacity, description);
            roomTypeDAO.insertRoomType(rt);
            response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");

        } else if ("update".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            String name = ParamUtil.getString(request, "name", "");
            double pricePerDay = ParamUtil.getDouble(request, "pricePerDay", 0.0);
            int capacity = ParamUtil.getInt(request, "capacity", 1);
            String description = ParamUtil.getString(request, "description", "");

            RoomType rt = new RoomType(id, name, pricePerDay, capacity, description);
            roomTypeDAO.updateRoomType(rt);
            response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");
        }
    }
}
