package com.heath.api.service;

import com.heath.api.model.Customer;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 客戶資料業務邏輯層
 */
@Service
public class CustomerService {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 取得所有客戶（根據使用者 ID 過濾）
     */
    public List<Customer> getAllCustomers(String userId) {
        String sql = "SELECT * FROM customers WHERE created_by = ? ORDER BY created_at DESC";
        return jdbcTemplate.query(sql, new CustomerRowMapper(), userId);
    }
    
    /**
     * 根據 ID 取得客戶
     */
    public Customer getCustomerById(String id, String userId) {
        String sql = "SELECT * FROM customers WHERE id = ? AND created_by = ?";
        List<Customer> customers = jdbcTemplate.query(sql, new CustomerRowMapper(), id, userId);
        return customers.isEmpty() ? null : customers.get(0);
    }
    
    /**
     * 新增客戶
     */
    public Customer addCustomer(Customer customer, String userId) {
        String id = String.valueOf(System.currentTimeMillis());
        String sql = "INSERT INTO customers (id, name, phone, city, district, village, neighborhood, " +
                     "street_type, street_name, lane, alley, number, floor, full_address, " +
                     "health_status, medications, supplements, avatar, created_by, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        jdbcTemplate.update(sql,
            id,
            customer.getName() != null ? customer.getName() : "",
            customer.getPhone() != null ? customer.getPhone() : "",
            customer.getCity() != null ? customer.getCity() : "",
            customer.getDistrict() != null ? customer.getDistrict() : "",
            customer.getVillage() != null ? customer.getVillage() : "",
            customer.getNeighborhood() != null ? customer.getNeighborhood() : "",
            customer.getStreetType() != null ? customer.getStreetType() : "",
            customer.getStreetName() != null ? customer.getStreetName() : "",
            customer.getLane() != null ? customer.getLane() : "",
            customer.getAlley() != null ? customer.getAlley() : "",
            customer.getNumber() != null ? customer.getNumber() : "",
            customer.getFloor() != null ? customer.getFloor() : "",
            customer.getFullAddress() != null ? customer.getFullAddress() : "",
            customer.getHealthStatus() != null ? customer.getHealthStatus() : "",
            customer.getMedications() != null ? customer.getMedications() : "",
            customer.getSupplements() != null ? customer.getSupplements() : "",
            customer.getAvatar() != null ? customer.getAvatar() : "",
            userId,
            LocalDateTime.now()
        );
        
        customer.setId(id);
        customer.setCreatedBy(userId);
        return customer;
    }
    
    /**
     * 更新客戶
     */
    public Customer updateCustomer(String id, Customer customer, String userId) {
        // 先檢查是否為自己的資料
        Customer existing = getCustomerById(id, userId);
        if (existing == null) {
            throw new RuntimeException("找不到指定的客戶資料或您沒有權限修改");
        }
        
        String sql = "UPDATE customers SET name = ?, phone = ?, city = ?, district = ?, " +
                     "village = ?, neighborhood = ?, street_type = ?, street_name = ?, " +
                     "lane = ?, alley = ?, number = ?, floor = ?, full_address = ?, " +
                     "health_status = ?, medications = ?, supplements = ?, avatar = ? " +
                     "WHERE id = ? AND created_by = ?";
        
        jdbcTemplate.update(sql,
            customer.getName() != null ? customer.getName() : "",
            customer.getPhone() != null ? customer.getPhone() : "",
            customer.getCity() != null ? customer.getCity() : "",
            customer.getDistrict() != null ? customer.getDistrict() : "",
            customer.getVillage() != null ? customer.getVillage() : "",
            customer.getNeighborhood() != null ? customer.getNeighborhood() : "",
            customer.getStreetType() != null ? customer.getStreetType() : "",
            customer.getStreetName() != null ? customer.getStreetName() : "",
            customer.getLane() != null ? customer.getLane() : "",
            customer.getAlley() != null ? customer.getAlley() : "",
            customer.getNumber() != null ? customer.getNumber() : "",
            customer.getFloor() != null ? customer.getFloor() : "",
            customer.getFullAddress() != null ? customer.getFullAddress() : "",
            customer.getHealthStatus() != null ? customer.getHealthStatus() : "",
            customer.getMedications() != null ? customer.getMedications() : "",
            customer.getSupplements() != null ? customer.getSupplements() : "",
            customer.getAvatar() != null ? customer.getAvatar() : "",
            id,
            userId
        );
        
        customer.setId(id);
        return customer;
    }
    
    /**
     * 刪除客戶
     */
    public void deleteCustomer(String id, String userId) {
        // 先檢查是否為自己的資料
        Customer existing = getCustomerById(id, userId);
        if (existing == null) {
            throw new RuntimeException("找不到指定的客戶資料或您沒有權限刪除");
        }
        
        String sql = "DELETE FROM customers WHERE id = ? AND created_by = ?";
        jdbcTemplate.update(sql, id, userId);
    }
    
    /**
     * RowMapper 用於將資料庫結果映射到 Customer 物件
     */
    private static class CustomerRowMapper implements RowMapper<Customer> {
        @Override
        public Customer mapRow(ResultSet rs, int rowNum) throws SQLException {
            Customer customer = new Customer();
            customer.setId(rs.getString("id"));
            customer.setName(rs.getString("name"));
            customer.setPhone(rs.getString("phone"));
            customer.setCity(rs.getString("city"));
            customer.setDistrict(rs.getString("district"));
            customer.setVillage(rs.getString("village"));
            customer.setNeighborhood(rs.getString("neighborhood"));
            customer.setStreetType(rs.getString("street_type"));
            customer.setStreetName(rs.getString("street_name"));
            customer.setLane(rs.getString("lane"));
            customer.setAlley(rs.getString("alley"));
            customer.setNumber(rs.getString("number"));
            customer.setFloor(rs.getString("floor"));
            customer.setFullAddress(rs.getString("full_address"));
            customer.setHealthStatus(rs.getString("health_status"));
            customer.setMedications(rs.getString("medications"));
            customer.setSupplements(rs.getString("supplements"));
            customer.setAvatar(rs.getString("avatar"));
            if (rs.getTimestamp("created_at") != null) {
                customer.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
            }
            customer.setCreatedBy(rs.getString("created_by"));
            return customer;
        }
    }
}

