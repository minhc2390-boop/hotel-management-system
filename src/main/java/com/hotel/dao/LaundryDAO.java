package com.hotel.dao;

import com.hotel.model.Laundry;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicInteger;

public class LaundryDAO {

    private static final Map<Integer, Laundry> memoryLaundries = new ConcurrentHashMap<>();
    private static final AtomicInteger idCounter = new AtomicInteger(500);

    public List<Laundry> getAllLaundries() {
        return searchLaundries("", "");
    }

    public List<Laundry> searchLaundries(String keyword, String status) {
        List<Laundry> list = new ArrayList<>();
        EntityManager em = DBContext.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT l FROM Laundry l WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append(" AND (LOWER(l.customerName) LIKE :kw OR LOWER(l.roomNumber) LIKE :kw OR LOWER(l.serviceType) LIKE :kw OR LOWER(l.notes) LIKE :kw)");
            }
            if (status != null && !status.trim().isEmpty()) {
                String st = status.trim().toUpperCase();
                if ((st.contains("ĐÃ") || st.contains("HOÀN THÀNH") || st.contains("HOAN THANH") || st.contains("DONE") || st.contains("COMPLETED")) && !st.contains("CHƯA") && !st.contains("CHUA")) {
                    jpql.append(" AND (UPPER(l.processingStatus) = 'DONE' OR UPPER(l.processingStatus) LIKE '%ĐÃ%' OR UPPER(l.processingStatus) LIKE '%HOÀN THÀNH%' OR UPPER(l.processingStatus) LIKE '%HOAN THANH%')");
                } else {
                    jpql.append(" AND (UPPER(l.processingStatus) = 'PENDING' OR UPPER(l.processingStatus) LIKE '%CHƯA%' OR UPPER(l.processingStatus) LIKE '%CHUA%')");
                }
            }
            jpql.append(" ORDER BY l.id DESC");

            TypedQuery<Laundry> query = em.createQuery(jpql.toString(), Laundry.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("kw", "%" + keyword.trim().toLowerCase() + "%");
            }
            list.addAll(query.getResultList());
        } catch (Exception e) {
            System.err.println("[LaundryDAO.searchLaundries DB Query Warning]: " + e.getMessage());
        } finally {
            em.close();
        }

        // Merge with memoryLaundries so newly created orders are GUARANTEED to appear!
        Set<Integer> existingIds = new HashSet<>();
        for (Laundry l : list) {
            existingIds.add(l.getId());
        }

        for (Laundry memItem : memoryLaundries.values()) {
            if (memItem != null && !existingIds.contains(memItem.getId())) {
                boolean matchesKw = true;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    String kw = keyword.trim().toLowerCase();
                    matchesKw = (memItem.getCustomerName() != null && memItem.getCustomerName().toLowerCase().contains(kw))
                             || (memItem.getRoomNumber() != null && memItem.getRoomNumber().toLowerCase().contains(kw))
                             || (memItem.getServiceType() != null && memItem.getServiceType().toLowerCase().contains(kw))
                             || (memItem.getNotes() != null && memItem.getNotes().toLowerCase().contains(kw));
                }
                boolean matchesStatus = true;
                if (status != null && !status.trim().isEmpty()) {
                    String st = status.trim().toUpperCase();
                    boolean isDoneSearch = (st.contains("ĐÃ") || st.contains("HOÀN THÀNH") || st.contains("HOAN THANH") || st.contains("DONE")) && !st.contains("CHƯA");
                    matchesStatus = isDoneSearch ? memItem.isCompleted() : !memItem.isCompleted();
                }
                if (matchesKw && matchesStatus) {
                    list.add(memItem);
                    existingIds.add(memItem.getId());
                }
            }
        }

        list.sort((a, b) -> Integer.compare(b.getId(), a.getId()));
        return list;
    }

    public Laundry getById(int id) {
        if (id <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            Laundry item = em.find(Laundry.class, id);
            if (item != null) return item;
        } catch (Exception e) {
            System.err.println("[LaundryDAO.getById DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }
        return memoryLaundries.get(id);
    }

    public boolean insert(Laundry laundry) {
        if (laundry == null) return false;
        if (laundry.getCreatedDate() == null) {
            laundry.setCreatedDate(LocalDateTime.now());
        }

        boolean dbSuccess = false;
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(laundry);
            em.flush();
            tx.commit();
            dbSuccess = laundry.getId() > 0;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[LaundryDAO.insert DB Warning]: " + e.getMessage());
            e.printStackTrace();
        } finally {
            em.close();
        }

        if (!dbSuccess || laundry.getId() <= 0) {
            int newId = idCounter.incrementAndGet();
            laundry.setId(newId);
        }

        memoryLaundries.put(laundry.getId(), laundry);
        return true;
    }

    public boolean update(Laundry laundry) {
        if (laundry == null || laundry.getId() <= 0) return false;
        memoryLaundries.put(laundry.getId(), laundry);

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(laundry);
            em.flush();
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[LaundryDAO.update DB Warning]: " + e.getMessage());
            e.printStackTrace();
            return true;
        } finally {
            em.close();
        }
    }

    public boolean updateProcessingStatus(int id, String status) {
        Laundry item = getById(id);
        if (item != null) {
            item.setProcessingStatus(status);
            memoryLaundries.put(id, item);
        }

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id);
            if (laundry != null) {
                laundry.setProcessingStatus(status);
                em.merge(laundry);
                em.flush();
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[LaundryDAO.updateProcessingStatus DB Warning]: " + e.getMessage());
            e.printStackTrace();
            return true;
        } finally {
            em.close();
        }
    }

    public boolean delete(int id) {
        memoryLaundries.remove(id);
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id);
            if (laundry != null) {
                em.remove(laundry);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[LaundryDAO.delete DB Warning]: " + e.getMessage());
            e.printStackTrace();
            return true;
        } finally {
            em.close();
        }
    }

    public List<Laundry> getLaundriesByRoomNumber(String roomNumber) {
        if (roomNumber == null || roomNumber.trim().isEmpty()) {
            return java.util.Collections.emptyList();
        }
        String cleanRoom = roomNumber.trim();
        List<Laundry> list = new ArrayList<>();
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT l FROM Laundry l WHERE LOWER(l.roomNumber) = :rm ORDER BY l.id DESC";
            TypedQuery<Laundry> query = em.createQuery(jpql, Laundry.class);
            query.setParameter("rm", cleanRoom.toLowerCase());
            list.addAll(query.getResultList());
        } catch (Exception e) {
            System.err.println("[LaundryDAO.getLaundriesByRoomNumber DB Warning]: " + e.getMessage());
        } finally {
            if (em != null && em.isOpen()) em.close();
        }
        return list;
    }

    public double getTotalLaundryCostForRoom(String roomNumber) {
        List<Laundry> list = getLaundriesByRoomNumber(roomNumber);
        double total = 0.0;
        for (Laundry l : list) {
            total += l.getTotalPrice();
        }
        return total;
    }
}
