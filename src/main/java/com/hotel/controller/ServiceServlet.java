package com.hotel.controller;

import com.hotel.dao.ServiceDAO;
import com.hotel.model.Service;
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

@WebServlet(name = "ServiceServlet", urlPatterns = {"/services"})
public class ServiceServlet extends HttpServlet {
    private final ServiceDAO serviceDAO = new ServiceDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "list");

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
                List<Service> listServices = serviceDAO.getAllServices();
                request.setAttribute("services", listServices);
                request.getRequestDispatcher("/admin/services.jsp").forward(request, response);
                break;
                
            case "add":
                request.getRequestDispatcher("/admin/service-form.jsp").forward(request, response);
                break;
                
            case "edit":
                int editId = ParamUtil.getInt(request, "id", 0);
                Service existingService = serviceDAO.getServiceById(editId);
                request.setAttribute("service", existingService);
                request.getRequestDispatcher("/admin/service-form.jsp").forward(request, response);
                break;
                
            case "delete":
                int deleteId = ParamUtil.getInt(request, "id", 0);
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
        String action = ParamUtil.getString(request, "action", "");

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
            double price = ParamUtil.getDouble(request, "price", 0.0);
            String description = ParamUtil.getString(request, "description", "");
            String status = ParamUtil.getString(request, "status", "Active");
            String unit = ParamUtil.getString(request, "unit", "Lượt");
            
            Service service = new Service(name, price, description, status, unit);
            serviceDAO.insertService(service);
            response.sendRedirect(request.getContextPath() + "/services?action=list");
            
        } else if ("update".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            String name = ParamUtil.getString(request, "name", "");
            double price = ParamUtil.getDouble(request, "price", 0.0);
            String description = ParamUtil.getString(request, "description", "");
            String status = ParamUtil.getString(request, "status", "Active");
            String unit = ParamUtil.getString(request, "unit", "Lượt");
            
            Service service = new Service(id, name, price, description, status, unit);
            serviceDAO.updateService(service);
            response.sendRedirect(request.getContextPath() + "/services?action=list");
        }
    }
}
