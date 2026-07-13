package com.hotel.controller;

import com.hotel.dao.ServiceDAO;
import com.hotel.model.Service;
import com.hotel.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "ServiceServlet", urlPatterns = {"/services"})
public class ServiceServlet extends HttpServlet {
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "list";
        }

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Check auth: only Admin/Receptionist can view/manage services list inside management area
        if (currentUser == null || (!"Admin".equals(currentUser.getRole()) && !"Receptionist".equals(currentUser.getRole()))) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                List<Service> listServices = serviceDAO.getAllServices();
                request.setAttribute("services", listServices);
                request.getRequestDispatcher("/admin/services.jsp").forward(request, response);
                break;
                
            case "add":
                request.getRequestDispatcher("/admin/service-form.jsp").forward(request, response);
                break;
                
            case "edit":
                int editId = Integer.parseInt(request.getParameter("id"));
                Service existingService = serviceDAO.getServiceById(editId);
                request.setAttribute("service", existingService);
                request.getRequestDispatcher("/admin/service-form.jsp").forward(request, response);
                break;
                
            case "delete":
                int deleteId = Integer.parseInt(request.getParameter("id"));
                serviceDAO.deleteService(deleteId);
                response.sendRedirect(request.getContextPath() + "/services?action=list");
                break;
                
            default:
                response.sendRedirect(request.getContextPath() + "/services?action=list");
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
            double price = Double.parseDouble(request.getParameter("price"));
            String description = request.getParameter("description");
            
            Service service = new Service(name, price, description);
            serviceDAO.insertService(service);
            response.sendRedirect(request.getContextPath() + "/services?action=list");
            
        } else if ("update".equals(action)) {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            double price = Double.parseDouble(request.getParameter("price"));
            String description = request.getParameter("description");
            
            Service service = new Service(id, name, price, description);
            serviceDAO.updateService(service);
            response.sendRedirect(request.getContextPath() + "/services?action=list");
        }
    }
}
