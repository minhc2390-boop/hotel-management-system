package com.hotel.model;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "HotelNotification")
public class HotelNotification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private int notificationId;

    @Column(name = "title", nullable = false, length = 200)
    private String title;

    @Column(name = "content", nullable = false)
    private String content;

    @Column(name = "type", nullable = false, length = 30)
    private String type = "INFO"; // INFO, WARNING, SUCCESS, ERROR

    @Column(name = "created_at")
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(name = "created_by")
    private Integer createdBy;

    @Column(name = "is_active")
    private Boolean isActive = true;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "created_by", insertable = false, updatable = false)
    private User creator;

    public HotelNotification() {}

    public HotelNotification(int notificationId, String title, String content, String type, LocalDateTime createdAt, Integer createdBy, Boolean isActive) {
        this.notificationId = notificationId;
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = createdAt != null ? createdAt : LocalDateTime.now();
        this.createdBy = createdBy;
        this.isActive = isActive != null ? isActive : true;
    }

    public HotelNotification(int notificationId, String title, String content, String type, Integer createdBy, Boolean isActive) {
        this.notificationId = notificationId;
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = createdBy;
        this.isActive = isActive != null ? isActive : true;
    }

    public HotelNotification(int notificationId, String title, String content, String type, Boolean isActive) {
        this.notificationId = notificationId;
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = null;
        this.isActive = isActive != null ? isActive : true;
    }

    public HotelNotification(String title, String content, String type, Integer createdBy, Boolean isActive) {
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = createdBy;
        this.isActive = (isActive != null) ? isActive : true;
    }

    public HotelNotification(String title, String content, String type, Boolean isActive) {
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = null;
        this.isActive = (isActive != null) ? isActive : true;
    }

    public HotelNotification(String title, String content, String type) {
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = null;
        this.isActive = true;
    }

    // Getters and Setters
    public int getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(int notificationId) {
        this.notificationId = notificationId;
    }

    public String getTitle() {
        if (title == null || title.trim().isEmpty()) return "Thông báo";
        return com.hotel.util.EncodingUtil.fixEncoding(title);
    }

    public void setTitle(String title) {
        this.title = com.hotel.util.EncodingUtil.fixEncoding(title);
    }

    public String getContent() {
        if (content == null) return "";
        return com.hotel.util.EncodingUtil.fixEncoding(content);
    }

    public void setContent(String content) {
        this.content = com.hotel.util.EncodingUtil.fixEncoding(content);
    }

    public String getType() {
        return (type != null && !type.trim().isEmpty()) ? type : "INFO";
    }

    public void setType(String type) {
        this.type = type;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt != null ? createdAt : LocalDateTime.now();
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getFormattedCreatedAt() {
        if (createdAt == null) return "";
        try {
            return createdAt.format(java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        } catch (Exception e) {
            return createdAt.toString();
        }
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Boolean getIsActive() {
        return isActive != null ? isActive : true;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public User getCreator() {
        return creator;
    }

    public void setCreator(User creator) {
        this.creator = creator;
    }

    public String getCreatorName() {
        try {
            if (creator != null && creator.getFullName() != null && !creator.getFullName().trim().isEmpty()) {
                return com.hotel.util.EncodingUtil.fixEncoding(creator.getFullName());
            }
        } catch (Exception ignored) {}
        return "Quản trị viên";
    }

    @Override
    public String toString() {
        return "HotelNotification{" +
                "notificationId=" + notificationId +
                ", title='" + title + '\'' +
                ", type='" + type + '\'' +
                ", createdAt=" + createdAt +
                ", createdBy=" + createdBy +
                ", isActive=" + isActive +
                '}';
    }
}
