<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.dao.RoomDAO" %>
<%@ page import="com.hotel.model.Room" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Rooms</title>
</head>
<body>
    <h1>Test getAvailableRooms()</h1>
    <%
        try {
            RoomDAO dao = new RoomDAO();
            List<Room> list = dao.getAvailableRooms();
            if (list == null) {
                out.println("<p style='color:red;'>Result is NULL</p>");
            } else {
                out.println("<p style='color:green;'>Found " + list.size() + " rooms</p>");
                out.println("<ul>");
                for (Room r : list) {
                    out.println("<li>Room: " + r.getRoomNumber() + ", Status: " + r.getStatus() + ", Type: " + r.getRoomType().getName() + "</li>");
                }
                out.println("</ul>");
            }
        } catch (Exception e) {
            out.println("<pre style='color:red;'>");
            e.printStackTrace(new java.io.PrintWriter(out));
            out.println("</pre>");
        }
    %>
</body>
</html>
