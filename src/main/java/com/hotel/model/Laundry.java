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

    @org.hibernate.annotations.Nationalized
    @Column(name = "customer_name", nullable = false, length = 150, columnDefinition = "NVARCHAR(150)")
    private String customerName;

    @Column(name = "room_number", nullable = false, length = 20)
    private String roomNumber;

    @org.hibernate.annotations.Nationalized
    @Column(name = "service_type", length = 100, columnDefinition = "NVARCHAR(100)")
    private String serviceType;

    @Column(name = "quantity")
    private int quantity = 1;

    @Column(name = "total_price")
    private double totalPrice = 0.0;

    @org.hibernate.annotations.Nationalized
    @Column(name = "processing_status", nullable = false, length = 100, columnDefinition = "NVARCHAR(100)")
    private String processingStatus = "Pending";

    @Column(name = "booking_id")
    private Integer bookingId;

    @Column(name = "bill_id")
    private Integer billId;

    @Column(name = "bill_detail_id")
    private Integer billDetailId;

    @org.hibernate.annotations.Nationalized
    @Column(name = "notes", length = 500, columnDefinition = "NVARCHAR(500)")
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
        setProcessingStatus(processingStatus);
        this.notes = notes;
        this.createdDate = createdDate;
    }

    public Laundry(String customerName, String roomNumber, String serviceType, int quantity, double totalPrice, String processingStatus, String notes) {
        this.customerName = customerName;
        this.roomNumber = roomNumber;
        this.serviceType = serviceType;
        this.quantity = quantity;
        this.totalPrice = totalPrice;
        setProcessingStatus(processingStatus);
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
        return fixEncoding(customerName);
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
        String str = fixEncoding(serviceType.trim());

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
        return isCompleted() ? "Đã hoàn thành" : "Chưa hoàn thành";
    }

    public boolean isCompleted() {
        if (processingStatus == null) return false;
        String status = fixEncoding(processingStatus.trim()).toUpperCase();
        return status.contains("DONE")
                || status.contains("COMPLETED")
                || status.contains("ĐÃ")
                || status.contains("HOÀN THÀNH")
                || status.contains("HOAN THANH")
                || status.contains("HOÀN TẤT")
                || status.contains("HOAN TAT");
    }

    public void setProcessingStatus(String processingStatus) {
        if (processingStatus == null || processingStatus.trim().isEmpty()) {
            this.processingStatus = "Pending";
            return;
        }
        String s = processingStatus.trim().toUpperCase();
        if (s.contains("CHƯA") || s.contains("CHUA") || s.contains("PENDING") || s.contains("UNCOMPLETED")) {
            this.processingStatus = "Pending";
        } else if (s.contains("DONE") || s.contains("COMPLETED") || s.contains("ĐÃ") || s.contains("DA") || s.contains("HOÀN THÀNH") || s.contains("HOAN THANH") || s.contains("HOÀN TẤT") || s.contains("HOAN TAT")) {
            this.processingStatus = "Completed";
        } else {
            this.processingStatus = "Pending";
        }
    }

    public String getStatusCode() {
        return isCompleted() ? "Completed" : "Pending";
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public Integer getBillId() {
        return billId;
    }

    public void setBillId(Integer billId) {
        this.billId = billId;
    }

    public Integer getBillDetailId() {
        return billDetailId;
    }

    public void setBillDetailId(Integer billDetailId) {
        this.billDetailId = billDetailId;
    }

    public String getNotes() {
        return fixEncoding(notes);
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    private String fixEncoding(String str) {
        if (str == null || str.trim().isEmpty()) return "";
        String s = str.trim();
        if (containsVietnamese(s) && !s.contains("Ã") && !s.contains("áº") && !s.contains("á»") && !s.contains("Æ°") && !s.contains("Ä‘")) {
            return s;
        }
        try {
            if (s.contains("Ã") || s.contains("áº") || s.contains("á»") || s.contains("Æ°") || s.contains("Ä‘")) {
                byte[] bytes = s.getBytes("ISO-8859-1");
                String decoded = new String(bytes, "UTF-8");
                if (!decoded.contains("ï¿½") && !decoded.contains("\uFFFD") && containsVietnamese(decoded)) {
                    return decoded;
                }
            }
        } catch (Exception e) {}
        return s;
    }

    private boolean containsVietnamese(String str) {
        if (str == null) return false;
        return str.matches(".*[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐ].*");
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
                ", bookingId=" + bookingId +
                ", billId=" + billId +
                ", billDetailId=" + billDetailId +
                ", notes='" + notes + '\'' +
                ", createdDate=" + createdDate +
                '}';
    }
}
