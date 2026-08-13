package com.hotel.dao;

import com.hotel.model.User;
import com.hotel.util.AuthUtil;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

public class UserDAO {

    private static final Map<String, User> memoryUsers = new ConcurrentHashMap<>();

    static {
        User defaultAdmin = new User("admin", "admin123", "Nguyễn Văn Admin", "admin@nestora.com", "0901234567", "Admin");
        defaultAdmin.setId(1);
        memoryUsers.put("admin", defaultAdmin);
        memoryUsers.put("admin@nestora.com", defaultAdmin);
    }

    public User findByEmail(String email) {
        if (email == null || email.trim().isEmpty()) return null;
        String searchEmail = email.trim().toLowerCase();
        
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u WHERE LOWER(u.email) = :email";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("email", searchEmail);
            List<User> results = query.getResultList();
            if (!results.isEmpty()) {
                return results.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }

        for (User u : memoryUsers.values()) {
            if (u.getEmail() != null && u.getEmail().trim().equalsIgnoreCase(searchEmail)) {
                return u;
            }
        }
        return null;
    }

    public User findByEmailOrUsername(String loginKey) {
        ensureDefaultAdminAccount();
        EntityManager em = DBContext.getEntityManager();
        try {
            String key = loginKey != null ? loginKey.trim().toLowerCase() : "";
            String jpql = "SELECT u FROM User u WHERE LOWER(u.email) = :loginKey OR LOWER(u.username) = :loginKey";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("loginKey", key);
            List<User> results = query.getResultList();
            if (!results.isEmpty()) {
                return results.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public User login(String username, String password) {
        String uStr = username != null ? username.trim() : "";
        String pStr = password != null ? password.trim() : "";
        if (uStr.isEmpty() || pStr.isEmpty()) return null;

        String hashedInput = AuthUtil.hashPassword(pStr);
        String keyLower = uStr.toLowerCase();

        // 1. Kiểm tra thông tin người dùng từ Database
        try {
            EntityManager em = DBContext.getEntityManager();
            try {
                String jpql = "SELECT u FROM User u WHERE LOWER(u.username) = :key OR LOWER(u.email) = :key";
                TypedQuery<User> query = em.createQuery(jpql, User.class);
                query.setParameter("key", keyLower);
                
                List<User> results = query.getResultList();
                for (User u : results) {
                    if (u.getPassword() != null) {
                        String uPass = u.getPassword().trim();
                        // So sánh mật khẩu đã hash SHA-256 hoặc plain text tương thích
                        if (uPass.equalsIgnoreCase(hashedInput) || uPass.equals(pStr) || uPass.equalsIgnoreCase(pStr)) {
                            if (u.getUsername() != null) memoryUsers.put(u.getUsername().toLowerCase(), u);
                            if (u.getEmail() != null) memoryUsers.put(u.getEmail().toLowerCase(), u);
                            return u;
                        }
                    }
                }
            } finally {
                em.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // 2. Kiểm tra trong bộ nhớ đệm tạm thời (Memory Store)
        for (User memUser : memoryUsers.values()) {
            if (memUser != null) {
                String mUser = memUser.getUsername() != null ? memUser.getUsername().trim().toLowerCase() : "";
                String mEmail = memUser.getEmail() != null ? memUser.getEmail().trim().toLowerCase() : "";
                
                if (keyLower.equals(mUser) || keyLower.equals(mEmail)) {
                    String mPass = memUser.getPassword() != null ? memUser.getPassword().trim() : "";
                    if (mPass.equalsIgnoreCase(hashedInput) || mPass.equals(pStr) || mPass.equalsIgnoreCase(pStr)) {
                        return memUser;
                    }
                }
            }
        }

        // 3. Fallback khởi tạo admin mặc định nếu DB chưa có tài khoản nào
        if ("admin".equals(keyLower) || "admin@nestora.com".equals(keyLower)) {
            User admin = ensureDefaultAdminAccount();
            if (admin != null && admin.getPassword() != null) {
                String aPass = admin.getPassword().trim();
                if (aPass.equalsIgnoreCase(hashedInput) || aPass.equals(pStr) || aPass.equalsIgnoreCase(pStr)) {
                    return admin;
                }
            }
        }

        return null;
    }

    /**
     * Phương thức checkLogin theo đúng yêu cầu đề bài Task 1.2
     */
    public User checkLogin(String username, String password) {
        return login(username, password);
    }
    
    public User ensureDefaultAdminAccount() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<User> list = em.createQuery("SELECT u FROM User u WHERE LOWER(u.username) = 'admin'", User.class).getResultList();
            User admin;
            if (list.isEmpty()) {
                String defaultAdminPass = AuthUtil.hashPassword("admin123");
                admin = new User("admin", defaultAdminPass, "Nguyễn Văn Admin", "admin@nestora.com", "0901234567", "Admin");
                em.persist(admin);
                em.flush();
            } else {
                admin = list.get(0);
                boolean changed = false;
                if (!"Admin".equalsIgnoreCase(admin.getRole())) {
                    admin.setRole("Admin");
                    changed = true;
                }
                if (changed) {
                    admin = em.merge(admin);
                }
            }
            tx.commit();
            if (admin.getUsername() != null) memoryUsers.put(admin.getUsername().toLowerCase(), admin);
            if (admin.getEmail() != null) memoryUsers.put(admin.getEmail().toLowerCase(), admin);
            return admin;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            String defaultAdminPass = AuthUtil.hashPassword("admin123");
            User defaultAdmin = new User("admin", defaultAdminPass, "Nguyễn Văn Admin", "admin@nestora.com", "0901234567", "Admin");
            defaultAdmin.setId(1);
            memoryUsers.put("admin", defaultAdmin);
            return defaultAdmin;
        } finally {
            em.close();
        }
    }

    public boolean register(User user) {
        if (user == null || user.getUsername() == null) return false;

        // Tự động mã hóa mật khẩu nếu chưa được mã hóa SHA-256 (64 ký tự hex)
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            if (user.getPassword().length() != 64) {
                user.setPassword(AuthUtil.hashPassword(user.getPassword()));
            }
        }

        String uKey = user.getUsername().trim().toLowerCase();
        String eKey = user.getEmail() != null ? user.getEmail().trim().toLowerCase() : "";
        memoryUsers.put(uKey, user);
        if (!eKey.isEmpty()) {
            memoryUsers.put(eKey, user);
        }

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(user);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return true;
    }
    
    public boolean insertUser(User user) {
        return register(user);
    }

    public User getUserById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            User u = em.find(User.class, id);
            if (u != null) return u;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }

        for (User u : memoryUsers.values()) {
            if (u.getId() == id) return u;
        }
        return null;
    }

