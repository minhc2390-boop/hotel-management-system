package com.hotel.dao;

import com.hotel.model.Booking;
import com.hotel.model.Bill;
import com.hotel.model.BillDetail;
import com.hotel.model.Room;
import com.hotel.model.User;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.LockModeType;
import javax.persistence.TypedQuery;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

public class BookingDAO {

    /**
     * Lấy toàn bộ danh sách đặt phòng trong hệ thống.
     */
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

    /**
     * [RBAC Phân quyền Hệ thống]
     * Lấy danh sách đặt phòng theo quyền hạn người dùng:
     * - Admin: Xem toàn bộ lịch sử đặt phòng của tất cả nhân viên.
     * - Staff/Receptionist: Chỉ xem danh sách các đơn do chính mình tạo (createdBy.id).
     */
    public List<Booking> getBookingsByRole(User user) {
        if (user == null) {
            return Collections.emptyList();
        }

        EntityManager em = DBContext.getEntityManager();
        try {
            boolean isAdmin = "ADMIN".equalsIgnoreCase(user.getRole());

            StringBuilder jpql = new StringBuilder(
                "SELECT b FROM Booking b " +
                "LEFT JOIN FETCH b.customer " +
                "LEFT JOIN FETCH b.room r " +
                "LEFT JOIN FETCH r.roomType " +
                "LEFT JOIN FETCH b.createdBy "
            );

            if (!isAdmin) {
                jpql.append("WHERE b.createdBy.id = :userId ");
            }
            jpql.append("ORDER BY b.bookingId DESC");

            TypedQuery<Booking> query = em.createQuery(jpql.toString(), Booking.class);
            if (!isAdmin) {
                query.setParameter("userId", user.getId());
            }

            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return Collections.emptyList();
    }

    /**
     * [Ràng buộc & Logic Đặt phòng - Khóa phòng]
     * Kiểm tra phòng (roomId) có bị trùng lịch trong khoảng thời gian [checkIn, checkOut] hay không.
     * Công thức: (CheckIn_Mới < CheckOut_Cũ) AND (CheckOut_Mới > CheckIn_Cũ)
     * 
     * @return true nếu phòng CÒN TRỐNG (Khả dụng), false nếu ĐÃ BỊ ĐẶT TRÙNG.
     */
    public boolean isRoomAvailable(int roomId, java.util.Date checkIn, java.util.Date checkOut) {
        if (checkIn == null || checkOut == null || !checkOut.after(checkIn)) {
            return false;
        }

        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT COUNT(b) FROM Booking b " +
                          "WHERE b.room.id = :roomId " +
                          "  AND b.status NOT IN ('Cancelled', 'CANCELLED', 'CheckedOut', 'CHECKED_OUT') " +
                          "  AND :checkIn < b.checkOutDate " +
                          "  AND :checkOut > b.checkInDate";

            TypedQuery<Long> query = em.createQuery(jpql, Long.class);
            query.setParameter("roomId", roomId);
            query.setParameter("checkIn", checkIn);
            query.setParameter("checkOut", checkOut);

            Long count = query.getSingleResult();
            return count != null && count == 0;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return false;
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

    public boolean cancelBooking(int id, String cancellationReason) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Booking booking = em.find(Booking.class, id, LockModeType.PESSIMISTIC_WRITE);
            if (booking == null
                    || (!"Pending".equals(booking.getStatus()) && !"Confirmed".equals(booking.getStatus()))) {
                tx.rollback();
                return false;
            }
            Room room = em.find(Room.class, booking.getRoom().getId(), LockModeType.PESSIMISTIC_WRITE);
            booking.setStatus("Cancelled");
            booking.setCancellationReason(cancellationReason);
            if (room != null) room.setStatus("Available");
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

    /**
     * Checks in one or more rooms atomically. Every selected booking must belong
     * to the same customer and still be waiting for check-in.
     */
    public boolean checkInBookings(List<Integer> bookingIds) {
        if (bookingIds == null || bookingIds.isEmpty()) {
            return false;
        }

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<Booking> bookings = getBookingsForUpdate(em, bookingIds);
            if (!isValidBulkSelection(bookings, bookingIds, false)) {
                tx.rollback();
                return false;
            }

            for (Booking booking : bookings) {
                booking.setStatus("CheckedIn");
                booking.getRoom().setStatus("Occupied");
            }
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

    /**
     * Checks out rooms of one customer in one transaction and creates one bill
     * containing a separate room-charge detail for every selected booking.
     *
     * @return the generated bill id, or -1 when validation/persistence fails
     */
    public int checkOutBookings(List<Integer> bookingIds, int fallbackUserId) {
        if (bookingIds == null || bookingIds.isEmpty()) {
            return -1;
        }

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            List<Booking> bookings = getBookingsForUpdate(em, bookingIds);
            if (!isValidBulkSelection(bookings, bookingIds, true)) {
                tx.rollback();
                return -1;
            }

            Booking firstBooking = bookings.get(0);
            User billCreator = firstBooking.getCreatedBy();
            if (billCreator == null && fallbackUserId > 0) {
                billCreator = em.find(User.class, fallbackUserId);
            }
            if (billCreator == null) {
                billCreator = em.find(User.class, 1);
            }
            if (billCreator == null) {
                tx.rollback();
                return -1;
            }

            double totalAmount = 0;
            java.sql.Timestamp earliestCheckIn = firstBooking.getCheckInDate();
            java.sql.Timestamp latestCheckOut = firstBooking.getCheckOutDate();
            for (Booking booking : bookings) {
                int days = calculateStayDays(booking);
                totalAmount += days * booking.getRoomPrice();
                if (booking.getCheckInDate().before(earliestCheckIn)) {
                    earliestCheckIn = booking.getCheckInDate();
                }
                if (booking.getCheckOutDate().after(latestCheckOut)) {
                    latestCheckOut = booking.getCheckOutDate();
                }
            }

            Bill bill = new Bill();
            bill.setUser(billCreator);
            bill.setCustomer(firstBooking.getCustomer());
            bill.setCheckInDate(earliestCheckIn);
            bill.setCheckOutDate(latestCheckOut);
            bill.setTotalAmount(totalAmount);
            bill.setStatus("Unpaid");
            em.persist(bill);
            em.flush();

            for (Booking booking : bookings) {
                BillDetail roomCharge = new BillDetail();
                roomCharge.setBillId(bill.getId());
                roomCharge.setRoom(booking.getRoom());
                roomCharge.setQuantity(calculateStayDays(booking));
                roomCharge.setPrice(booking.getRoomPrice());
                em.persist(roomCharge);

                booking.setStatus("CheckedOut");
                booking.getRoom().setStatus("Available");
            }

            // A bill does not exist while the guest is staying. Completed,
            // unbilled laundry orders are therefore attached atomically as
            // soon as checkout creates the bill.
            new LaundryDAO().attachCompletedOrdersToBill(em, bookings, bill);

            tx.commit();
            return bill.getId();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return -1;
        } finally {
            em.close();
        }
    }

    private List<Booking> getBookingsForUpdate(EntityManager em, List<Integer> bookingIds) {
        Set<Integer> uniqueIds = new HashSet<>(bookingIds);
        if (uniqueIds.size() != bookingIds.size()) {
            return Collections.emptyList();
        }

        String jpql = "SELECT b FROM Booking b "
                + "JOIN FETCH b.customer JOIN FETCH b.room "
                + "LEFT JOIN FETCH b.createdBy "
                + "WHERE b.bookingId IN :bookingIds";
        List<Booking> bookings = em.createQuery(jpql, Booking.class)
                .setParameter("bookingIds", uniqueIds)
                .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                .getResultList();
        bookings.sort(Comparator.comparingInt(Booking::getBookingId));
        return bookings;
    }

    private boolean isValidBulkSelection(List<Booking> bookings,
                                         List<Integer> requestedIds,
                                         boolean checkout) {
        if (bookings == null || bookings.size() != requestedIds.size()) {
            return false;
        }

        int customerId = bookings.get(0).getCustomer().getCustomerId();
        for (Booking booking : bookings) {
            if (booking.getCustomer() == null
                    || booking.getCustomer().getCustomerId() != customerId
                    || booking.getRoom() == null) {
                return false;
            }
            if (checkout) {
                if (!"CheckedIn".equals(booking.getStatus())) return false;
            } else if (!"Pending".equals(booking.getStatus())
                    && !"Confirmed".equals(booking.getStatus())) {
                return false;
            }
        }
        return true;
    }

    private int calculateStayDays(Booking booking) {
        long diffMs = booking.getCheckOutDate().getTime() - booking.getCheckInDate().getTime();
        long dayMs = 1000L * 60 * 60 * 24;
        long days = diffMs / dayMs;
        return (int) Math.max(1, days);
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
