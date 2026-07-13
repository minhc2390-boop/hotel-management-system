package com.hotel.controller;

import com.hotel.dao.RoomDAO;
import com.hotel.dao.RoomTypeDAO;
import com.hotel.model.Room;
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

@WebServlet(name = "RoomServlet", urlPatterns = {"/rooms"})
public class RoomServlet extends HttpServlet {
    private final RoomDAO roomDAO = new RoomDAO();
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

        switch (action) {
            case "list":
                // Check authorization
                if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                List<Room> listRooms = roomDAO.getAllRooms();
                request.setAttribute("rooms", listRooms);
                request.getRequestDispatcher("/admin/rooms.jsp").forward(request, response);
                break;
                
            case "add":
                if (currentUser == null || !"Admin".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                List<RoomType> listTypes = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("roomTypes", listTypes);
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                break;
                
            case "edit":
                if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                int editId = Integer.parseInt(request.getParameter("id"));
                Room existingRoom = roomDAO.getRoomById(editId);
                List<RoomType> types = roomTypeDAO.getAllRoomTypes();
                request.setAttribute("room", existingRoom);
                request.setAttribute("roomTypes", types);
                request.getRequestDispatcher("/admin/room-form.jsp").forward(request, response);
                break;
                
            case "delete":
                if (currentUser == null || !"Admin".equals(currentUser.getRole())) {
                    response.sendRedirect(request.getContextPath() + "/home");
                    return;
                }
                int deleteId = Integer.parseInt(request.getParameter("id"));
                roomDAO.deleteRoom(deleteId);
                response.sendRedirect(request.getContextPath() + "/rooms?action=list");
                break;
                
            case "bookForm":
                if (currentUser == null) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }
                int bookRoomId = Integer.parseInt(request.getParameter("roomId"));
                Room bookRoom = roomDAO.getRoomById(bookRoomId);
                request.setAttribute("room", bookRoom);
                request.getRequestDispatcher("/booking.jsp").forward(request, response);
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/home");
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
        
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("insert".equals(action)) {
            if (!"Admin".equals(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            String roomNumber = request.getParameter("roomNumber");
            int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
            String status = request.getParameter("status");
            String description = request.getParameter("description");
            
            Room room = new Room(roomNumber, roomTypeId, status, description);
            roomDAO.insertRoom(room);
            response.sendRedirect(request.getContextPath() + "/rooms?action=list");
            
        } else if ("update".equals(action)) {
            if (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole())) {
                response.sendRedirect(request.getContextPath() + "/home");
                return;
            }
            int id = Integer.parseInt(request.getParameter("id"));
            String roomNumber = request.getParameter("roomNumber");
            int roomTypeId = Integer.parseInt(request.getParameter("roomTypeId"));
            String status = request.getParameter("status");
            String description = request.getParameter("description");
            
            Room room = new Room(id, roomNumber, roomTypeId, status, description);
            roomDAO.updateRoom(room);
            response.sendRedirect(request.getContextPath() + "/rooms?action=list");
        }
    }
}
