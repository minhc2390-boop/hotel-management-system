package com.hotel.controller;

import com.hotel.dao.BuffetMenuDAO;
import com.hotel.model.BuffetMenuItem;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;
import com.hotel.util.ParamUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;

@WebServlet(name = "BuffetServlet", urlPatterns = {"/buffet"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,      // 1MB
    maxFileSize = 10 * 1024 * 1024,        // 10MB
    maxRequestSize = 15 * 1024 * 1024      // 15MB
)
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

        if ("upload-image".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            try {
                Part filePart = null;
                try {
                    filePart = request.getPart("imageFile");
                } catch (Exception ignored) {}

                if (filePart == null || filePart.getSize() == 0) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Không tìm thấy file ảnh tải lên.\"}");
                    return;
                }
                String uploadedUrl = handleFileUpload(request, filePart);
                if (uploadedUrl == null) {
                    response.getWriter().write("{\"success\":false,\"message\":\"Chỉ chấp nhận file ảnh định dạng JPG, JPEG, PNG, WEBP, GIF (tối đa 10MB).\"}");
                    return;
                }
                response.getWriter().write("{\"success\":true,\"imageUrl\":\"" + uploadedUrl + "\"}");
            } catch (Exception e) {
                e.printStackTrace();
                response.getWriter().write("{\"success\":false,\"message\":\"Lỗi hệ thống khi tải ảnh: " + escapeJson(e.getMessage()) + "\"}");
            }
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

        String imageUrl = ParamUtil.getString(request, "imageUrl", "");
        try {
            Part filePart = request.getPart("imageFile");
            if (filePart != null && filePart.getSize() > 0) {
                String uploadedUrl = handleFileUpload(request, filePart);
                if (uploadedUrl != null && !uploadedUrl.isEmpty()) {
                    imageUrl = uploadedUrl;
                }
            }
        } catch (Exception ignored) {}

        item.setImageUrl(imageUrl);
        item.setStatus(ParamUtil.getString(request, "status", "Active"));
        item.setSortOrder(Math.max(0, ParamUtil.getInt(request, "sortOrder", 0)));
        return item;
    }

    private String handleFileUpload(HttpServletRequest request, Part filePart) {
        try {
            String fileName = getSubmittedFileName(filePart);
            if (fileName == null || fileName.trim().isEmpty()) {
                return null;
            }
            String ext = getFileExtension(fileName).toLowerCase();
            if (!ext.matches("^(png|jpg|jpeg|webp|gif)$")) {
                return null;
            }
            String safeBaseName = sanitizeFileName(fileName);
            String savedFileName = "dish_" + System.currentTimeMillis() + "_" + safeBaseName + "." + ext;

            File savedDest = null;
            String uploadPath = request.getServletContext().getRealPath("/images/buffet");
            if (uploadPath != null) {
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) {
                    uploadDir.mkdirs();
                }
                savedDest = new File(uploadDir, savedFileName);
                filePart.write(savedDest.getAbsolutePath());
            }

            // Sync to source workspace folder if available in development environment
            try {
                File srcDir = new File("src/main/webapp/images/buffet");
                if (!srcDir.exists()) {
                    String userDir = System.getProperty("user.dir");
                    if (userDir != null) {
                        File check = new File(userDir, "src/main/webapp/images/buffet");
                        if (check.exists()) srcDir = check;
                    }
                }
                if (srcDir.exists() && savedDest != null && savedDest.exists()) {
                    File srcDest = new File(srcDir, savedFileName);
                    Files.copy(savedDest.toPath(), srcDest.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            } catch (Exception ignored) {}

            return "images/buffet/" + savedFileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    private String getSubmittedFileName(Part part) {
        if (part == null) return null;
        try {
            String submitted = part.getSubmittedFileName();
            if (submitted != null && !submitted.isEmpty()) return submitted;
        } catch (Throwable ignored) {}
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String cd : header.split(";")) {
                if (cd.trim().startsWith("filename")) {
                    String fileName = cd.substring(cd.indexOf('=') + 1).trim().replace("\"", "");
                    return fileName.substring(fileName.lastIndexOf('/') + 1).substring(fileName.lastIndexOf('\\') + 1);
                }
            }
        }
        return null;
    }

    private String getFileExtension(String fileName) {
        int dot = fileName.lastIndexOf('.');
        return (dot >= 0 && dot < fileName.length() - 1) ? fileName.substring(dot + 1) : "";
    }

    private String sanitizeFileName(String fileName) {
        int dot = fileName.lastIndexOf('.');
        String base = (dot > 0) ? fileName.substring(0, dot) : fileName;
        base = base.replaceAll("[^a-zA-Z0-9_-]", "_");
        if (base.length() > 25) {
            base = base.substring(0, 25);
        }
        if (base.isEmpty()) {
            base = "image";
        }
        return base;
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", " ").replace("\r", "");
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
                && !item.getImageUrl().startsWith("uploads/")
                && !item.getImageUrl().startsWith("http://")
                && !item.getImageUrl().startsWith("https://")) {
            return "Ảnh không hợp lệ.";
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
