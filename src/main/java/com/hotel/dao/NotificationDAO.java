package com.hotel.dao;

import com.hotel.model.HotelNotification;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class NotificationDAO {

    private static final Map<Integer, HotelNotification> memoryNotifications = new ConcurrentHashMap<>();
    private static final AtomicInteger idCounter = new AtomicInteger(500);

    public List<HotelNotification> getAllNotifications() {
        List<HotelNotification> list = new ArrayList<>();
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT n FROM HotelNotification n ORDER BY n.createdAt DESC, n.notificationId DESC";
            list.addAll(em.createQuery(jpql, HotelNotification.class).getResultList());
        } catch (Exception e) {
            System.err.println("[NotificationDAO.getAllNotifications DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }

        Set<Integer> existingIds = new HashSet<>();
        for (HotelNotification n : list) {
            existingIds.add(n.getNotificationId());
        }

        for (HotelNotification memItem : memoryNotifications.values()) {
            if (memItem != null && !existingIds.contains(memItem.getNotificationId())) {
                list.add(memItem);
                existingIds.add(memItem.getNotificationId());
            }
        }

        list.sort((a, b) -> Integer.compare(b.getNotificationId(), a.getNotificationId()));
        return list;
    }

    public List<HotelNotification> getTop5Newest() {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.createQuery(
                            "SELECT n FROM HotelNotification n "
                                    + "WHERE n.isActive = TRUE "
                                    + "ORDER BY n.createdAt DESC, n.notificationId DESC",
                            HotelNotification.class)
                    .setMaxResults(5)
                    .getResultList();
        } catch (Exception e) {
            System.err.println("[NotificationDAO.getTop5Newest DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }

        return getAllNotifications().stream()
                .filter(n -> n != null && Boolean.TRUE.equals(n.getIsActive()))
                .sorted(Comparator
                        .comparing(HotelNotification::getCreatedAt,
                                Comparator.nullsLast(Comparator.reverseOrder()))
                        .thenComparing(HotelNotification::getNotificationId, Comparator.reverseOrder()))
                .limit(5)
                .collect(java.util.stream.Collectors.toList());
    }

    public HotelNotification getById(int id) {
        if (id <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            HotelNotification item = em.find(HotelNotification.class, id);
            if (item != null) return item;
        } catch (Exception e) {
            System.err.println("[NotificationDAO.getById DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }
        return memoryNotifications.get(id);
    }

    public boolean insert(HotelNotification notification) {
        if (notification == null) return false;
        if (notification.getCreatedAt() == null) {
            notification.setCreatedAt(LocalDateTime.now());
        }

        boolean dbSuccess = false;
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(notification);
            em.flush();
            tx.commit();
            dbSuccess = notification.getNotificationId() > 0;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[NotificationDAO.insert Primary DB Warning]: " + e.getMessage());

            // Safe Retry without FK createdBy if foreign key constraint failed
            if (notification.getCreatedBy() != null) {
                notification.setCreatedBy(null);
                EntityManager emRetry = DBContext.getEntityManager();
                EntityTransaction txRetry = emRetry.getTransaction();
                try {
                    txRetry.begin();
                    emRetry.persist(notification);
                    emRetry.flush();
                    txRetry.commit();
                    dbSuccess = notification.getNotificationId() > 0;
                } catch (Exception ex2) {
                    if (txRetry != null && txRetry.isActive()) txRetry.rollback();
                    System.err.println("[NotificationDAO.insert Retry DB Warning]: " + ex2.getMessage());
                } finally {
                    emRetry.close();
                }
            }
        } finally {
            em.close();
        }

        if (!dbSuccess || notification.getNotificationId() <= 0) {
            int newId = idCounter.incrementAndGet();
            notification.setNotificationId(newId);
        }

        memoryNotifications.put(notification.getNotificationId(), notification);
        return true;
    }

    public boolean update(HotelNotification notification) {
        if (notification == null || notification.getNotificationId() <= 0) return false;
        memoryNotifications.put(notification.getNotificationId(), notification);

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(notification);
            em.flush();
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[NotificationDAO.update DB Warning]: " + e.getMessage());
            return true;
        } finally {
            em.close();
        }
    }

    public boolean delete(int id) {
        memoryNotifications.remove(id);
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            HotelNotification notification = em.find(HotelNotification.class, id);
            if (notification != null) {
                em.remove(notification);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[NotificationDAO.delete DB Warning]: " + e.getMessage());
            return true;
        } finally {
            em.close();
        }
    }
}
