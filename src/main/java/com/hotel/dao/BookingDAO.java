package com.hotel.dao;

import com.hotel.model.Booking;
import com.hotel.model.Room;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.LockModeType;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
        return insertBookings(Collections.singletonList(booking));
    }

    /**
     * Creates all requested bookings and marks their rooms as booked in one
     * transaction. A pessimistic lock prevents two concurrent requests from
     * reserving the same room.
     */
    public boolean insertBookings(List<Booking> bookings) {
        if (bookings == null || bookings.isEmpty()) {
            return false;
        }

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Set<Integer> roomIds = new HashSet<>();

            for (Booking booking : bookings) {
                if (booking == null || booking.getRoom() == null
                        || booking.getCustomer() == null || booking.getCreatedBy() == null) {
                    throw new IllegalArgumentException("Booking data is incomplete");
                }

                int roomId = booking.getRoom().getId();
                if (roomId <= 0 || !roomIds.add(roomId)) {
                    throw new IllegalArgumentException("Duplicate or invalid room id: " + roomId);
                }

                Room managedRoom = em.find(Room.class, roomId, LockModeType.PESSIMISTIC_WRITE);
                if (managedRoom == null || !"Available".equalsIgnoreCase(managedRoom.getStatus())) {
                    throw new IllegalStateException("Room is no longer available: " + roomId);
                }

                booking.setCustomer(em.merge(booking.getCustomer()));
                booking.setCreatedBy(em.merge(booking.getCreatedBy()));
                booking.setRoom(managedRoom);
                managedRoom.setStatus("Booked");
                em.persist(booking);
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

    public List<Booking> getBookingsByCustomerId(int customerId) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Booking b LEFT JOIN FETCH b.customer LEFT JOIN FETCH b.room r LEFT JOIN FETCH r.roomType LEFT JOIN FETCH b.createdBy WHERE b.customer.customerId = :customerId ORDER BY b.bookingId DESC";
            TypedQuery<Booking> query = em.createQuery(jpql, Booking.class);
            query.setParameter("customerId", customerId);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
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
