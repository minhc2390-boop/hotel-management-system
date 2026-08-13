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

    @Column(name = "processing_status", nullable = false, length = 100)
    private String processingStatus = "PENDING";

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
        return com.hotel.util.EncodingUtil.fixEncoding(customerName);
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
        if (serviceType == null || serviceType.trim().isEmpty()) {
            return "Giặt sấy thông thường";
        }
        String str = com.hotel.util.EncodingUtil.fixEncoding(serviceType.trim());

        String lower = str.toLowerCase();
        if (lower.contains("sấy") || lower.contains("say") || lower.contains("thông thường") || lower.contains("thong thuong")) {
            return "Giặt sấy thông thường";
        }
        if (lower.contains("khô") || lower.contains("kho") || lower.contains("dry cleaning")) {
            return "Giặt khô (Dry Cleaning)";
        }
        if (lower.contains("ủi") || lower.contains("ui quan ao")) {
            return "Ủi quần áo";
        }
        if (lower.contains("hấp") || lower.contains("hap cao cap")) {
            return "Giặt hấp cao cấp";
        }
        if (lower.contains("tẩy") || lower.contains("tay vet ban")) {
            return "Tẩy vết bẩn đặc biệt";
        }
        return str;
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
        if (processingStatus == null || processingStatus.trim().isEmpty()) {
            return "Chưa hoàn thành";
        }
        String s = com.hotel.util.EncodingUtil.fixEncoding(processingStatus.trim()).toUpperCase();
        if (s.contains("CHƯA") || s.contains("CHUA") || s.contains("PENDING") || s.contains("UNCOMPLETED")) {
            return "Chưa hoàn thành";
        }
        if (s.contains("DONE") || s.contains("COMPLETED") || s.contains("ĐÃ") || s.contains("DA") || s.contains("HOÀN THÀNH") || s.contains("HOAN THANH") || s.contains("HOÀN TẤT") || s.contains("HOAN TAT")) {
            return "Đã hoàn thành";
        }
        return "Chưa hoàn thành";
    }

    public boolean isCompleted() {
        return "Đã hoàn thành".equals(getProcessingStatus());
    }

    public void setProcessingStatus(String processingStatus) {
        if (processingStatus == null || processingStatus.trim().isEmpty()) {
            this.processingStatus = "Chưa hoàn thành";
            return;
        }
        String s = processingStatus.trim().toUpperCase();
        if (s.contains("CHƯA") || s.contains("CHUA") || s.contains("PENDING") || s.contains("UNCOMPLETED")) {
            this.processingStatus = "Chưa hoàn thành";
        } else if (s.contains("DONE") || s.contains("COMPLETED") || s.contains("ĐÃ") || s.contains("DA") || s.contains("HOÀN THÀNH") || s.contains("HOAN THANH") || s.contains("HOÀN TẤT") || s.contains("HOAN TAT")) {
            this.processingStatus = "Đã hoàn thành";
        } else {
            this.processingStatus = processingStatus.trim();
        }
    }

    public String getNotes() {
        return com.hotel.util.EncodingUtil.fixEncoding(notes);
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
