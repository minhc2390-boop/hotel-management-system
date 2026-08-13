package com.hotel.dao;

import com.hotel.model.Equipment;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class EquipmentDAO {

    public List<Equipment> getAllEquipments() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT e FROM Equipment e ORDER BY e.equipmentId DESC";
            TypedQuery<Equipment> query = em.createQuery(jpql, Equipment.class);
            List<Equipment> list = query.getResultList();
            if (list == null || list.isEmpty()) {
                seedDefaultEquipments();
                list = em.createQuery(jpql, Equipment.class).getResultList();
            }
            return list;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    private void seedDefaultEquipments() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(new Equipment("Tivi Smart 4K 43 inch", 24, "Cái", "Hoạt động tốt", "Thiết bị giải trí cố định trong phòng"));
            em.persist(new Equipment("Máy lạnh Inverter Daikin", 24, "Bộ", "Hoạt động tốt", "Điều hòa không khí cố định trong phòng"));
            em.persist(new Equipment("Máy sấy tóc cao cấp", 24, "Cái", "Hoạt động tốt", "Trang bị nhà tắm cố định"));
            em.persist(new Equipment("Tủ lạnh Mini Bar 50L", 24, "Cái", "Hoạt động tốt", "Tủ lạnh bảo quản nước uống cố định"));
            em.persist(new Equipment("Bình đun siêu tốc 1.8L", 24, "Cái", "Hoạt động tốt", "Trang bị pha trà/cà phê phòng nghỉ"));
            em.persist(new Equipment("Két sắt an toàn điện tử", 24, "Cái", "Hoạt động tốt", "Két sắt cố định lưu trữ tài sản"));
            em.persist(new Equipment("Bình nóng lạnh Rossi 30L", 24, "Bộ", "Hoạt động tốt", "Cung cấp nước nóng cố định nhà tắm"));
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    public List<Equipment> searchEquipments(String keyword) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT e FROM Equipment e WHERE LOWER(e.equipmentName) LIKE LOWER(:kw) OR LOWER(e.unit) LIKE LOWER(:kw) OR LOWER(e.status) LIKE LOWER(:kw) OR LOWER(e.description) LIKE LOWER(:kw) ORDER BY e.equipmentId DESC";
            TypedQuery<Equipment> query = em.createQuery(jpql, Equipment.class);
            query.setParameter("kw", "%" + keyword + "%");
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Equipment getEquipmentById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(Equipment.class, id);
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

    public boolean updateEquipment(Equipment equipment) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
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
}
