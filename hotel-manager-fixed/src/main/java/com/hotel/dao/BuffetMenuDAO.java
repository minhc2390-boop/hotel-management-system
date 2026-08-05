package com.hotel.dao;

import com.hotel.model.BuffetMenuItem;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

public class BuffetMenuDAO {

    public List<BuffetMenuItem> getActiveItemsByDate(LocalDate menuDate) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT i FROM BuffetMenuItem i "
                    + "WHERE i.menuDate = :menuDate AND i.status = 'Active' "
                    + "ORDER BY CASE i.mealPeriod "
                    + "WHEN 'Breakfast' THEN 1 WHEN 'Lunch' THEN 2 WHEN 'Dinner' THEN 3 ELSE 4 END, "
                    + "i.sortOrder, i.category, i.dishName";
            return em.createQuery(jpql, BuffetMenuItem.class)
                    .setParameter("menuDate", menuDate)
                    .getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public List<BuffetMenuItem> getItemsForManagement(LocalDate menuDate) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT i FROM BuffetMenuItem i "
                    + "WHERE (:menuDate IS NULL OR i.menuDate = :menuDate) "
                    + "ORDER BY i.menuDate DESC, "
                    + "CASE i.mealPeriod WHEN 'Breakfast' THEN 1 WHEN 'Lunch' THEN 2 WHEN 'Dinner' THEN 3 ELSE 4 END, "
                    + "i.sortOrder, i.dishName";
            TypedQuery<BuffetMenuItem> query = em.createQuery(jpql, BuffetMenuItem.class);
            query.setParameter("menuDate", menuDate);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public BuffetMenuItem getById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(BuffetMenuItem.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean insert(BuffetMenuItem item) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(item);
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

    public boolean update(BuffetMenuItem item) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(item);
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
            BuffetMenuItem item = em.find(BuffetMenuItem.class, id);
            if (item == null) {
                tx.rollback();
                return false;
            }
            em.remove(item);
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
