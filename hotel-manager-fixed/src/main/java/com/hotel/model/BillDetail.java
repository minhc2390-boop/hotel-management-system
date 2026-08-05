package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "BillDetails")
public class BillDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "bill_id", nullable = false)
    private int billId;

    @Transient
    private Integer roomId;      // nullable transient

    @Transient
    private Integer serviceId;   // nullable transient

    @Column(name = "quantity", nullable = false)
    private int quantity;

    @Column(name = "price", nullable = false)
    private double price;        // price at transaction time

    // Joint objects mapped by JPA
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "room_id")
    private Room room;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "service_id")
    private Service service;

    public BillDetail() {}

    public BillDetail(int id, int billId, Integer roomId, Integer serviceId, int quantity, double price) {
        this.id = id;
        this.billId = billId;
        setRoomId(roomId);
        setServiceId(serviceId);
        this.quantity = quantity;
        this.price = price;
    }

    public BillDetail(int billId, Integer roomId, Integer serviceId, int quantity, double price) {
        this.billId = billId;
        setRoomId(roomId);
        setServiceId(serviceId);
        this.quantity = quantity;
        this.price = price;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getBillId() {
        return billId;
    }

    public void setBillId(int billId) {
        this.billId = billId;
    }

    public Integer getRoomId() {
        if (room != null) {
            return room.getId();
        }
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
        if (roomId == null) {
            this.room = null;
        } else {
            if (this.room == null) {
                this.room = new Room();
            }
            this.room.setId(roomId);
        }
    }

    public Integer getServiceId() {
        if (service != null) {
            return service.getId();
        }
        return serviceId;
    }

    public void setServiceId(Integer serviceId) {
        this.serviceId = serviceId;
        if (serviceId == null) {
            this.service = null;
        } else {
            if (this.service == null) {
                this.service = new Service();
            }
            this.service.setId(serviceId);
        }
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getPrice() {
        return price;
    }

    public void setPrice(double price) {
        this.price = price;
    }

    public Room getRoom() {
        return room;
    }

    public void setRoom(Room room) {
        this.room = room;
        if (room != null) {
            this.roomId = room.getId();
        } else {
            this.roomId = null;
        }
    }

    public Service getService() {
        return service;
    }

    public void setService(Service service) {
        this.service = service;
        if (service != null) {
            this.serviceId = service.getId();
        } else {
            this.serviceId = null;
        }
    }

    @Override
    public String toString() {
        return "BillDetail{" +
                "id=" + id +
                ", billId=" + billId +
                ", roomId=" + getRoomId() +
                ", serviceId=" + getServiceId() +
                ", quantity=" + quantity +
                ", price=" + price +
                '}';
    }
}
