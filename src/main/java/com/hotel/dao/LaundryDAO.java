package com.hotel.dao;

import com.hotel.model.Laundry;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;

public class LaundryDAO {

    public List<Laundry> getAllLaundries() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT l FROM Laundry l ORDER BY l.id DESC";
            return em.createQuery(jpql, Laundry.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public List<Laundry> searchLaundries(String keyword, String status) {
        EntityManager em = DBContext.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT l FROM Laundry l WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append(" AND (LOWER(l.customerName) LIKE :kw OR LOWER(l.roomNumber) LIKE :kw OR LOWER(l.serviceType) LIKE :kw OR LOWER(l.notes) LIKE :kw)");
            }
            if (status != null && !status.trim().isEmpty()) {
                jpql.append(" AND l.processingStatus = :status");
            }
            jpql.append(" ORDER BY l.id DESC");

            TypedQuery<Laundry> query = em.createQuery(jpql.toString(), Laundry.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
            }
            if (status != null && !status.trim().isEmpty()) {
                query.setParameter("status", status.trim());
            }

            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public Laundry getById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(Laundry.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean insert(Laundry laundry) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(laundry);
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

    public boolean update(Laundry laundry) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(laundry);
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

    public boolean updateProcessingStatus(int id, String status) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id);
            if (laundry == null) {
                tx.rollback();
                return false;
            }
            laundry.setProcessingStatus(status);
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

    public boolean delete(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id);
            if (laundry == null) {
                tx.rollback();
                return false;
            }
            em.remove(laundry);
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
}
