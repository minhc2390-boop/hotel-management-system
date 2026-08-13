package com.hotel.controller;

import com.hotel.dao.EquipmentDAO;
import com.hotel.dao.RoomDAO;
import com.hotel.dao.RoomTypeDAO;
import com.hotel.model.Equipment;
import com.hotel.model.Room;
import com.hotel.model.RoomType;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "RoomServlet", urlPatterns = {"/rooms"})
public class RoomServlet extends HttpServlet {
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final EquipmentDAO equipmentDAO = new EquipmentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = ParamUtil.getString(request, "action", "list");

        // Cho phép khách vãng lai (chưa đăng nhập) xem và đặt phòng
        if ("bookForm".equalsIgnoreCase(action) || "book".equalsIgnoreCase(action)) {
            int bookRoomId = ParamUtil.getInt(request, "roomId", 0);
            Room bookRoom = roomDAO.getRoomById(bookRoomId);
            if (bookRoom == null) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            request.setAttribute("room", bookRoom);
            request.getRequestDispatcher("/booking.jsp").forward(request, response);
            return;
        }

        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        String role = currentUser != null ? currentUser.getRole() : "";

        if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                List<Room> listRooms = roomDAO.getAllRooms();
                request.setAttribute("rooms", listRooms);
                request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
                break;
                
            case "add":
                List<RoomType> listTypes = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("roomTypes", listTypes);
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                break;
                
            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Room existingRoom = roomDAO.getRoomById(editId);
                if (existingRoom == null) {
                    response.sendRedirect(request.getContextPath() + "/rooms?action=list");
                    return;
                }
                List<RoomType> types = roomTypeDAO.getAllRoomTypes();
                List<Equipment> roomEquipments = equipmentDAO.getEquipmentsByRoomId(editId);
                request.setAttribute("room", existingRoom);
                request.setAttribute("roomTypes", types);
                request.setAttribute("roomEquipments", roomEquipments);
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                break;
                
            case "delete":
                if ("Admin".equalsIgnoreCase(role)) {
                    int deleteId = ParamUtil.getInt(request, "id", 0);
                    if (deleteId > 0) {
                        roomDAO.deleteRoom(deleteId);
                    }
                }
                response.sendRedirect(request.getContextPath() + "/rooms?action=list");
                break;
                
            case "bookForm":
                int bookRoomId = ParamUtil.getInt(request, "roomId", 0);
                Room bookRoom = roomDAO.getRoomById(bookRoomId);
                request.setAttribute("room", bookRoom);
                request.getRequestDispatcher("/booking.jsp").forward(request, response);
                break;
                
