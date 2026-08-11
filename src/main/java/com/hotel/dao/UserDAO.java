package com.hotel.dao;

import com.hotel.model.User;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class UserDAO {

    public User findByEmail(String email) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u WHERE u.email = :email";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("email", email);
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

    public User findByEmailOrUsername(String loginKey) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u WHERE u.email = :loginKey OR u.username = :loginKey";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("loginKey", loginKey);
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
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u WHERE u.username = :username AND u.password = :password";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            query.setParameter("username", username);
            query.setParameter("password", password);
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

    public boolean register(User user) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(user);
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

    public User getUserById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(User.class, id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public List<User> getAllUsers() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT u FROM User u ORDER BY u.id DESC";
            TypedQuery<User> query = em.createQuery(jpql, User.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public List<User> getEmployees() {
        List<User> all = getAllUsers();
        List<User> employees = new java.util.ArrayList<>();
        if (all != null) {
            for (User u : all) {
                if (u != null && ("Admin".equalsIgnoreCase(u.getRole()) || "Receptionist".equalsIgnoreCase(u.getRole()))) {
                    employees.add(u);
                }
            }
        }
        return employees;
    }

    public boolean updateUser(User user) {
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
