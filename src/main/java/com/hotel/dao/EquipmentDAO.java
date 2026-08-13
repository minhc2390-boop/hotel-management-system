package com.hotel.dao;

import com.hotel.model.Equipment;
import com.hotel.model.Room;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.List;

public class EquipmentDAO {

    public List<Equipment> getAllEquipments() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT e FROM Equipment e LEFT JOIN FETCH e.room r ORDER BY CASE WHEN r IS NULL THEN 1 ELSE 0 END, r.roomNumber ASC, e.equipmentId DESC";
            TypedQuery<Equipment> query = em.createQuery(jpql, Equipment.class);
            List<Equipment> list = query.getResultList();
            if (list == null || list.isEmpty()) {
                seedInitialEquipments();
                list = em.createQuery(jpql, Equipment.class).getResultList();
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return Collections.emptyList();
    }

    public List<Equipment> getEquipmentsByRoomId(int roomId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT e FROM Equipment e LEFT JOIN FETCH e.room WHERE e.room.id = :roomId ORDER BY e.equipmentId ASC";
            TypedQuery<Equipment> query = em.createQuery(jpql, Equipment.class);
            query.setParameter("roomId", roomId);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return Collections.emptyList();
    }

    public List<Equipment> searchEquipments(String keyword, Integer roomId, String status) {
        EntityManager em = DBContext.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT e FROM Equipment e LEFT JOIN FETCH e.room r WHERE 1=1 ");
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append("AND (LOWER(e.equipmentName) LIKE LOWER(:kw) OR LOWER(e.unit) LIKE LOWER(:kw) OR LOWER(e.status) LIKE LOWER(:kw) OR LOWER(e.description) LIKE LOWER(:kw) OR LOWER(r.roomNumber) LIKE LOWER(:kw)) ");
            }
            if (roomId != null && roomId > 0) {
                jpql.append("AND r.id = :roomId ");
            } else if (roomId != null && roomId == -1) {
                jpql.append("AND r IS NULL ");
            }
            if (status != null && !status.trim().isEmpty()) {
                jpql.append("AND LOWER(e.status) = LOWER(:status) ");
            }
            jpql.append("ORDER BY CASE WHEN r IS NULL THEN 1 ELSE 0 END, r.roomNumber ASC, e.equipmentId DESC");

            TypedQuery<Equipment> query = em.createQuery(jpql.toString(), Equipment.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim() + "%");
            }
            if (roomId != null && roomId > 0) {
                query.setParameter("roomId", roomId);
            }
            if (status != null && !status.trim().isEmpty()) {
                query.setParameter("status", status.trim());
            }
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return Collections.emptyList();
    }

    public List<Equipment> searchEquipments(String keyword) {
        return searchEquipments(keyword, null, null);
    }

    public Equipment getEquipmentById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT e FROM Equipment e LEFT JOIN FETCH e.room WHERE e.equipmentId = :id";
            List<Equipment> list = em.createQuery(jpql, Equipment.class).setParameter("id", id).getResultList();
            return (list != null && !list.isEmpty()) ? list.get(0) : null;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean insertEquipment(Equipment equipment) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (equipment.getRoom() != null && equipment.getRoom().getId() > 0) {
                Room r = em.find(Room.class, equipment.getRoom().getId());
                equipment.setRoom(r);
            }
            em.persist(equipment);
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

    public boolean insertEquipmentsForRoom(int roomId, List<Equipment> equipments) {
        if (equipments == null || equipments.isEmpty()) return true;
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Room room = em.find(Room.class, roomId);
            for (Equipment eq : equipments) {
                eq.setRoom(room);
                em.persist(eq);
            }
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

    public boolean updateEquipment(Equipment equipment) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (equipment.getRoom() != null && equipment.getRoom().getId() > 0) {
                Room r = em.find(Room.class, equipment.getRoom().getId());
                equipment.setRoom(r);
            } else {
                equipment.setRoom(null);
            }
            em.merge(equipment);
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

    public boolean deleteEquipment(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Equipment equipment = em.find(Equipment.class, id);
            if (equipment != null) {
                em.remove(equipment);
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

    public boolean deleteEquipmentsByRoomId(int roomId) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.createNativeQuery("DELETE FROM Equipments WHERE room_id = :roomId")
              .setParameter("roomId", roomId)
              .executeUpdate();
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

    private void seedInitialEquipments() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<Room> rooms = em.createQuery("SELECT r FROM Room r ORDER BY r.id ASC", Room.class).getResultList();
            if (rooms != null && !rooms.isEmpty()) {
                for (Room r : rooms) {
                    em.persist(new Equipment(r, "Tivi Smart 4K", 1, "Cái", "Hoạt động tốt", "Kèm điều khiển và giá treo tường"));
                    em.persist(new Equipment(r, "Máy lạnh Inverter Daikin", 1, "Bộ", "Hoạt động tốt", "Điều hòa hai chiều kèm remote"));
                    em.persist(new Equipment(r, "Máy sấy tóc cao cấp", 1, "Cái", "Hoạt động tốt", "Trang bị trong phòng tắm"));
                    em.persist(new Equipment(r, "Tủ lạnh Mini Bar 50L", 1, "Cái", "Hoạt động tốt", "Tủ lạnh bảo quản đồ uống"));
                    em.persist(new Equipment(r, "Bình đun siêu tốc 1.8L", 1, "Cái", "Hoạt động tốt", "Kèm khay trà cà phê"));
                    em.persist(new Equipment(r, "Két sắt an toàn điện tử", 1, "Cái", "Hoạt động tốt", "Khóa mã số điện tử"));
                    em.persist(new Equipment(r, "Bình nóng lạnh 30L", 1, "Bộ", "Hoạt động tốt", "Hệ thống nước nóng phòng tắm"));
                }
            } else {
                em.persist(new Equipment("Tivi Smart 4K 43 inch", 1, "Cái", "Hoạt động tốt", "Thiết bị giải trí cố định"));
                em.persist(new Equipment("Máy lạnh Inverter Daikin", 1, "Bộ", "Hoạt động tốt", "Điều hòa không khí"));
                em.persist(new Equipment("Máy sấy tóc cao cấp", 1, "Cái", "Hoạt động tốt", "Trang bị nhà tắm"));
                em.persist(new Equipment("Tủ lạnh Mini Bar 50L", 1, "Cái", "Hoạt động tốt", "Tủ lạnh mini"));
                em.persist(new Equipment("Bình đun siêu tốc 1.8L", 1, "Cái", "Hoạt động tốt", "Pha trà cà phê"));
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
