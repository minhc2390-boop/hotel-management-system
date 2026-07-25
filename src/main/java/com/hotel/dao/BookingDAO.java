package com.hotel.dao;

import com.hotel.model.Booking;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class BookingDAO {

    public List<Booking> getAllBookings() {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Booking b LEFT JOIN FETCH b.customer LEFT JOIN FETCH b.room r LEFT JOIN FETCH r.roomType LEFT JOIN FETCH b.createdBy ORDER BY b.bookingId DESC";
            TypedQuery<Booking> query = em.createQuery(jpql, Booking.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public List<Booking> getBookingsByUserId(int userId, String email) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Booking b LEFT JOIN FETCH b.customer LEFT JOIN FETCH b.room r LEFT JOIN FETCH r.roomType LEFT JOIN FETCH b.createdBy WHERE b.createdBy.id = :userId OR (b.customer.customerEmail = :email) ORDER BY b.bookingId DESC";
            TypedQuery<Booking> query = em.createQuery(jpql, Booking.class);
            query.setParameter("userId", userId);
            query.setParameter("email", email);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public Booking getBookingById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Booking b LEFT JOIN FETCH b.customer LEFT JOIN FETCH b.room r LEFT JOIN FETCH r.roomType LEFT JOIN FETCH b.createdBy WHERE b.bookingId = :id";
            TypedQuery<Booking> query = em.createQuery(jpql, Booking.class);
            query.setParameter("id", id);
            List<Booking> list = query.getResultList();
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

    public boolean insertBooking(Booking booking) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            // Merge customer and user to ensure they are attached to the current persistence context
            booking.setCustomer(em.merge(booking.getCustomer()));
            booking.setCreatedBy(em.merge(booking.getCreatedBy()));
            booking.setRoom(em.merge(booking.getRoom()));
            em.persist(booking);
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

    public boolean updateBooking(Booking booking) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(booking);
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

    public boolean updateBookingStatus(int id, String status) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Booking booking = em.find(Booking.class, id);
            if (booking != null) {
                booking.setStatus(status);
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

    public boolean deleteBooking(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Booking booking = em.find(Booking.class, id);
            if (booking != null) {
                em.remove(booking);
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
