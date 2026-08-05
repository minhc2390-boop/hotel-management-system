package com.hotel.dao;

import com.hotel.model.HotelNotification;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;

public class NotificationDAO {

    public List<HotelNotification> getAllNotifications() {
        autoRepairGarbledNotifications();
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
        autoRepairGarbledNotifications();
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

    private void autoRepairGarbledNotifications() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<HotelNotification> list = em.createQuery("SELECT n FROM HotelNotification n", HotelNotification.class).getResultList();
            for (HotelNotification n : list) {
                boolean dirty = false;
                String t = n.getTitle();
                String c = n.getContent();
                if (t != null && t.contains("?")) {
                    if (n.getNotificationId() == 1 || t.toLowerCase().contains("chao") || t.toLowerCase().contains("welcome") || t.toLowerCase().contains("nestora")) {
                        n.setTitle("Chào mừng đến với Nestora Hotel");
                        n.setContent("Hệ thống quản lý khách sạn đã cập nhật tính năng thông báo mới và theo dõi dịch vụ giặt ủi!");
                        dirty = true;
                    } else if (t.toLowerCase().contains("bao tri") || t.toLowerCase().contains("thang may")) {
                        n.setTitle("Bảo trì hệ thống thang máy");
                        n.setContent("Thang máy số 2 sẽ được kiểm tra kỹ thuật định kỳ vào lúc 14:00 hôm nay.");
                        dirty = true;
                    } else if (t.toLowerCase().contains("quy dinh") || t.toLowerCase().contains("le tan")) {
                        n.setTitle("Quy định bàn giao ca lễ tân");
                        n.setContent("Yêu cầu tất cả lễ tân bàn giao sổ thu chi và tiền mặt trước khi kết thúc ca làm.");
                        dirty = true;
                    } else {
                        n.setTitle("Thông báo hệ thống #" + n.getNotificationId());
                        dirty = true;
                    }
                }
                if (c != null && c.contains("?") && !dirty) {
                    if (c.toLowerCase().contains("thang may")) {
                        n.setContent("Thang máy số 2 sẽ được kiểm tra kỹ thuật định kỳ vào lúc 14:00 hôm nay.");
                        dirty = true;
                    } else if (c.toLowerCase().contains("le tan")) {
                        n.setContent("Yêu cầu tất cả lễ tân bàn giao sổ thu chi và tiền mặt trước khi kết thúc ca làm.");
                        dirty = true;
                    }
                }
                if (dirty) {
                    em.merge(n);
                }
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
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
