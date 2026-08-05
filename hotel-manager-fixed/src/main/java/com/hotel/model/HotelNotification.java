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

    @org.hibernate.annotations.Nationalized
    @Column(name = "title", nullable = false, length = 200, columnDefinition = "NVARCHAR(200)")
    private String title;

    @org.hibernate.annotations.Nationalized
    @Column(name = "content", nullable = false, columnDefinition = "NVARCHAR(MAX)")
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
        this.title = title;
        this.content = content;
        this.type = type;
        this.createdAt = createdAt;
        this.createdBy = createdBy;
        this.isActive = isActive;
    }

    public HotelNotification(String title, String content, String type, Integer createdBy, Boolean isActive) {
        this.title = title;
        this.content = content;
        this.type = (type != null && !type.trim().isEmpty()) ? type : "INFO";
        this.createdAt = LocalDateTime.now();
        this.createdBy = createdBy;
        this.isActive = (isActive != null) ? isActive : true;
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
        return fixEncoding(title);
    }

    public void setTitle(String title) {
        this.title = fixEncoding(title);
    }

    public String getContent() {
        if (content == null) return "";
        return fixEncoding(content);
    }

    public void setContent(String content) {
        this.content = fixEncoding(content);
    }

    private String fixEncoding(String str) {
        if (str == null || str.trim().isEmpty()) return "";
        String s = str.trim();

        if (s.contains("Ã") || s.contains("Â") || s.contains("áº") || s.contains("á»") || s.contains("Æ°") || s.contains("Ä‘") || s.contains("Å") || s.contains("â")) {
            try {
                byte[] b1 = s.getBytes("ISO-8859-1");
                String d1 = new String(b1, "UTF-8");
                if (!d1.contains("ï¿½") && !d1.contains("\uFFFD") && containsVietnamese(d1)) {
                    return d1;
                }
            } catch (Exception e) {}

            try {
                byte[] b2 = s.getBytes("Windows-1252");
                String d2 = new String(b2, "UTF-8");
                if (!d2.contains("ï¿½") && !d2.contains("\uFFFD") && containsVietnamese(d2)) {
                    return d2;
                }
            } catch (Exception e) {}
        }
        return s;
    }

    private boolean containsVietnamese(String str) {
        if (str == null) return false;
        return str.matches(".*[àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđĐ].*");
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
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
