package com.hotel.dao;

import com.hotel.model.Equipment;
import com.hotel.model.Room;
import com.hotel.model.RoomType;
import javax.persistence.EntityManager;
import javax.persistence.EntityTransaction;
import javax.persistence.TypedQuery;
import java.util.List;

public class RoomDAO {

    public void syncRoomStatuses() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            java.util.Date now = new java.util.Date();

            // 1. Tìm tất cả các phòng đang có khách ở (CheckedIn) hoặc có lịch đặt hiệu lực ngay tại thời điểm hiện tại
            String activeRoomJpql = "SELECT DISTINCT b.room.id FROM Booking b WHERE b.room IS NOT NULL AND (" +
                                    "b.status = 'CheckedIn' OR " +
                                    "((b.status = 'Pending' OR b.status = 'Confirmed') AND :now >= b.checkInDate AND :now <= b.checkOutDate)" +
                                    ")";
            List<Integer> activeBookedRoomIds = em.createQuery(activeRoomJpql, Integer.class)
                    .setParameter("now", now)
                    .getResultList();
            java.util.Set<Integer> activeSet = new java.util.HashSet<>(activeBookedRoomIds);

            // 2. Lấy danh sách phòng và cập nhật trạng thái
            List<Room> rooms = em.createQuery("SELECT r FROM Room r", Room.class).getResultList();
            for (Room r : rooms) {
                // Giữ nguyên nếu phòng đang Bảo trì, Đang dọn dẹp hoặc Đã ngưng hoạt động (Inactive)
                if ("Maintenance".equalsIgnoreCase(r.getStatus()) || "Cleaning".equalsIgnoreCase(r.getStatus()) || "Inactive".equalsIgnoreCase(r.getStatus())) {
                    continue;
                }

                if (activeSet.contains(r.getId())) {
                    if (!"Booked".equalsIgnoreCase(r.getStatus())) {
                        r.setStatus("Booked");
                        em.merge(r);
                    }
                } else {
                    if (!"Available".equalsIgnoreCase(r.getStatus())) {
                        r.setStatus("Available");
                        em.merge(r);
                    }
                }
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[RoomDAO.syncRoomStatuses DB Warning]: " + e.getMessage());
        } finally {
            em.close();
        }
    }

    public void ensureDefaultRooms() {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Long count = em.createQuery("SELECT COUNT(r) FROM Room r", Long.class).getSingleResult();
            if (count == null || count == 0) {
                List<com.hotel.model.RoomType> types = em.createQuery("SELECT t FROM com.hotel.model.RoomType t", com.hotel.model.RoomType.class).getResultList();
                com.hotel.model.RoomType std = null, del = null, suite = null;
                if (types.isEmpty()) {
                    std = new com.hotel.model.RoomType("Standard", 450000.0, 2, "Phòng tiêu chuẩn ấm cúng, trang bị đầy đủ tiện nghi cơ bản.");
                    del = new com.hotel.model.RoomType("Deluxe", 850000.0, 2, "Phòng cao cấp với hướng nhìn ra thành phố và ban công thoáng mát.");
                    suite = new com.hotel.model.RoomType("Executive Suite", 1500000.0, 4, "Căn hộ Suite sang trọng bậc nhất với phòng khách riêng biệt.");
                    em.persist(std);
                    em.persist(del);
                    em.persist(suite);
                    em.flush();
                } else {
                    for (com.hotel.model.RoomType t : types) {
                        if (t.getName().toLowerCase().contains("standard")) std = t;
                        else if (t.getName().toLowerCase().contains("deluxe")) del = t;
                        else if (t.getName().toLowerCase().contains("suite")) suite = t;
                    }
                    if (std == null) std = types.get(0);
                    if (del == null) del = types.get(0);
                    if (suite == null) suite = types.get(types.size() - 1);
                }

                Room r101 = new Room("101", std.getId(), "Available", "Phòng Standard tầng 1, giường đôi êm ái.");
                r101.setRoomType(std);
                Room r102 = new Room("102", std.getId(), "Available", "Phòng Standard tầng 1 hướng vườn xanh mát.");
                r102.setRoomType(std);
                Room r201 = new Room("201", del.getId(), "Available", "Phòng Deluxe tầng 2, ban công nhìn toàn cảnh.");
                r201.setRoomType(del);
                Room r202 = new Room("202", del.getId(), "Available", "Phòng Deluxe tầng 2 với thiết bị hiện đại.");
                r202.setRoomType(del);
                Room r301 = new Room("301", suite.getId(), "Available", "Phòng Suite VIP tầng 3 với dịch vụ đặc biệt.");
                r301.setRoomType(suite);
                Room r302 = new Room("302", suite.getId(), "Available", "Phòng Suite gia đình tầng 3 đầy đủ tiện nghi.");
                r302.setRoomType(suite);

                em.persist(r101);
                em.persist(r102);
                em.persist(r201);
                em.persist(r202);
                em.persist(r301);
                em.persist(r302);
            } else {
                List<Room> rooms = em.createQuery("SELECT r FROM Room r WHERE r.status != 'Maintenance'", Room.class).getResultList();
                for (Room r : rooms) {
                    if (!"Booked".equalsIgnoreCase(r.getStatus()) && !"Available".equalsIgnoreCase(r.getStatus())) {
                        r.setStatus("Available");
                        em.merge(r);
                    }
                }
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) tx.rollback();
            System.err.println("[RoomDAO.ensureDefaultRooms Warning]: " + e.getMessage());
        } finally {
            em.close();
        }
    }

    public List<Room> getAllRooms() {
        ensureDefaultRooms();
        syncRoomStatuses();
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r ORDER BY r.roomNumber ASC";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            return query.getResultList();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return java.util.Collections.emptyList();
    }

    public List<Room> getAvailableRooms() {
        ensureDefaultRooms();
        syncRoomStatuses();
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r WHERE UPPER(r.status) = 'AVAILABLE' ORDER BY r.roomNumber ASC";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            List<Room> list = query.getResultList();
            if (list != null) {
                return list;
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return java.util.Collections.emptyList();
    }

    public Room getRoomById(int id) {
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r WHERE r.id = :id";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            query.setParameter("id", id);
            List<Room> list = query.getResultList();
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

    public boolean insertRoomWithEquipments(Room room, List<com.hotel.model.Equipment> equipments) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (room.getRoomType() != null && room.getRoomType().getId() > 0) {
                room.setRoomType(em.find(com.hotel.model.RoomType.class, room.getRoomType().getId()));
            }
            em.persist(room);
            em.flush();

            if (equipments != null && !equipments.isEmpty()) {
                for (com.hotel.model.Equipment eq : equipments) {
                    if (eq.getEquipmentName() != null && !eq.getEquipmentName().trim().isEmpty()) {
                        eq.setRoom(room);
                        em.persist(eq);
                    }
                }
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

    public boolean insertRoom(Room room) {
        return insertRoomWithEquipments(room, null);
    }

    public boolean updateRoom(Room room) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            if (room.getRoomType() != null && room.getRoomType().getId() > 0) {
                room.setRoomType(em.find(com.hotel.model.RoomType.class, room.getRoomType().getId()));
            }
            em.merge(room);
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

    public boolean updateRoomStatus(int id, String status) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Room room = em.find(Room.class, id);
            if (room != null) {
                room.setStatus(status);
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

    public Room getRoomByNumber(String roomNumber) {
        if (roomNumber == null || roomNumber.trim().isEmpty()) return null;
        EntityManager em = DBContext.getEntityManager();
        try {
            String jpql = "SELECT r FROM Room r WHERE LOWER(TRIM(r.roomNumber)) = LOWER(TRIM(:num))";
            TypedQuery<Room> query = em.createQuery(jpql, Room.class);
            query.setParameter("num", roomNumber.trim());
            List<Room> list = query.getResultList();
            if (list != null && !list.isEmpty()) {
                return list.get(0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            em.close();
        }
        return null;
    }

    public boolean deleteRoom(int id) {
        EntityManager em = DBContext.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Room room = em.find(Room.class, id);
            if (room != null) {
                // Kiểm tra xem phòng đã có lịch sử đặt phòng hoặc chi tiết hóa đơn chưa
                Long bookingCount = em.createQuery("SELECT COUNT(b) FROM Booking b WHERE b.room.id = :rid", Long.class)
                        .setParameter("rid", id).getSingleResult();
                Long billDetailCount = em.createQuery("SELECT COUNT(bd) FROM BillDetail bd WHERE bd.room.id = :rid", Long.class)
                        .setParameter("rid", id).getSingleResult();

                // Nếu có giao dịch lịch sử -> Chuyển trạng thái sang Inactive (Xóa mềm) để bảo toàn dữ liệu
                if ((bookingCount != null && bookingCount > 0) || (billDetailCount != null && billDetailCount > 0)) {
                    room.setStatus("Inactive");
                    em.merge(room);
                    tx.commit();
                    return true;
                }

                em.createNativeQuery("DELETE FROM Equipments WHERE room_id = :rid")
                  .setParameter("rid", id)
                  .executeUpdate();
                em.remove(room);
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
