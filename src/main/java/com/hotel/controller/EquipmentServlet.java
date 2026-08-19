package com.hotel.controller;

import com.hotel.dao.EquipmentDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.model.Equipment;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.util.ParamUtil;

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
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = ParamUtil.getString(request, "action", "list");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        List<Room> allRooms = roomDAO.getAllRooms();
        request.setAttribute("rooms", allRooms);

        switch (action) {
            case "list":
                String keyword = ParamUtil.getString(request, "keyword", "");
                int filterRoomId = ParamUtil.getInt(request, "roomId", 0);
                String filterStatus = ParamUtil.getString(request, "status", "");

                List<Equipment> listEquipments = equipmentDAO.searchEquipments(
                        keyword,
                        filterRoomId != 0 ? filterRoomId : null,
                        !filterStatus.isEmpty() ? filterStatus : null
                );

                request.setAttribute("keyword", keyword);
                request.setAttribute("selectedRoomId", filterRoomId);
                request.setAttribute("selectedStatus", filterStatus);
                request.setAttribute("equipments", listEquipments);
                request.getRequestDispatcher("/admin/equipments.jsp").forward(request, response);
                break;

            case "add":
                int defaultRoomId = ParamUtil.getInt(request, "roomId", 0);
                request.setAttribute("defaultRoomId", defaultRoomId);
                request.getRequestDispatcher("/admin/equipment-form.jsp").forward(request, response);
                break;

            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Equipment existingEquipment = equipmentDAO.getEquipmentById(editId);
                if (existingEquipment == null) {
                    response.sendRedirect(request.getContextPath() + "/equipments?action=list");
                    return;
                }
                request.setAttribute("equipment", existingEquipment);
                request.getRequestDispatcher("/admin/equipment-form.jsp").forward(request, response);
                break;

            case "delete":
                int deleteId = ParamUtil.getInt(request, "id", 0);
                int returnRoomId = ParamUtil.getInt(request, "roomId", 0);
                if (deleteId > 0) {
                    equipmentDAO.deleteEquipment(deleteId);
                }
                if (returnRoomId > 0) {
                    response.sendRedirect(request.getContextPath() + "/rooms?action=edit&id=" + returnRoomId + "#equipments");
                } else {
                    response.sendRedirect(request.getContextPath() + "/equipments?action=list");
                }
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
        response.setCharacterEncoding("UTF-8");

        String action = ParamUtil.getString(request, "action", "");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !"Admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String name = ParamUtil.getString(request, "name", "");
        String unit = ParamUtil.getString(request, "unit", "Cái");
        String status = ParamUtil.getString(request, "status", "Hoạt động tốt");
        String description = ParamUtil.getString(request, "description", "");
        int totalQuantity = Math.max(1, ParamUtil.getInt(request, "totalQuantity", 1));
        int roomId = ParamUtil.getInt(request, "roomId", 0);
        String returnTo = ParamUtil.getString(request, "returnTo", "");

        Room assignedRoom = null;
        if (roomId > 0) {
            assignedRoom = roomDAO.getRoomById(roomId);
        }

        if ("insert".equals(action)) {
            if (!name.isEmpty()) {
                Equipment equipment = new Equipment(assignedRoom, name, totalQuantity, unit, status, description);
                equipmentDAO.insertEquipment(equipment);
            }
            if ("room".equals(returnTo) && roomId > 0) {
                response.sendRedirect(request.getContextPath() + "/rooms?action=edit&id=" + roomId + "#equipments");
            } else if (roomId > 0) {
                response.sendRedirect(request.getContextPath() + "/equipments?action=list&roomId=" + roomId);
            } else {
                response.sendRedirect(request.getContextPath() + "/equipments?action=list");
            }

        } else if ("update".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            if (id > 0 && !name.isEmpty()) {
                Equipment equipment = new Equipment(id, assignedRoom, name, totalQuantity, unit, status, description);
                equipmentDAO.updateEquipment(equipment);
            }
            if ("room".equals(returnTo) && roomId > 0) {
                response.sendRedirect(request.getContextPath() + "/rooms?action=edit&id=" + roomId + "#equipments");
            } else if (roomId > 0) {
                response.sendRedirect(request.getContextPath() + "/equipments?action=list&roomId=" + roomId);
            } else {
                response.sendRedirect(request.getContextPath() + "/equipments?action=list");
            }
        } else {
            response.sendRedirect(request.getContextPath() + "/equipments?action=list");
        }
    }
}
