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
            String jpql = "SELECT b FROM Bill b JOIN FETCH b.user ORDER BY b.id DESC";
            TypedQuery<Bill> query = em.createQuery(jpql, Bill.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public List<Bill> getBillsByUserId(int userId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Bill b JOIN FETCH b.user WHERE b.user.id = :userId ORDER BY b.id DESC";
            TypedQuery<Bill> query = em.createQuery(jpql, Bill.class);
            query.setParameter("userId", userId);
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
            String jpql = "SELECT b FROM Bill b JOIN FETCH b.user WHERE b.id = :id";
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
