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
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
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
