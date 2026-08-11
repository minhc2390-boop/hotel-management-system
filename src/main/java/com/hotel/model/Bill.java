package com.hotel.model;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "Bills")
public class Bill {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Transient
    private int userId;

    @Column(name = "check_in_date", nullable = false)
    private Timestamp checkInDate;

    @Column(name = "check_out_date")
    private Timestamp checkOutDate;

    @Column(name = "total_amount")
    private double totalAmount;

    @Column(name = "status", nullable = false)
    private String status; // Unpaid, Paid, Cancelled

    @Column(name = "payment_method", length = 30)
    private String paymentMethod; // Cash, BankTransfer, Card

    @Column(name = "created_at")
    private Timestamp createdAt;

    // Joint object mapped by JPA
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "customer_id", nullable = true)
    private Customer customer;

    public Bill() {}

    public Bill(int id, int userId, Timestamp checkInDate, Timestamp checkOutDate, double totalAmount, String status, Timestamp createdAt) {
        this.id = id;
        setUserId(userId);
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.totalAmount = totalAmount;
        this.status = status;
        this.createdAt = createdAt;
    }

    public Bill(int userId, Timestamp checkInDate, Timestamp checkOutDate, double totalAmount, String status) {
        setUserId(userId);
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.totalAmount = totalAmount;
        this.status = status;
    }

    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = new Timestamp(System.currentTimeMillis());
        }
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getUserId() {
        if (user != null) {
            return user.getId();
        }
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
        if (this.user == null) {
            this.user = new User();
        }
        this.user.setId(userId);
    }

    public Timestamp getCheckInDate() {
        return checkInDate;
    }

    public void setCheckInDate(Timestamp checkInDate) {
        this.checkInDate = checkInDate;
    }

    public Timestamp getCheckOutDate() {
        return checkOutDate;
    }

    public void setCheckOutDate(Timestamp checkOutDate) {
        this.checkOutDate = checkOutDate;
    }

    public double getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(double totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
        if (user != null) {
            this.userId = user.getId();
        }
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    @Override
    public String toString() {
        return "Bill{" +
                "id=" + id +
                ", userId=" + getUserId() +
                ", checkInDate=" + checkInDate +
                ", checkOutDate=" + checkOutDate +
                ", totalAmount=" + totalAmount +
                ", status='" + status + '\'' +
                ", paymentMethod='" + paymentMethod + '\'' +
                '}';
    }
}
