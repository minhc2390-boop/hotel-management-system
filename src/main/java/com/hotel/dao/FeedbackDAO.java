package com.hotel.dao;

import com.hotel.model.Booking;
import com.hotel.model.Customer;
import com.hotel.model.Feedback;
import com.hotel.model.Room;
import com.hotel.model.User;
import com.hotel.util.AuthUtil;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.LockModeType;
import java.sql.Timestamp;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class FeedbackDAO {

    public List<Feedback> getAll() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT f FROM Feedback f "
                    + "LEFT JOIN FETCH f.booking b "
                    + "LEFT JOIN FETCH b.room r "
                    + "LEFT JOIN FETCH r.roomType "
                    + "LEFT JOIN FETCH b.customer "
                    + "LEFT JOIN FETCH f.customerUser "
                    + "ORDER BY f.createdAt DESC";
            return em.createQuery(jpql, Feedback.class).getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public boolean deleteFeedback(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Feedback f = em.find(Feedback.class, id);
            if (f != null) {
                em.remove(f);
            }
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public int deleteAllFeedbacks() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            int count = em.createQuery("DELETE FROM Feedback f").executeUpdate();
            tx.commit();
            return count;
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            e.printStackTrace();
            return 0;
        } finally {
            em.close();
        }
    }

    public Feedback getByBookingId(int bookingId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT f FROM Feedback f "
                    + "JOIN FETCH f.booking b "
                    + "JOIN FETCH b.room r "
                    + "JOIN FETCH r.roomType "
                    + "JOIN FETCH b.customer "
                    + "JOIN FETCH f.customerUser "
                    + "WHERE b.bookingId = :bookingId";
            List<Feedback> results = em.createQuery(jpql, Feedback.class)
                    .setParameter("bookingId", bookingId)
                    .setMaxResults(1)
                    .getResultList();
            return results.isEmpty() ? null : results.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public Set<Integer> getReviewedBookingIdsForUser(int userId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            List<Integer> ids = em.createQuery(
                            "SELECT f.booking.bookingId FROM Feedback f WHERE f.customerUser.id = :userId",
                            Integer.class)
                    .setParameter("userId", userId)
                    .getResultList();
            return new HashSet<>(ids);
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptySet();
        } finally {
            em.close();
        }
    }

    public boolean insertForCheckedOutBooking(Feedback feedback, int bookingId, int userId, String userEmail) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Booking booking = em.find(Booking.class, bookingId, LockModeType.PESSIMISTIC_WRITE);
            User user = em.find(User.class, userId);
            if (booking == null || user == null || !"CheckedOut".equals(booking.getStatus())) {
                tx.rollback();
                return false;
            }

            boolean ownsBooking = booking.getCreatedBy() != null && booking.getCreatedBy().getId() == userId;
            if (!ownsBooking && booking.getCustomer() != null && userEmail != null) {
                ownsBooking = userEmail.equalsIgnoreCase(booking.getCustomer().getCustomerEmail());
            }
            if (!ownsBooking) {
                tx.rollback();
                return false;
            }

            Long existingCount = em.createQuery(
                            "SELECT COUNT(f) FROM Feedback f WHERE f.booking.bookingId = :bookingId",
                            Long.class)
                    .setParameter("bookingId", bookingId)
                    .getSingleResult();
            if (existingCount > 0) {
                tx.rollback();
                return false;
            }

            feedback.setBooking(booking);
            feedback.setCustomerUser(user);
            em.persist(feedback);
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
