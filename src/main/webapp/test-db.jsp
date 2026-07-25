<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="com.hotel.dao.DBContext" %>
<%@ page import="com.hotel.model.User" %>
<%@ page import="javax.persistence.EntityManager" %>
<%@ page import="java.util.List" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test DB Users</title>
</head>
<body>
    <h2>User List in Database:</h2>
    <table border="1">
        <tr>
            <th>ID</th>
            <th>Username</th>
            <th>Email</th>
            <th>Password</th>
            <th>Role</th>
        </tr>
        <%
            EntityManager em = null;
            try {
                em = DBContext.getEntityManager();
                List<User> users = em.createQuery("SELECT u FROM User u", User.class).getResultList();
                for (User u : users) {
        %>
        <tr>
            <td><%= u.getId() %></td>
            <td><%= u.getUsername() %></td>
            <td><%= u.getEmail() %></td>
            <td><%= u.getPassword() %></td>
            <td><%= u.getRole() %></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
                e.printStackTrace(new java.io.PrintWriter(out));
            } finally {
                if (em != null) em.close();
            }
        %>
    </table>
</body>
</html>
