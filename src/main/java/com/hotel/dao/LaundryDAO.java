package com.hotel.dao;

import com.hotel.model.Bill;
import com.hotel.model.BillDetail;
import com.hotel.model.Booking;
import com.hotel.model.Laundry;
import com.hotel.model.Service;

import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.LockModeType;
import javax.persistence.TypedQuery;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.stream.Collectors;

public class LaundryDAO {

    public enum CompletionResult {
        COMPLETED_AND_BILLED(true),
        COMPLETED_PENDING_BILL(true),
        ALREADY_BILLED(true),
        ORDER_NOT_FOUND(false),
        ACTIVE_BOOKING_NOT_FOUND(false),
        DATABASE_ERROR(false);

        private final boolean success;

        CompletionResult(boolean success) {
            this.success = success;
        }

        public boolean isSuccess() {
            return success;
        }
    }

    public List<Laundry> getAllLaundries() {
        return searchLaundries("", "");
    }

    public List<Laundry> searchLaundries(String keyword, String status) {
        EntityManager em = DBContext.getEntityManager();
        try {
            StringBuilder jpql = new StringBuilder("SELECT l FROM Laundry l WHERE 1=1");
            if (keyword != null && !keyword.trim().isEmpty()) {
                jpql.append(" AND (LOWER(l.customerName) LIKE :keyword")
                    .append(" OR LOWER(l.roomNumber) LIKE :keyword")
                    .append(" OR LOWER(l.serviceType) LIKE :keyword")
                    .append(" OR LOWER(l.notes) LIKE :keyword)");
            }
            if (status != null && !status.trim().isEmpty()) {
                jpql.append(isCompletedStatus(status)
                        ? " AND UPPER(l.processingStatus) IN ('COMPLETED', 'DONE', 'ĐÃ HOÀN THÀNH', 'ĐÃ HOÀN TẤT')"
                        : " AND UPPER(l.processingStatus) IN ('PENDING', 'UNCOMPLETED', 'CHƯA HOÀN THÀNH', 'CHƯA HOÀN TẤT')");
            }
            jpql.append(" ORDER BY l.createdDate DESC, l.id DESC");

            TypedQuery<Laundry> query = em.createQuery(jpql.toString(), Laundry.class);
            if (keyword != null && !keyword.trim().isEmpty()) {
                query.setParameter("keyword", "%" + keyword.trim().toLowerCase(Locale.ROOT) + "%");
            }
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
            return Collections.emptyList();
        } finally {
            em.close();
        }
    }

