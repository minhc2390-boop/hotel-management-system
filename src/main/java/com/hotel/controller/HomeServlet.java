package com.hotel.controller;

import com.hotel.dao.NotificationDAO;
import com.hotel.model.HotelNotification;
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
import com.hotel.util.AuthUtil;

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
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        User currentUser = AuthUtil.getUser(request);
        List<HotelNotification> latestNotifications = notificationDAO.getTop5Newest();
        if (latestNotifications == null) latestNotifications = java.util.Collections.emptyList();

        // If Admin or Receptionist, show dashboard stats
        if (currentUser != null && (currentUser.getRole() != null && 
            ("Admin".equalsIgnoreCase(currentUser.getRole()) || "Receptionist".equalsIgnoreCase(currentUser.getRole()) || "Manager".equalsIgnoreCase(currentUser.getRole())))) {
            List<Room> rooms = roomDAO.getAllRooms();
            List<User> users = userDAO.getAllUsers();
            List<Bill> bills = billDAO.getAllBills();
            List<Service> services = serviceDAO.getAllServices();
            
            // Chống null khi login
            if (rooms == null) rooms = java.util.Collections.emptyList();
            if (users == null) users = java.util.Collections.emptyList();
            if (bills == null) bills = java.util.Collections.emptyList();
            if (services == null) services = java.util.Collections.emptyList();
            
            long availableCount = rooms.stream().filter(r -> r != null && "Available".equalsIgnoreCase(r.getStatus())).count();
            long bookedCount = rooms.stream().filter(r -> r != null && "Booked".equalsIgnoreCase(r.getStatus())).count();
            long maintenanceCount = rooms.stream().filter(r -> r != null && "Maintenance".equalsIgnoreCase(r.getStatus())).count();
            double totalRevenue = bills.stream().filter(b -> b != null && "Paid".equalsIgnoreCase(b.getStatus())).mapToDouble(Bill::getTotalAmount).sum();

            request.setAttribute("totalRooms", rooms.size());
            request.setAttribute("availableRooms", availableCount);
            request.setAttribute("bookedRooms", bookedCount);
            request.setAttribute("maintenanceRooms", maintenanceCount);
            request.setAttribute("totalUsers", users.size());
            request.setAttribute("totalBills", bills.size());
            request.setAttribute("totalRevenue", totalRevenue);
            request.setAttribute("rooms", rooms);
            request.setAttribute("bills", bills);
            request.setAttribute("latestNotifications", latestNotifications);
            
            request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
        } else {
            // Public / Customer page: list available rooms and services
            List<Room> availableRooms = roomDAO.getAvailableRooms();
            List<RoomType> roomTypes = roomTypeDAO.getAllRoomTypes();
            List<Service> services = serviceDAO.getAllServices();
            
            request.setAttribute("availableRooms", availableRooms);
            request.setAttribute("roomTypes", roomTypes);
            request.setAttribute("services", services);
            request.setAttribute("latestNotifications", latestNotifications);
            
            request.getRequestDispatcher("/index.jsp").forward(request, response);
        }
    }
}
