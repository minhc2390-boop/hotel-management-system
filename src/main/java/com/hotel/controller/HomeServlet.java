package com.hotel.controller;

import com.hotel.dao.RoomDAO;
import com.hotel.dao.RoomTypeDAO;
import com.hotel.dao.ServiceDAO;
import com.hotel.dao.UserDAO;
import com.hotel.dao.BillDAO;
import com.hotel.model.Room;
import com.hotel.model.RoomType;
import com.hotel.model.Service;
import com.hotel.model.User;
import com.hotel.model.Bill;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home", "/index"})
public class HomeServlet extends HttpServlet {
    private final RoomDAO roomDAO = new RoomDAO();
    private final RoomTypeDAO roomTypeDAO = new RoomTypeDAO();
    private final ServiceDAO serviceDAO = new ServiceDAO();
    private final UserDAO userDAO = new UserDAO();
    private final BillDAO billDAO = new BillDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // If Admin or Receptionist, show dashboard stats
        if (currentUser != null && ("Admin".equals(currentUser.getRole()) || "Receptionist".equals(currentUser.getRole()))) {
            List<Room> rooms = roomDAO.getAllRooms();
            List<User> users = userDAO.getAllUsers();
            List<Bill> bills = billDAO.getAllBills();
            List<Service> services = serviceDAO.getAllServices();
            
            //chống null khi login
            if (rooms == null) rooms = java.util.Collections.emptyList();
            if (users == null) users = java.util.Collections.emptyList();
            if (bills == null) bills = java.util.Collections.emptyList();
            if (services == null) services = java.util.Collections.emptyList();
            
            long availableCount = rooms.stream().filter(r -> "Available".equals(r.getStatus())).count();
            long bookedCount = rooms.stream().filter(r -> "Booked".equals(r.getStatus())).count();
            long maintenanceCount = rooms.stream().filter(r -> "Maintenance".equals(r.getStatus())).count();
            double totalRevenue = bills.stream().filter(b -> "Paid".equals(b.getStatus())).mapToDouble(Bill::getTotalAmount).sum();

            request.setAttribute("totalRooms", rooms.size());
            request.setAttribute("availableRooms", availableCount);
            request.setAttribute("bookedRooms", bookedCount);
            request.setAttribute("maintenanceRooms", maintenanceCount);
            request.setAttribute("totalUsers", users.size());
            request.setAttribute("totalBills", bills.size());
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("rooms", rooms);
            request.setAttribute("bills", bills);
            
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } else {
            // Public / Customer page: list available rooms and services
            List<Room> availableRooms = roomDAO.getAvailableRooms();
            List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
            List<Service> services = serviceDAO.getAllServices();
            
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("services", services);
            
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