    public Laundry getById(int id) {
        if (id <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            return em.find(Laundry.class, id);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    /**
     * Resolves the checked-in booking owned by the current customer. This keeps
     * a public form from placing a laundry charge on somebody else's room.
     */
    public Booking findActiveBookingForCustomer(String roomNumber, int userId, String userEmail) {
        if (roomNumber == null || roomNumber.trim().isEmpty() || userId <= 0) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT b FROM Booking b "
                    + "JOIN FETCH b.customer c JOIN FETCH b.room r LEFT JOIN FETCH b.createdBy u "
                    + "WHERE LOWER(r.roomNumber) = :roomNumber AND b.status = 'CheckedIn' "
                    + "AND (u.id = :userId OR LOWER(c.customerEmail) = :email) "
                    + "ORDER BY b.checkInDate DESC";
            List<Booking> bookings = em.createQuery(jpql, Booking.class)
                    .setParameter("roomNumber", roomNumber.trim().toLowerCase(Locale.ROOT))
                    .setParameter("userId", userId)
                    .setParameter("email", userEmail == null ? "" : userEmail.trim().toLowerCase(Locale.ROOT))
                    .setMaxResults(1)
                    .getResultList();
            return bookings.isEmpty() ? null : bookings.get(0);
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public boolean insert(Laundry laundry) {
        if (laundry == null) return false;
        if (laundry.getCreatedDate() == null) laundry.setCreatedDate(LocalDateTime.now());
        if (laundry.getStatusCode() == null) laundry.setProcessingStatus("Pending");

        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(laundry);
            em.flush();
            tx.commit();
            return laundry.getId() > 0;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }

    public boolean update(Laundry laundry) {
        if (laundry == null || laundry.getId() <= 0) return false;
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry managed = em.find(Laundry.class, laundry.getId(), LockModeType.PESSIMISTIC_WRITE);
            if (managed == null) {
                tx.rollback();
                return false;
            }
            managed.setCustomerName(laundry.getCustomerName());
            managed.setRoomNumber(laundry.getRoomNumber());
            managed.setServiceType(laundry.getServiceType());
            managed.setQuantity(laundry.getQuantity());
            managed.setTotalPrice(laundry.getTotalPrice());
            managed.setNotes(laundry.getNotes());
            if (managed.getBillDetailId() == null) {
                managed.setBookingId(laundry.getBookingId());
                managed.setProcessingStatus(laundry.getStatusCode());
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
     * Completes a laundry order exactly once. If an unpaid bill for the room
     * already exists, the charge is inserted immediately. In the current hotel
     * flow a bill is normally created at checkout; in that case the completed
     * order is kept as an unbilled charge and attached by BookingDAO in the same
     * checkout transaction.
     */
    public CompletionResult completeAndAddToBill(int laundryId) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, laundryId, LockModeType.PESSIMISTIC_WRITE);
            if (laundry == null) {
                tx.rollback();
                return CompletionResult.ORDER_NOT_FOUND;
            }
            if (laundry.getBillDetailId() != null) {
                laundry.setProcessingStatus("Completed");
                tx.commit();
                return CompletionResult.ALREADY_BILLED;
            }

            Booking booking = findChargeableBooking(em, laundry);
            if (booking == null) {
                tx.rollback();
                return CompletionResult.ACTIVE_BOOKING_NOT_FOUND;
            }
            laundry.setBookingId(booking.getBookingId());

            Bill bill = findOpenBillForRoom(em, booking.getRoom().getId());
            laundry.setProcessingStatus("Completed");
            if (bill == null) {
                tx.commit();
                return CompletionResult.COMPLETED_PENDING_BILL;
            }

            addChargeToBill(em, laundry, bill);
            tx.commit();
            return CompletionResult.COMPLETED_AND_BILLED;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
            return CompletionResult.DATABASE_ERROR;
        } finally {
            em.close();
        }
    }

    /**
     * Called from BookingDAO while checkout is creating the bill. The supplied
     * EntityManager belongs to that transaction, so booking, laundry charge and
     * invoice total either all commit or all roll back together.
     */
    public int attachCompletedOrdersToBill(EntityManager em, List<Booking> bookings, Bill bill) {
        if (em == null || bookings == null || bookings.isEmpty() || bill == null || bill.getId() <= 0) {
            return 0;
        }
        List<Integer> bookingIds = bookings.stream()
                .map(Booking::getBookingId)
                .collect(Collectors.toList());
        String jpql = "SELECT l FROM Laundry l WHERE l.bookingId IN :bookingIds "
                + "AND l.billDetailId IS NULL "
                + "AND UPPER(l.processingStatus) IN ('COMPLETED', 'DONE', 'ĐÃ HOÀN THÀNH', 'ĐÃ HOÀN TẤT') "
                + "ORDER BY l.createdDate, l.id";
        List<Laundry> orders = em.createQuery(jpql, Laundry.class)
                .setParameter("bookingIds", bookingIds)
                .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                .getResultList();
        for (Laundry order : orders) {
            addChargeToBill(em, order, bill);
        }
        return orders.size();
    }

    public boolean updateProcessingStatus(int id, String status) {
        if (isCompletedStatus(status)) {
            return completeAndAddToBill(id).isSuccess();
        }
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id, LockModeType.PESSIMISTIC_WRITE);
            if (laundry == null || laundry.getBillDetailId() != null) {
                tx.rollback();
                return false;
            }
            laundry.setProcessingStatus("Pending");
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

    public boolean delete(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Laundry laundry = em.find(Laundry.class, id, LockModeType.PESSIMISTIC_WRITE);
            if (laundry == null || laundry.getBillDetailId() != null) {
                tx.rollback();
                return false;
            }
            em.remove(laundry);
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

    private Booking findChargeableBooking(EntityManager em, Laundry laundry) {
        if (laundry.getBookingId() != null && laundry.getBookingId() > 0) {
            Booking booking = em.find(Booking.class, laundry.getBookingId(), LockModeType.PESSIMISTIC_WRITE);
            if (booking != null && ("CheckedIn".equals(booking.getStatus())
                    || "CheckedOut".equals(booking.getStatus())
                    || "Completed".equalsIgnoreCase(booking.getStatus()))) {
                booking.getRoom().getRoomNumber();
                return booking;
            }
        }

        String jpql = "SELECT b FROM Booking b JOIN FETCH b.room r JOIN FETCH b.customer "
                + "LEFT JOIN FETCH b.createdBy "
                + "WHERE LOWER(r.roomNumber) = :roomNumber AND b.status = 'CheckedIn' "
                + "ORDER BY b.checkInDate DESC";
        List<Booking> bookings = em.createQuery(jpql, Booking.class)
                .setParameter("roomNumber", laundry.getRoomNumber().trim().toLowerCase(Locale.ROOT))
                .setMaxResults(1)
                .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                .getResultList();
        return bookings.isEmpty() ? null : bookings.get(0);
    }

    private Bill findOpenBillForRoom(EntityManager em, int roomId) {
        String jpql = "SELECT DISTINCT b FROM Bill b, BillDetail bd "
                + "WHERE bd.billId = b.id AND bd.room.id = :roomId AND b.status = 'Unpaid' "
                + "ORDER BY b.id DESC";
        List<Bill> bills = em.createQuery(jpql, Bill.class)
                .setParameter("roomId", roomId)
                .setMaxResults(1)
                .setLockMode(LockModeType.PESSIMISTIC_WRITE)
                .getResultList();
        return bills.isEmpty() ? null : bills.get(0);
    }

    private void addChargeToBill(EntityManager em, Laundry laundry, Bill bill) {
        if (laundry.getBillDetailId() != null) return;

        int quantity = Math.max(1, laundry.getQuantity());
        double total = Math.max(0, laundry.getTotalPrice());
        double unitPrice = total / quantity;
        Service service = getOrCreateLaundryService(em, laundry.getServiceType(), unitPrice);

        BillDetail detail = new BillDetail();
        detail.setBillId(bill.getId());
        detail.setService(service);
        detail.setQuantity(quantity);
        detail.setPrice(unitPrice);
        em.persist(detail);
        em.flush();

        bill.setTotalAmount(bill.getTotalAmount() + total);
        laundry.setBillId(bill.getId());
        laundry.setBillDetailId(detail.getId());
        laundry.setProcessingStatus("Completed");
    }

    private Service getOrCreateLaundryService(EntityManager em, String serviceType, double unitPrice) {
        String normalizedType = serviceType == null || serviceType.trim().isEmpty()
                ? "Giặt sấy thông thường" : serviceType.trim();
        String serviceName = "Giặt ủi - " + normalizedType;
        List<Service> services = em.createQuery(
                        "SELECT s FROM Service s WHERE LOWER(s.name) = :name", Service.class)
                .setParameter("name", serviceName.toLowerCase(Locale.ROOT))
                .setMaxResults(1)
                .getResultList();
        if (!services.isEmpty()) return services.get(0);

        Service service = new Service();
        service.setName(serviceName);
        service.setPrice(unitPrice);
        service.setDescription("Dịch vụ được tạo tự động từ đơn giặt ủi.");
        service.setStatus("Active");
        service.setUnit("Món");
        em.persist(service);
        em.flush();
        return service;
    }

    private static boolean isCompletedStatus(String status) {
        if (status == null) return false;
        String normalized = status.trim().toUpperCase(Locale.ROOT);
        return normalized.contains("COMPLETED")
                || normalized.contains("DONE")
                || normalized.contains("ĐÃ")
                || normalized.contains("HOÀN THÀNH")
                || normalized.contains("HOAN THANH")
                || normalized.contains("HOÀN TẤT")
                || normalized.contains("HOAN TAT");
    }
}
