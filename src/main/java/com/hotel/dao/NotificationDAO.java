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
            String jpql = "SELECT n FROM HotelNotification n LEFT JOIN FETCH n.creator ORDER BY n.createdAt DESC, n.notificationId DESC";
            list.addAll(em.createQuery(jpql, HotelNotification.class).getResultList());
        } catch (Exception e) {
            System.err.println("[NotificationDAO.getAllNotifications DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }

        if (list.isEmpty() && memoryNotifications.isEmpty()) {
            seedInitialNotifications();
            return getAllNotifications();
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

    private synchronized void seedInitialNotifications() {
        if (memoryNotifications.isEmpty()) {
            HotelNotification n1 = new HotelNotification(1, "Lịch bảo trì hệ thống điều hòa khu VIP", "Bảo dưỡng định kỳ toàn bộ hệ thống điều hòa tại tầng 4 và tầng 5 từ 22h00 tối nay đến 04h00 sáng mai.", "WARNING", null, true);
            HotelNotification n2 = new HotelNotification(2, "Triển khai chương trình chào hè giảm 15%", "Áp dụng giảm 15% cho khách hàng hạng thành viên Diamond và 10% cho khách hàng hạng Platinum khi đặt phòng trực tuyến.", "SUCCESS", null, true);
            HotelNotification n3 = new HotelNotification(3, "Họp giao ban toàn thể nhân viên lễ tân & buồng phòng", "Ban quản lý tổ chức họp giao ban định kỳ vào 08h30 sáng thứ Hai đầu tuần tại phòng họp tầng 2.", "INFO", null, true);
            HotelNotification n4 = new HotelNotification(4, "Lưu ý kiểm tra thông tin CCCD và xác thực khách khi nhận phòng", "Yêu cầu toàn bộ nhân viên lễ tân đối chiếu chính xác CCCD/Hộ chiếu của tất cả khách lưu trú theo đúng quy định an ninh.", "ERROR", null, true);
            
            memoryNotifications.put(n1.getNotificationId(), n1);
            memoryNotifications.put(n2.getNotificationId(), n2);
            memoryNotifications.put(n3.getNotificationId(), n3);
            memoryNotifications.put(n4.getNotificationId(), n4);

            EntityManager em = DBContext.getEntityManager();
            EntityTransaction tx = em.getTransaction();
            try {
                tx.begin();
                em.persist(new HotelNotification("Lịch bảo trì hệ thống điều hòa khu VIP", "Bảo dưỡng định kỳ toàn bộ hệ thống điều hòa tại tầng 4 và tầng 5 từ 22h00 tối nay đến 04h00 sáng mai.", "WARNING", null, true));
                em.persist(new HotelNotification("Triển khai chương trình chào hè giảm 15%", "Áp dụng giảm 15% cho khách hàng hạng thành viên Diamond và 10% cho khách hàng hạng Platinum khi đặt phòng trực tuyến.", "SUCCESS", null, true));
                em.persist(new HotelNotification("Họp giao ban toàn thể nhân viên lễ tân & buồng phòng", "Ban quản lý tổ chức họp giao ban định kỳ vào 08h30 sáng thứ Hai đầu tuần tại phòng họp tầng 2.", "INFO", null, true));
                em.persist(new HotelNotification("Lưu ý kiểm tra thông tin CCCD và xác thực khách khi nhận phòng", "Yêu cầu toàn bộ nhân viên lễ tân đối chiếu chính xác CCCD/Hộ chiếu của tất cả khách lưu trú theo đúng quy định an ninh.", "ERROR", null, true));
                tx.commit();
            } catch (Exception e) {
                if (tx != null && tx.isActive()) tx.rollback();
            } finally {
                em.close();
            }
        }
    }

    public List<HotelNotification> searchNotifications(String keyword, String type, String status) {
        List<HotelNotification> all = getAllNotifications();
        if ((keyword == null || keyword.trim().isEmpty())
                && (type == null || type.trim().isEmpty() || "ALL".equalsIgnoreCase(type))
                && (status == null || status.trim().isEmpty() || "ALL".equalsIgnoreCase(status))) {
            return all;
        }

        String kw = keyword != null ? keyword.trim().toLowerCase() : "";
        List<HotelNotification> filtered = new ArrayList<>();
        for (HotelNotification n : all) {
            boolean matchesKw = kw.isEmpty()
                    || (n.getTitle() != null && n.getTitle().toLowerCase().contains(kw))
                    || (n.getContent() != null && n.getContent().toLowerCase().contains(kw));

            boolean matchesType = type == null || type.isEmpty() || "ALL".equalsIgnoreCase(type)
                    || (n.getType() != null && n.getType().equalsIgnoreCase(type));

            boolean matchesStatus = true;
            if ("ACTIVE".equalsIgnoreCase(status)) {
                matchesStatus = n.getIsActive() != null && n.getIsActive();
            } else if ("HIDDEN".equalsIgnoreCase(status)) {
                matchesStatus = n.getIsActive() == null || !n.getIsActive();
            }

            if (matchesKw && matchesType && matchesStatus) {
                filtered.add(n);
            }
        }
        return filtered;
    }

    public List<HotelNotification> getTop5Newest() {
        List<HotelNotification> all = getAllNotifications();
        List<HotelNotification> result = new ArrayList<>();
        for (HotelNotification n : all) {
            if (n.getIsActive() != null && n.getIsActive()) {
                result.add(n);
                if (result.size() >= 5) break;
            }
        }
        return result;
    }

    public HotelNotification getById(int id) {
        if (id <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT n FROM HotelNotification n LEFT JOIN FETCH n.creator WHERE n.notificationId = :id";
            List<HotelNotification> res = em.createQuery(jpql, HotelNotification.class).setParameter("id", id).getResultList();
            if (res != null && !res.isEmpty()) return res.get(0);
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
                    txRetry.commit();
                    dbSuccess = notification.getNotificationId() > 0;
                } catch (Exception ex2) {
                    if (txRetry != null && txRetry.isActive()) txRetry.rollback();
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
            int updatedCount = em.createQuery(
                    "UPDATE HotelNotification n SET n.title = :title, n.content = :content, n.type = :type, n.isActive = :isActive WHERE n.notificationId = :id")
                    .setParameter("title", notification.getTitle())
                    .setParameter("content", notification.getContent())
                    .setParameter("type", notification.getType())
                    .setParameter("isActive", notification.getIsActive())
                    .setParameter("id", notification.getNotificationId())
                    .executeUpdate();
            tx.commit();
            return updatedCount > 0 || memoryNotifications.containsKey(notification.getNotificationId());
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[NotificationDAO.update DB Warning]: " + e.getMessage());
            return true;
        } finally {
            em.close();
        }
    }

    public boolean toggleActive(int id) {
        HotelNotification item = getById(id);
        if (item != null) {
            boolean newActive = !(item.getIsActive() != null && item.getIsActive());
            item.setIsActive(newActive);
            memoryNotifications.put(id, item);

            EntityManager em = DBContext.getEntityManager();
            EntityTransaction tx = em.getTransaction();
            try {
                tx.begin();
                em.createQuery("UPDATE HotelNotification n SET n.isActive = :isActive WHERE n.notificationId = :id")
                        .setParameter("isActive", newActive)
                        .setParameter("id", id)
                        .executeUpdate();
                tx.commit();
                return true;
            } catch (Exception e) {
                if (tx != null && tx.isActive()) tx.rollback();
                return true;
            } finally {
                em.close();
            }
        }
        return false;
    }

    public boolean delete(int id) {
        memoryNotifications.remove(id);
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.createQuery("DELETE FROM HotelNotification n WHERE n.notificationId = :id")
                    .setParameter("id", id)
                    .executeUpdate();
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
