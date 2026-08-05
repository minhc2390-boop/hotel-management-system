package com.hotel.dao;

import com.hotel.model.Room;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class RoomDAO {

    public List<Room> getAllRooms() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r ORDER BY r.roomNumber ASC";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public List<Room> getAvailableRooms() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r WHERE r.status != 'Maintenance' ORDER BY r.roomNumber ASC";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Room getRoomById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r WHERE r.id = :id";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            query.setParameter("id", id);
            List<Room> list = query.getResultList();
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

    public boolean insertRoom(Room room) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (room.getRoomType() != null && room.getRoomType().getId() > 0) {
                room.setRoomType(em.find(com.hotel.model.RoomType.class, room.getRoomType().getId()));
            }
            em.persist(room);
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

    public boolean updateRoom(Room room) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (room.getRoomType() != null && room.getRoomType().getId() > 0) {
                room.setRoomType(em.find(com.hotel.model.RoomType.class, room.getRoomType().getId()));
            }
            em.merge(room);
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

    public boolean updateRoomStatus(int id, String status) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Room room = em.find(Room.class, id);
            if (room != null) {
                room.setStatus(status);
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

    public boolean deleteRoom(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Room room = em.find(Room.class, id);
            if (room != null) {
                em.remove(room);
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