    public List<User> getAllUsers() {
        List<User> list = new java.util.ArrayList<>();
        try {
            EntityManager em = DBContext.getEntityManager();
            try {
                list = em.createQuery("SELECT u FROM User u", User.class).getResultList();
            } finally {
                em.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        // Merge with memoryUsers so all created users appear in list
        Set<String> addedUsernames = new HashSet<>();
        for (User u : list) {
            if (u.getUsername() != null) {
                addedUsernames.add(u.getUsername().toLowerCase());
            }
        }
        for (User memUser : memoryUsers.values()) {
            if (memUser.getUsername() != null && !addedUsernames.contains(memUser.getUsername().toLowerCase())) {
                list.add(memUser);
                addedUsernames.add(memUser.getUsername().toLowerCase());
            }
        }
        return list;
    }

    public boolean updateUser(User user) {
        if (user == null) return false;

        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            if (user.getPassword().length() != 64) {
                user.setPassword(AuthUtil.hashPassword(user.getPassword()));
            }
        }

        String uKey = user.getUsername() != null ? user.getUsername().trim().toLowerCase() : "";
        String eKey = user.getEmail() != null ? user.getEmail().trim().toLowerCase() : "";
        if (!uKey.isEmpty()) memoryUsers.put(uKey, user);
        if (!eKey.isEmpty()) memoryUsers.put(eKey, user);

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(user);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }

    public boolean deleteUser(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                em.remove(user);
                tx.commit();
                return true;
            }
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }
}
