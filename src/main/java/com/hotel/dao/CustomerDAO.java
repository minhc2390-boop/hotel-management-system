package com.hotel.dao;

import com.hotel.model.Customer;
import com.hotel.model.User;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;

public class CustomerDAO {

    public List<Customer> getAllCustomers() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c LEFT JOIN FETCH c.user ORDER BY c.customerName ASC";
            TypedQuery<Customer> query = em.createQuery(jpql, Customer.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return Collections.emptyList();
    }

    public Customer getCustomerById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE c.customerId = :id";
            List<Customer> list = em.createQuery(jpql, Customer.class)
                    .setParameter("id", id)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Customer getCustomerByUserId(int userId) {
        if (userId <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE c.user.id = :userId";
            List<Customer> list = em.createQuery(jpql, Customer.class)
                    .setParameter("userId", userId)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean insertCustomer(Customer customer) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (customer.getUser() != null && customer.getUser().getId() > 0) {
                User managedUser = em.find(User.class, customer.getUser().getId());
                if (managedUser != null) {
                    customer.setUser(managedUser);
                }
            }
            if (customer.getCustomerId() > 0) {
                em.merge(customer);
            } else {
                em.persist(customer);
            }
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

    /**
     * Tìm hoặc tạo hồ sơ khách hàng lưu trú với cơ chế thứ tự ưu tiên chính xác:
     * 1. Khớp theo User ID (nếu khách hàng đã đăng nhập tài khoản).
     * 2. Khớp theo CCCD (định danh công dân duy nhất tại Việt Nam).
     * 3. Khớp theo Email cá nhân.
     * 4. Khớp theo Số điện thoại.
     * 5. Nếu chưa tồn tại, tạo mới hồ sơ và tự động gắn kết với tài khoản User (nếu có).
     */
    public Customer findOrCreateCustomer(String name, String phone, String email, String cccd, User user) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            String pVal = (phone != null) ? phone.trim() : "";
            String eVal = (email != null) ? email.trim() : "";
            String cVal = (cccd != null && !cccd.trim().isEmpty()) ? cccd.trim() : null;
            String nVal = (name != null) ? name.trim() : "";

            Customer existing = null;

            // 1. Nếu có User được chỉ định, tìm theo user.id trước tiên
            if (user != null && user.getId() > 0) {
                String jpqlUser = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE c.user.id = :userId";
                List<Customer> listUser = em.createQuery(jpqlUser, Customer.class)
                        .setParameter("userId", user.getId())
                        .getResultList();
                if (!listUser.isEmpty()) {
                    existing = listUser.get(0);
                }
            }

            // 2. Nếu chưa tìm thấy và có CCCD (duy nhất)
            if (existing == null && cVal != null && !cVal.isEmpty()) {
                String jpqlCccd = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE c.customerCccd = :cccd";
                List<Customer> listCccd = em.createQuery(jpqlCccd, Customer.class)
                        .setParameter("cccd", cVal)
                        .getResultList();
                if (!listCccd.isEmpty()) {
                    existing = listCccd.get(0);
                }
            }

            // 3. Nếu chưa tìm thấy và có Email
            if (existing == null && !eVal.isEmpty()) {
                String jpqlEmail = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE LOWER(c.customerEmail) = :email";
                List<Customer> listEmail = em.createQuery(jpqlEmail, Customer.class)
                        .setParameter("email", eVal.toLowerCase())
                        .getResultList();
                if (!listEmail.isEmpty()) {
                    existing = listEmail.get(0);
                }
            }

            // 4. Nếu chưa tìm thấy và có SĐT
            if (existing == null && !pVal.isEmpty()) {
                String jpqlPhone = "SELECT c FROM Customer c LEFT JOIN FETCH c.user WHERE c.customerPhone = :phone";
                List<Customer> listPhone = em.createQuery(jpqlPhone, Customer.class)
                        .setParameter("phone", pVal)
                        .getResultList();
                if (!listPhone.isEmpty()) {
                    existing = listPhone.get(0);
                }
            }

            // Nếu đã tìm thấy khách hàng: Cập nhật các trường còn thiếu / gắn kết User nếu chưa có
            if (existing != null) {
                boolean updated = false;
                if ((existing.getCustomerName() == null || existing.getCustomerName().trim().isEmpty()) && !nVal.isEmpty()) {
                    existing.setCustomerName(nVal);
                    updated = true;
                }
                if ((existing.getCustomerPhone() == null || existing.getCustomerPhone().trim().isEmpty()) && !pVal.isEmpty()) {
                    existing.setCustomerPhone(pVal);
                    updated = true;
                }
                if ((existing.getCustomerCccd() == null || existing.getCustomerCccd().trim().isEmpty()) && cVal != null) {
                    existing.setCustomerCccd(cVal);
                    updated = true;
                }
                if ((existing.getCustomerEmail() == null || existing.getCustomerEmail().trim().isEmpty()) && !eVal.isEmpty()) {
                    existing.setCustomerEmail(eVal);
                    updated = true;
                }
                if (existing.getUser() == null && user != null && user.getId() > 0) {
                    User managedUser = em.find(User.class, user.getId());
                    existing.setUser(managedUser != null ? managedUser : user);
                    updated = true;
                }
                if (updated) {
                    tx.begin();
                    existing = em.merge(existing);
                    tx.commit();
                }
                return existing;
            }

            // 5. Nếu không tìm thấy, tạo mới hồ sơ khách hàng
            tx.begin();
            User managedUser = null;
            if (user != null && user.getId() > 0) {
                managedUser = em.find(User.class, user.getId());
            }
            Customer newCust = new Customer(nVal, cVal, pVal, eVal, managedUser != null ? managedUser : user);
            em.persist(newCust);
            tx.commit();
            return newCust;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Customer findOrCreateCustomer(String name, String phone, String email, String cccd) {
        return findOrCreateCustomer(name, phone, email, cccd, null);
    }
}
