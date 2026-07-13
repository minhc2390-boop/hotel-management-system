package com.hotel.dao;

import com.hotel.model.RoomType;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class RoomTypeDAO {

    public List<RoomType> getAllRoomTypes() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT rt FROM RoomType rt ORDER BY rt.id DESC";
            TypedQuery<RoomType> query = em.createQuery(jpql, RoomType.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public RoomType getRoomTypeById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(RoomType.class, id);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean insertRoomType(RoomType roomType) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(roomType);
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

    public boolean updateRoomType(RoomType roomType) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(roomType);
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

    public boolean deleteRoomType(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            RoomType roomType = em.find(RoomType.class, id);
            if (roomType != null) {
                em.remove(roomType);
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
