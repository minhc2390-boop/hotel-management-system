package com.hotel.dao;

import com.hotel.model.Bill;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class BillDAO {

    public List<Bill> getAllBills() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Bill b LEFT JOIN FETCH b.user LEFT JOIN FETCH b.customer ORDER BY b.id DESC";
            TypedQuery<Bill> query = em.createQuery(jpql, Bill.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return java.util.Collections.emptyList();
        } finally {
            if (em != null && em.isOpen()) {
                em.close();
            }
        }
    }

    public List<Bill> getBillsByUserId(int userId, String email) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Bill b LEFT JOIN FETCH b.user LEFT JOIN FETCH b.customer WHERE b.user.id = :userId OR (b.customer.customerEmail = :email) ORDER BY b.id DESC";
            TypedQuery<Bill> query = em.createQuery(jpql, Bill.class);
            query.setParameter("userId", userId);
            query.setParameter("email", email);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Bill getBillById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Bill b LEFT JOIN FETCH b.user LEFT JOIN FETCH b.customer WHERE b.id = :id";
            TypedQuery<Bill> query = em.createQuery(jpql, Bill.class);
            query.setParameter("id", id);
            List<Bill> list = query.getResultList();
            if (!list.isEmpty()) {
                return list.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    /**
     * Inserts a bill and returns the auto-generated id.
     */
    public int insertBill(Bill bill) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (bill.getUser() != null && bill.getUser().getId() > 0) {
                bill.setUser(em.find(com.hotel.model.User.class, bill.getUser().getId()));
            }
            if (bill.getCustomer() != null && bill.getCustomer().getCustomerId() > 0) {
                bill.setCustomer(em.find(com.hotel.model.Customer.class, bill.getCustomer().getCustomerId()));
            }
            em.persist(bill);
            tx.commit();
            return bill.getId(); // Automatically populated by JPA/Hibernate
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return -1;
    }

    public boolean updateBillStatus(int id, String status) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Bill bill = em.find(Bill.class, id);
            if (bill != null) {
                bill.setStatus(status);
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

    public boolean markBillPaid(int id, String paymentMethod) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Bill bill = em.find(Bill.class, id);
            if (bill == null || !"Unpaid".equals(bill.getStatus())) {
                tx.rollback();
                return false;
            }
            bill.setPaymentMethod(paymentMethod);
            bill.setStatus("Paid");
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean updateBillTotal(int id, double total) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Bill bill = em.find(Bill.class, id);
            if (bill != null) {
                bill.setTotalAmount(total);
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

    public boolean deleteBill(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Bill bill = em.find(Bill.class, id);
            if (bill != null) {
                em.remove(bill);
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
