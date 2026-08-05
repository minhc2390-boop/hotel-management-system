package com.hotel.controller;

import com.hotel.dao.BuffetMenuDAO;
import com.hotel.model.BuffetMenuItem;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "BuffetServlet", urlPatterns = {"/buffet"})
public class BuffetServlet extends HttpServlet {

    private final BuffetMenuDAO buffetMenuDAO = new BuffetMenuDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = ParamUtil.getString(request, "action", "view");

        if ("view".equals(action)) {
            LocalDate selectedDate = parseDate(request.getParameter("date"), LocalDate.now());
            request.setAttribute("selectedDate", selectedDate);
            request.setAttribute("menuItems", buffetMenuDAO.getActiveItemsByDate(selectedDate));
            request.getRequestDispatcher("/buffet.jsp").forward(request, response);
            return;
        }

        if (!isManager(request)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        switch (action) {
            case "list":
                LocalDate filterDate = parseOptionalDate(request.getParameter("date"));
                List<BuffetMenuItem> items = buffetMenuDAO.getItemsForManagement(filterDate);
                request.setAttribute("filterDate", filterDate);
                request.setAttribute("menuItems", items);
                request.getRequestDispatcher("/admin/buffet-menu.jsp").forward(request, response);
                break;
            case "add":
                request.setAttribute("defaultDate",
                        parseDate(request.getParameter("date"), LocalDate.now()));
                request.getRequestDispatcher("/admin/buffet-form.jsp").forward(request, response);
                break;
            case "edit":
                int id = ParamUtil.getInt(request, "id", 0);
                BuffetMenuItem item = buffetMenuDAO.getById(id);
                if (item == null) {
                    response.sendRedirect(request.getContextPath() + "/buffet?action=list");
                    return;
                }
                request.setAttribute("menuItem", item);
                request.getRequestDispatcher("/admin/buffet-form.jsp").forward(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/buffet?action=list");
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isManager(request)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = ParamUtil.getString(request, "action", "");
        if ("delete".equals(action)) {
            int id = ParamUtil.getInt(request, "id", 0);
            buffetMenuDAO.delete(id);
            response.sendRedirect(request.getContextPath() + "/buffet?action=list");
            return;
        }

        BuffetMenuItem item = buildItem(request);
        String validationError = validate(item);
        if (validationError != null) {
            if ("update".equals(action)) {
                item.setId(ParamUtil.getInt(request, "id", 0));
            }
            request.setAttribute("menuItem", item);
            request.setAttribute("error", validationError);
            request.getRequestDispatcher("/admin/buffet-form.jsp").forward(request, response);
            return;
        }

        boolean success;
        if ("insert".equals(action)) {
            success = buffetMenuDAO.insert(item);
        } else if ("update".equals(action)) {
            item.setId(ParamUtil.getInt(request, "id", 0));
            success = item.getId() > 0 && buffetMenuDAO.update(item);
        } else {
            response.sendRedirect(request.getContextPath() + "/buffet?action=list");
            return;
        }

        if (!success) {
            request.setAttribute("menuItem", item);
            request.setAttribute("error", "Không thể lưu món buffet. Vui lòng kiểm tra dữ liệu và thử lại.");
            request.getRequestDispatcher("/admin/buffet-form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath()
                + "/buffet?action=list&date=" + item.getMenuDate() + "&saved=1");
    }

    private BuffetMenuItem buildItem(HttpServletRequest request) {
        BuffetMenuItem item = new BuffetMenuItem();
        item.setMenuDate(parseOptionalDate(request.getParameter("menuDate")));
        item.setMealPeriod(ParamUtil.getString(request, "mealPeriod", ""));
        item.setCategory(ParamUtil.getString(request, "category", ""));
        item.setDishName(ParamUtil.getString(request, "dishName", ""));
        item.setDescription(ParamUtil.getString(request, "description", ""));
        item.setImageUrl(ParamUtil.getString(request, "imageUrl", ""));
        item.setStatus(ParamUtil.getString(request, "status", "Active"));
        item.setSortOrder(Math.max(0, ParamUtil.getInt(request, "sortOrder", 0)));
        return item;
    }

    private String validate(BuffetMenuItem item) {
        if (item.getMenuDate() == null) return "Vui lòng chọn ngày áp dụng thực đơn.";
        if (!isAllowed(item.getMealPeriod(), "Breakfast", "Lunch", "Dinner")) {
            return "Buổi phục vụ không hợp lệ.";
        }
        if (item.getCategory().isEmpty() || item.getCategory().length() > 80) {
            return "Nhóm món phải có từ 1 đến 80 ký tự.";
        }
        if (item.getDishName().isEmpty() || item.getDishName().length() > 160) {
            return "Tên món phải có từ 1 đến 160 ký tự.";
        }
        if (item.getDescription().length() > 1000) {
            return "Mô tả không được vượt quá 1000 ký tự.";
        }
        if (item.getImageUrl().length() > 500) {
            return "Đường dẫn ảnh không được vượt quá 500 ký tự.";
        }
        if (!item.getImageUrl().isEmpty()
                && !item.getImageUrl().startsWith("images/")
                && !item.getImageUrl().startsWith("/images/")
                && !item.getImageUrl().startsWith("https://")) {
            return "Ảnh phải là đường dẫn trong thư mục images/ hoặc URL HTTPS.";
        }
        if (!isAllowed(item.getStatus(), "Active", "Inactive")) {
            return "Trạng thái không hợp lệ.";
        }
        return null;
    }

    private boolean isAllowed(String value, String... allowedValues) {
        for (String allowed : allowedValues) {
            if (allowed.equals(value)) return true;
        }
        return false;
    }

    private boolean isManager(HttpServletRequest request) {
        User user = AuthUtil.getUser(request);
        return user != null
                && ("Admin".equalsIgnoreCase(user.getRole())
                || "Receptionist".equalsIgnoreCase(user.getRole()));
    }

    private LocalDate parseDate(String value, LocalDate fallback) {
        LocalDate parsed = parseOptionalDate(value);
        return parsed != null ? parsed : fallback;
    }

    private LocalDate parseOptionalDate(String value) {
        if (value == null || value.trim().isEmpty()) return null;
        try {
            return LocalDate.parse(value.trim());
        } catch (DateTimeParseException ignored) {
            return null;
        }
    }
}
