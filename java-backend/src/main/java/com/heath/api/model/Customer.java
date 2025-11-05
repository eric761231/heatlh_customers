package com.heath.api.model;

import java.time.LocalDateTime;

/**
 * 客戶資料模型
 */
public class Customer {
    private String id;
    private String name;
    private String phone;
    private String city;
    private String district;
    private String village;
    private String neighborhood;
    private String streetType;
    private String streetName;
    private String lane;
    private String alley;
    private String number;
    private String floor;
    private String fullAddress;
    private String healthStatus;
    private String medications;
    private String supplements;
    private String avatar;
    private LocalDateTime createdAt;
    private String createdBy;
    
    // 建構子
    public Customer() {}
    
    // Getter 和 Setter 方法
    public String getId() {
        return id;
    }
    
    public void setId(String id) {
        this.id = id;
    }
    
    public String getName() {
        return name;
    }
    
    public void setName(String name) {
        this.name = name;
    }
    
    public String getPhone() {
        return phone;
    }
    
    public void setPhone(String phone) {
        this.phone = phone;
    }
    
    public String getCity() {
        return city;
    }
    
    public void setCity(String city) {
        this.city = city;
    }
    
    public String getDistrict() {
        return district;
    }
    
    public void setDistrict(String district) {
        this.district = district;
    }
    
    public String getVillage() {
        return village;
    }
    
    public void setVillage(String village) {
        this.village = village;
    }
    
    public String getNeighborhood() {
        return neighborhood;
    }
    
    public void setNeighborhood(String neighborhood) {
        this.neighborhood = neighborhood;
    }
    
    public String getStreetType() {
        return streetType;
    }
    
    public void setStreetType(String streetType) {
        this.streetType = streetType;
    }
    
    public String getStreetName() {
        return streetName;
    }
    
    public void setStreetName(String streetName) {
        this.streetName = streetName;
    }
    
    public String getLane() {
        return lane;
    }
    
    public void setLane(String lane) {
        this.lane = lane;
    }
    
    public String getAlley() {
        return alley;
    }
    
    public void setAlley(String alley) {
        this.alley = alley;
    }
    
    public String getNumber() {
        return number;
    }
    
    public void setNumber(String number) {
        this.number = number;
    }
    
    public String getFloor() {
        return floor;
    }
    
    public void setFloor(String floor) {
        this.floor = floor;
    }
    
    public String getFullAddress() {
        return fullAddress;
    }
    
    public void setFullAddress(String fullAddress) {
        this.fullAddress = fullAddress;
    }
    
    public String getHealthStatus() {
        return healthStatus;
    }
    
    public void setHealthStatus(String healthStatus) {
        this.healthStatus = healthStatus;
    }
    
    public String getMedications() {
        return medications;
    }
    
    public void setMedications(String medications) {
        this.medications = medications;
    }
    
    public String getSupplements() {
        return supplements;
    }
    
    public void setSupplements(String supplements) {
        this.supplements = supplements;
    }
    
    public String getAvatar() {
        return avatar;
    }
    
    public void setAvatar(String avatar) {
        this.avatar = avatar;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
}

