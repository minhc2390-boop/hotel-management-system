package com.hotel.model;

import javax.persistence.*;

@Entity
@Table(name = "RoomTypes")
public class RoomType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "name", nullable = false, unique = true)
    private String name;

    @Column(name = "price_per_day", nullable = false)
    private double pricePerDay;

    @Column(name = "capacity", nullable = false)
    private int capacity;

    @Column(name = "description")
    private String description;

    public RoomType() {}

    public RoomType(int id, String name, double pricePerDay, int capacity, String description) {
        this.id = id;
        this.name = name;
        this.pricePerDay = pricePerDay;
        this.capacity = capacity;
        this.description = description;
    }

    public RoomType(String name, double pricePerDay, int capacity, String description) {
        this.name = name;
        this.pricePerDay = pricePerDay;
        this.capacity = capacity;
        this.description = description;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return com.hotel.util.EncodingUtil.fixEncoding(name);
    }

    public void setName(String name) {
        this.name = name;
    }

    public double getPricePerDay() {
        return pricePerDay;
    }

    public void setPricePerDay(double pricePerDay) {
        this.pricePerDay = pricePerDay;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public String getDescription() {
        return com.hotel.util.EncodingUtil.fixEncoding(description);
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "RoomType{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", pricePerDay=" + pricePerDay +
                ", capacity=" + capacity +
                '}';
    }
}
