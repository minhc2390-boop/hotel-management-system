package com.hotel.dao;

import com.hotel.model.HotelNotification;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;

public class NotificationDAO {

    public List<HotelNotification> getAllNotifications() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT n FROM HotelNotification n ORDER BY n.createdAt DESC, n.notificationId DESC";
            return em.createQuery(jpql, HotelNotification.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public List<HotelNotification> getTop5Newest() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT n FROM HotelNotification n WHERE n.isActive = true ORDER BY n.createdAt DESC, n.notificationId DESC";
            TypedQuery<HotelNotification> query = em.createQuery(jpql, HotelNotification.class);
            query.setMaxResults(5);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public HotelNotification getById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(HotelNotification.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean insert(HotelNotification notification) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(notification);
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

    public boolean update(HotelNotification notification) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(notification);
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
            HotelNotification notification = em.find(HotelNotification.class, id);
            if (notification == null) {
                tx.rollback();
                return false;
            }
            em.remove(notification);
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
