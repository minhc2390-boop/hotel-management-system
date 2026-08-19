package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "EQUIPMENTS")
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "equipment_id")
    private int equipmentId;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "room_id", nullable = true)
    private Room room;

    @Column(name = "equipment_name", nullable = false, columnDefinition = "NVARCHAR(150)")
    private String equipmentName;

    @Column(name = "total_quantity", nullable = false)
    private int totalQuantity = 1;

    @Column(name = "unit", columnDefinition = "NVARCHAR(20)")
    private String unit = "Cái";

    @Column(name = "status", columnDefinition = "NVARCHAR(50)")
    private String status = "Hoạt động tốt"; // Hoạt động tốt, Cần kiểm tra, Bảo trì, Hỏng

    @Column(name = "description", columnDefinition = "NVARCHAR(500)")
    private String description;

    public Equipment() {}

    public Equipment(String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.equipmentName = com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
        this.totalQuantity = totalQuantity;
        this.unit = com.hotel.util.EncodingUtil.fixEncoding(unit);
        this.status = com.hotel.util.EncodingUtil.fixEncoding(status);
        this.description = com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public Equipment(Room room, String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.room = room;
        this.equipmentName = com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
        this.totalQuantity = totalQuantity;
        this.unit = com.hotel.util.EncodingUtil.fixEncoding(unit);
        this.status = com.hotel.util.EncodingUtil.fixEncoding(status);
        this.description = com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public Equipment(int equipmentId, Room room, String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.equipmentId = equipmentId;
        this.room = room;
        this.equipmentName = com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
        this.totalQuantity = totalQuantity;
        this.unit = com.hotel.util.EncodingUtil.fixEncoding(unit);
        this.status = com.hotel.util.EncodingUtil.fixEncoding(status);
        this.description = com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public Equipment(int equipmentId, String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.equipmentId = equipmentId;
        this.equipmentName = com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
        this.totalQuantity = totalQuantity;
        this.unit = com.hotel.util.EncodingUtil.fixEncoding(unit);
        this.status = com.hotel.util.EncodingUtil.fixEncoding(status);
        this.description = com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public Integer getRoomId() {
        return room != null ? room.getId() : null;
    }

    public String getRoomNumber() {
        return room != null ? room.getRoomNumber() : null;
    }

    public String getEquipmentName() {
        return com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
    }

    public void setEquipmentName(String equipmentName) {
        this.equipmentName = com.hotel.util.EncodingUtil.fixEncoding(equipmentName);
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }

    public String getUnit() {
        return com.hotel.util.EncodingUtil.fixEncoding(unit);
    }

    public void setUnit(String unit) {
        this.unit = com.hotel.util.EncodingUtil.fixEncoding(unit);
    }

    public String getStatus() {
        return com.hotel.util.EncodingUtil.fixEncoding(status);
    }

    public void setStatus(String status) {
        this.status = com.hotel.util.EncodingUtil.fixEncoding(status);
    }

    public String getDescription() {
        return com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public void setDescription(String description) {
        this.description = com.hotel.util.EncodingUtil.fixEncoding(description);
    }
}
