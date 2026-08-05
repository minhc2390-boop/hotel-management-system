package com.hotel.controller;

import com.hotel.dao.EquipmentDAO;
import com.hotel.model.Equipment;
import com.hotel.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "EquipmentServlet", urlPatterns = {"/equipments"})
public class EquipmentServlet extends HttpServlet {
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();

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
                String keyword = request.getParameter("keyword");
                List<Equipment> listEquipments;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    listEquipments = equipmentDAO.searchEquipments(keyword.trim());
                    request.setAttribute("keyword", keyword.trim());
                } else {
                    listEquipments = equipmentDAO.getAllEquipments();
                }
                request.setAttribute("equipments", listEquipments);
                request.getRequestDispatcher("/admin/equipments.jsp").forward(request, response);
                break;

            case "add":
                request.getRequestDispatcher("/admin/equipment-form.jsp").forward(request, response);
                break;

            case "edit":
                try {
                    int editId = Integer.parseInt(request.getParameter("id"));
                    Equipment existingEquipment = equipmentDAO.getEquipmentById(editId);
                    request.setAttribute("equipment", existingEquipment);
                    request.getRequestDispatcher("/admin/equipment-form.jsp").forward(request, response);
                } catch (NumberFormatException e) {
                    response.sendRedirect(request.getContextPath() + "/equipments?action=list");
                }
                break;

            case "delete":
                try {
                    int deleteId = Integer.parseInt(request.getParameter("id"));
                    equipmentDAO.deleteEquipment(deleteId);
                } catch (NumberFormatException e) {
                    e.printStackTrace();
                }
                response.sendRedirect(request.getContextPath() + "/equipments?action=list");
                break;

            default:
                response.sendRedirect(request.getContextPath() + "/equipments?action=list");
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

        String name = request.getParameter("name");
        String unit = request.getParameter("unit");
        String status = request.getParameter("status");
        String description = request.getParameter("description");
        
        int totalQuantity = 0;
        try {
            totalQuantity = Integer.parseInt(request.getParameter("totalQuantity"));
        } catch (NumberFormatException e) {
            totalQuantity = 0;
        }

        if ("insert".equals(action)) {
            Equipment equipment = new Equipment(name, totalQuantity, unit, status, description);
            equipmentDAO.insertEquipment(equipment);
            response.sendRedirect(request.getContextPath() + "/equipments?action=list");

        } else if ("update".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Equipment equipment = new Equipment(id, name, totalQuantity, unit, status, description);
                equipmentDAO.updateEquipment(equipment);
            } catch (NumberFormatException e) {
                e.printStackTrace();
            }
            response.sendRedirect(request.getContextPath() + "/equipments?action=list");
        }
    }
}
