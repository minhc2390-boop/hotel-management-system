package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "Rooms")
public class Room {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "room_number", nullable = false, unique = true)
    private String roomNumber;

    @Transient
    private int roomTypeId;

    @Column(name = "status", nullable = false)
    private String status; // Available, Booked, Maintenance

    @Column(name = "description")
    private String description;
    
    // Joint object mapped by JPA
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "room_type_id", nullable = false)
    private RoomType roomType;

    public Room() {}

    public Room(int id, String roomNumber, int roomTypeId, String status, String description) {
        this.id = id;
        this.roomNumber = roomNumber;
        setRoomTypeId(roomTypeId);
        this.status = status;
        this.description = description;
    }

    public Room(String roomNumber, int roomTypeId, String status, String description) {
        this.roomNumber = roomNumber;
        setRoomTypeId(roomTypeId);
        this.status = status;
        this.description = description;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public int getRoomTypeId() {
        if (roomType != null) {
            return roomType.getId();
        }
        return roomTypeId;
    }

    public void setRoomTypeId(int roomTypeId) {
        this.roomTypeId = roomTypeId;
        if (this.roomType == null) {
            this.roomType = new RoomType();
        }
        this.roomType.setId(roomTypeId);
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public RoomType getRoomType() {
        return roomType;
    }

    public void setRoomType(RoomType roomType) {
        this.roomType = roomType;
        if (roomType != null) {
            this.roomTypeId = roomType.getId();
        }
    }

    @Override
    public String toString() {
        return "Room{" +
                "id=" + id +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomTypeId=" + getRoomTypeId() +
                ", status='" + status + '\'' +
                '}';
    }
}
