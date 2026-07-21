package com.hotel.controller;

import com.hotel.dao.RoomTypeDAO;
import com.hotel.model.RoomType;
import com.hotel.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "RoomTypeServlet", urlPatterns = {"/roomtypes"})
public class RoomTypeServlet extends HttpServlet {
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
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
                int editId = Integer.parseInt(request.getParameter("id"));
                RoomType typeToEdit = roomTypeDAO.getRoomTypeById(editId);
                request.setAttribute("roomType", typeToEdit);
                request.getRequestDispatcher("/admin/room-type-form.jsp").forward(request, response);
                break;

            case "delete":
                if ("Admin".equals(currentUser.getRole())) {
                    int deleteId = Integer.parseInt(request.getParameter("id"));
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
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("insert".equals(action)) {
            String name = request.getParameter("name");
            double pricePerDay = Double.parseDouble(request.getParameter("pricePerDay"));
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String description = request.getParameter("description");

            RoomType rt = new RoomType(name, pricePerDay, capacity, description);
            roomTypeDAO.insertRoomType(rt);
            response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");

        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            double pricePerDay = Double.parseDouble(request.getParameter("pricePerDay"));
            int capacity = Integer.parseInt(request.getParameter("capacity"));
            String description = request.getParameter("description");

            RoomType rt = new RoomType(id, name, pricePerDay, capacity, description);
            roomTypeDAO.updateRoomType(rt);
            response.sendRedirect(request.getContextPath() + "/roomtypes?action=list");
        }
    }
}
