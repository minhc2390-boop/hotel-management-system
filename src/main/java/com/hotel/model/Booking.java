package com.hotel.model;

import javax.persistence.*;
import java.sql.Timestamp;

@Entity
@Table(name = "BOOKINGS")
public class Booking {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "booking_id")
    private int bookingId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "customer_id", nullable = false)
    private Customer customer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "room_id", nullable = false)
    private Room room;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by", nullable = false)
    private User createdBy;

    @Column(name = "check_in_date", nullable = false)
    private Timestamp checkInDate;

    @Column(name = "check_out_date", nullable = false)
    private Timestamp checkOutDate;

    @Column(name = "status", nullable = false)
    private String status; // Pending, CheckedIn, CheckedOut, Cancelled

    @Column(name = "room_price", nullable = false)
    private double roomPrice;

    @Column(name = "note")
    private String note;

    public Booking() {}

    public Booking(Customer customer, Room room, User createdBy, Timestamp checkInDate, Timestamp checkOutDate, String status, double roomPrice, String note) {
        this.customer = customer;
        this.room = room;
        this.createdBy = createdBy;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.status = status;
        this.roomPrice = roomPrice;
        this.note = note;
    }

    public Booking(Customer customer, Room room, User createdBy, Timestamp checkInDate, Timestamp checkOutDate, String status) {
        this.customer = customer;
        this.room = room;
        this.createdBy = createdBy;
        this.checkInDate = checkInDate;
        this.checkOutDate = checkOutDate;
        this.status = status;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
    }

    public User getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(User createdBy) {
        this.createdBy = createdBy;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getRoomPrice() {
        return roomPrice;
    }

    public void setRoomPrice(double roomPrice) {
        this.roomPrice = roomPrice;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }
}
