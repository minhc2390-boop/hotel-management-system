package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "CUSTOMERS")
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "customer_id")
    private int customerId;

    @Column(name = "customer_name", nullable = false, columnDefinition = "NVARCHAR(100)")
    private String customerName;

    @Column(name = "customer_cccd", unique = true)
    private String customerCccd;

    @Column(name = "customer_phone")
    private String customerPhone;

    @Column(name = "customer_email")
    private String customerEmail;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "user_id")
    private User user;

    public Customer() {}

    public Customer(String customerName, String customerCccd, String customerPhone, String customerEmail) {
        this.customerName = customerName;
        this.customerCccd = customerCccd;
        this.customerPhone = customerPhone;
        this.customerEmail = customerEmail;
    }

    public Customer(String customerName, String customerCccd, String customerPhone, String customerEmail, User user) {
        this.customerName = customerName;
        this.customerCccd = customerCccd;
        this.customerPhone = customerPhone;
        this.customerEmail = customerEmail;
        this.user = user;
    }

    public Customer(int customerId, String customerName, String customerCccd, String customerPhone, String customerEmail) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerCccd = customerCccd;
        this.customerPhone = customerPhone;
        this.customerEmail = customerEmail;
    }

    public Customer(int customerId, String customerName, String customerCccd, String customerPhone, String customerEmail, User user) {
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerCccd = customerCccd;
        this.customerPhone = customerPhone;
        this.customerEmail = customerEmail;
        this.user = user;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return com.hotel.util.EncodingUtil.fixEncoding(customerName);
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerCccd() {
        return customerCccd;
    }

    public void setCustomerCccd(String customerCccd) {
        this.customerCccd = customerCccd;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getCustomerEmail() {
        return customerEmail;
    }

    public void setCustomerEmail(String customerEmail) {
        this.customerEmail = customerEmail;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }
}
