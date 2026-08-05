package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "EQUIPMENTS")
public class Equipment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "equipment_id")
    private int equipmentId;

    @Column(name = "equipment_name", nullable = false, unique = true, columnDefinition = "NVARCHAR(100)")
    private String equipmentName;

    @Column(name = "total_quantity", nullable = false)
    private int totalQuantity;

    @Column(name = "unit", columnDefinition = "NVARCHAR(20)")
    private String unit;

    @Column(name = "status")
    private String status; // Active, Maintenance, OutOfStock

    @Column(name = "description", columnDefinition = "NVARCHAR(500)")
    private String description;

    public Equipment() {}

    public Equipment(String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.equipmentName = equipmentName;
        this.totalQuantity = totalQuantity;
        this.unit = unit;
        this.status = status;
        this.description = description;
    }

    public Equipment(int equipmentId, String equipmentName, int totalQuantity, String unit, String status, String description) {
        this.equipmentId = equipmentId;
        this.equipmentName = equipmentName;
        this.totalQuantity = totalQuantity;
        this.unit = unit;
        this.status = status;
        this.description = description;
    }

    public int getEquipmentId() {
        return equipmentId;
    }

    public void setEquipmentId(int equipmentId) {
        this.equipmentId = equipmentId;
    }

    public String getEquipmentName() {
        return equipmentName;
    }

    public void setEquipmentName(String equipmentName) {
        this.equipmentName = equipmentName;
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
