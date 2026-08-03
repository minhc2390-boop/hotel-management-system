package com.hotel.model;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "Laundry")
public class Laundry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "customer_name", nullable = false, length = 150)
    private String customerName;

    @Column(name = "room_number", nullable = false, length = 20)
    private String roomNumber;

    @Column(name = "service_type", length = 100)
    private String serviceType;

    @Column(name = "quantity")
    private int quantity = 1;

    @Column(name = "total_price")
    private double totalPrice = 0.0;

    @Column(name = "processing_status", nullable = false, length = 20)
    private String processingStatus = "Chưa hoàn tất";

    @Column(name = "notes", length = 500)
    private String notes;

    @Column(name = "created_date")
    private LocalDateTime createdDate = LocalDateTime.now();

    public Laundry() {}

    public Laundry(int id, String customerName, String roomNumber, String serviceType, int quantity, double totalPrice, String processingStatus, String notes, LocalDateTime createdDate) {
        this.id = id;
        this.customerName = customerName;
        this.roomNumber = roomNumber;
        this.serviceType = serviceType;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.processingStatus = processingStatus;
        this.notes = notes;
        this.createdDate = createdDate;
    }

    public Laundry(String customerName, String roomNumber, String serviceType, int quantity, double totalPrice, String processingStatus, String notes) {
        this.customerName = customerName;
        this.roomNumber = roomNumber;
        this.serviceType = serviceType;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        this.processingStatus = (processingStatus != null && !processingStatus.trim().isEmpty()) ? processingStatus : "Chưa hoàn tất";
        this.notes = notes;
        this.createdDate = LocalDateTime.now();
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getServiceType() {
        return serviceType;
    }

    public void setServiceType(String serviceType) {
        this.serviceType = serviceType;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getTotalPrice() {
        return totalPrice;
    }

    public void setTotalPrice(double totalPrice) {
        this.totalPrice = totalPrice;
    }

    public String getProcessingStatus() {
        return processingStatus;
    }

    public void setProcessingStatus(String processingStatus) {
        this.processingStatus = processingStatus;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    @Override
    public String toString() {
        return "Laundry{" +
                "id=" + id +
                ", customerName='" + customerName + '\'' +
                ", roomNumber='" + roomNumber + '\'' +
                ", serviceType='" + serviceType + '\'' +
                ", quantity=" + quantity +
                ", totalPrice=" + totalPrice +
                ", processingStatus='" + processingStatus + '\'' +
                ", notes='" + notes + '\'' +
                ", createdDate=" + createdDate +
                '}';
    }
}
