package com.hotel.dao;

import com.hotel.model.BillDetail;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import java.util.List;

public class BillDetailDAO {

    public List<BillDetail> getBillDetailsByBillId(int billId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            // Eagerly fetch optional room and service relations using LEFT JOIN FETCH
            String jpql = "SELECT bd FROM BillDetail bd " +
                           "LEFT JOIN FETCH bd.room " +
                           "LEFT JOIN FETCH bd.service " +
                           "WHERE bd.billId = :billId";
            TypedQuery<BillDetail> query = em.createQuery(jpql, BillDetail.class);
            query.setParameter("billId", billId);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean insertBillDetail(BillDetail detail) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (detail.getRoom() != null && detail.getRoom().getId() > 0) {
                detail.setRoom(em.find(com.hotel.model.Room.class, detail.getRoom().getId()));
            }
            if (detail.getService() != null && detail.getService().getId() > 0) {
                detail.setService(em.find(com.hotel.model.Service.class, detail.getService().getId()));
            }
            em.persist(detail);
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

    public boolean deleteBillDetailsByBillId(int billId) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            String jpql = "DELETE FROM BillDetail bd WHERE bd.billId = :billId";
            Query query = em.createQuery(jpql);
            query.setParameter("billId", billId);
            int rowsDeleted = query.executeUpdate();
            tx.commit();
            return rowsDeleted > 0;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
    }
}
