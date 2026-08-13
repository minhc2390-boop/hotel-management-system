package com.hotel.dao;

import com.hotel.model.Room;
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
            List<Room> rooms = em.createQuery("SELECT r FROM Room r", Room.class).getResultList();
            for (Room r : rooms) {
                if ("Maintenance".equalsIgnoreCase(r.getStatus()) || "Cleaning".equalsIgnoreCase(r.getStatus())) {
                    continue;
                }

                Long occupiedCount = em.createQuery(
                    "SELECT COUNT(b) FROM Booking b WHERE b.room.id = :rid AND b.status = 'CheckedIn'", Long.class)
                    .setParameter("rid", r.getId())
                    .getSingleResult();

                Long bookedCount = em.createQuery(
                    "SELECT COUNT(b) FROM Booking b WHERE b.room.id = :rid AND (b.status = 'Pending' OR b.status = 'Confirmed')", Long.class)
                    .setParameter("rid", r.getId())
                    .getSingleResult();

                if (occupiedCount != null && occupiedCount > 0) {
                    if (!"Occupied".equalsIgnoreCase(r.getStatus())) {
                        r.setStatus("Occupied");
                        em.merge(r);
                    }
                } else if (bookedCount != null && bookedCount > 0) {
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
                    if (!"Occupied".equalsIgnoreCase(r.getStatus()) && !"Available".equalsIgnoreCase(r.getStatus())) {
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