            case "map":
                List<Room> mapRooms = roomDAO.getAllRooms();
                request.setAttribute("rooms", mapRooms);
                request.getRequestDispatcher("/admin/room-map.jsp").forward(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/rooms?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        String action = ParamUtil.getString(request, "action", "");
        
        if (!AuthUtil.isAuthenticated(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User currentUser = AuthUtil.getUser(request);
        String role = currentUser != null ? currentUser.getRole() : "";

        if (!"Admin".equalsIgnoreCase(role) && !"Receptionist".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        if ("insert".equals(action)) {
            String roomNumber = ParamUtil.getString(request, "roomNumber", "");
            int roomTypeId = ParamUtil.getInt(request, "roomTypeId", 0);
            String status = ParamUtil.getString(request, "status", "Available");
            String description = ParamUtil.getString(request, "description", "");

            if (roomNumber.isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập số phòng / mã phòng!");
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                return;
            }

            if (roomTypeId <= 0) {
                request.setAttribute("error", "Vui lòng chọn loại phòng phù hợp!");
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                return;
            }

            // Check if roomNumber already exists
            Room existing = roomDAO.getRoomByNumber(roomNumber);
            if (existing != null) {
                request.setAttribute("error", "Số phòng #" + roomNumber + " đã tồn tại trong hệ thống! Vui lòng chọn số phòng khác.");
                Room draft = new Room(roomNumber, roomTypeId, status, description);
                request.setAttribute("room", draft);
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                return;
            }

            Room room = new Room(roomNumber, roomTypeId, status, description);

            // Extract initial equipment list for this new room
            List<Equipment> equipmentList = extractEquipmentsFromRequest(request);
            boolean created = roomDAO.insertRoomWithEquipments(room, equipmentList);

            if (created) {
                response.sendRedirect(request.getContextPath() + "/rooms?action=list");
            } else {
                request.setAttribute("error", "Không thể tạo phòng lúc này. Vui lòng kiểm tra lại thông tin!");
                Room draft = new Room(roomNumber, roomTypeId, status, description);
                request.setAttribute("room", draft);
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
            }

        } else if ("update".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            String roomNumber = ParamUtil.getString(request, "roomNumber", "");
            int roomTypeId = ParamUtil.getInt(request, "roomTypeId", 0);
            String status = ParamUtil.getString(request, "status", "Available");
            String description = ParamUtil.getString(request, "description", "");

            if (roomNumber.isEmpty()) {
                request.setAttribute("error", "Vui lòng nhập số phòng!");
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                return;
            }

            // Check if roomNumber changed to an existing room number of another room
            Room existing = roomDAO.getRoomByNumber(roomNumber);
            if (existing != null && existing.getId() != id) {
                request.setAttribute("error", "Số phòng #" + roomNumber + " đã trùng với phòng khác trong hệ thống!");
                Room draft = new Room(id, roomNumber, roomTypeId, status, description);
                request.setAttribute("room", draft);
                request.setAttribute("roomTypes", roomTypeDAO.getAllRoomTypes());
                request.setAttribute("roomEquipments", equipmentDAO.getEquipmentsByRoomId(id));
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                return;
            }

            Room room = new Room(id, roomNumber, roomTypeId, status, description);
            roomDAO.updateRoom(room);

            // Check if user also added an equipment from the edit room form
            String newEqName = ParamUtil.getString(request, "newEqName", "");
            if (!newEqName.isEmpty()) {
                int newEqQty = Math.max(1, ParamUtil.getInt(request, "newEqQuantity", 1));
                String newEqUnit = ParamUtil.getString(request, "newEqUnit", "Cái");
                String newEqStatus = ParamUtil.getString(request, "newEqStatus", "Hoạt động tốt");
                String newEqDesc = ParamUtil.getString(request, "newEqDescription", "");
                Equipment newEq = new Equipment(room, newEqName, newEqQty, newEqUnit, newEqStatus, newEqDesc);
                equipmentDAO.insertEquipment(newEq);
            }

            response.sendRedirect(request.getContextPath() + "/rooms?action=list");
        }
    }

    private List<Equipment> extractEquipmentsFromRequest(HttpServletRequest request) {
        List<Equipment> list = new ArrayList<>();
        String[] eqNames = request.getParameterValues("eqName");
        String[] eqQtys = request.getParameterValues("eqQuantity");
        String[] eqUnits = request.getParameterValues("eqUnit");
        String[] eqStatuses = request.getParameterValues("eqStatus");
        String[] eqDescs = request.getParameterValues("eqDescription");
        String[] eqSelected = request.getParameterValues("eqEnabled");

        if (eqNames != null && eqNames.length > 0) {
            for (int i = 0; i < eqNames.length; i++) {
                String name = eqNames[i] != null ? eqNames[i].trim() : "";
                if (name.isEmpty()) continue;

                // If checkbox template is used, check if selected
                if (eqSelected != null) {
                    boolean isChecked = false;
                    for (String sel : eqSelected) {
                        if (String.valueOf(i).equals(sel) || name.equals(sel)) {
                            isChecked = true;
                            break;
                        }
                    }
                    if (!isChecked) continue;
                }

                int qty = 1;
                if (eqQtys != null && i < eqQtys.length) {
                    try { qty = Math.max(1, Integer.parseInt(eqQtys[i].trim())); } catch (Exception ignored) {}
                }
                String unit = (eqUnits != null && i < eqUnits.length && eqUnits[i] != null && !eqUnits[i].trim().isEmpty())
                        ? eqUnits[i].trim() : "Cái";
                String status = (eqStatuses != null && i < eqStatuses.length && eqStatuses[i] != null && !eqStatuses[i].trim().isEmpty())
                        ? eqStatuses[i].trim() : "Hoạt động tốt";
                String desc = (eqDescs != null && i < eqDescs.length && eqDescs[i] != null)
                        ? eqDescs[i].trim() : "";

                list.add(new Equipment(name, qty, unit, status, desc));
            }
        }
        return list;
    }
}
