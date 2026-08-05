package com.hotel.model;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.Table;
import java.time.LocalDate;

@Entity
@Table(name = "BuffetMenuItems")
public class BuffetMenuItem {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private int id;

    @Column(name = "menu_date", nullable = false)
    private LocalDate menuDate;

    @Column(name = "meal_period", nullable = false, length = 20)
    private String mealPeriod;

    @Column(name = "category", nullable = false, length = 80, columnDefinition = "NVARCHAR(80)")
    private String category;

    @Column(name = "dish_name", nullable = false, length = 160, columnDefinition = "NVARCHAR(160)")
    private String dishName;

    @Column(name = "description", length = 1000, columnDefinition = "NVARCHAR(1000)")
    private String description;

    @Column(name = "image_url", length = 500, columnDefinition = "NVARCHAR(500)")
    private String imageUrl;

    @Column(name = "status", nullable = false, length = 20)
    private String status;

    @Column(name = "sort_order", nullable = false)
    private int sortOrder;

    public BuffetMenuItem() {
    }

    public BuffetMenuItem(LocalDate menuDate, String mealPeriod, String category,
                          String dishName, String description, String imageUrl,
                          String status, int sortOrder) {
        this.menuDate = menuDate;
        this.mealPeriod = mealPeriod;
        this.category = category;
        this.dishName = dishName;
        this.description = description;
        this.imageUrl = imageUrl;
        this.status = status;
        this.sortOrder = sortOrder;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public LocalDate getMenuDate() {
        return menuDate;
    }

    public void setMenuDate(LocalDate menuDate) {
        this.menuDate = menuDate;
    }

    public String getMealPeriod() {
        return mealPeriod;
    }

    public void setMealPeriod(String mealPeriod) {
        this.mealPeriod = mealPeriod;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDishName() {
        return dishName;
    }

    public void setDishName(String dishName) {
        this.dishName = dishName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getSortOrder() {
        return sortOrder;
    }

    public void setSortOrder(int sortOrder) {
        this.sortOrder = sortOrder;
    }
}
