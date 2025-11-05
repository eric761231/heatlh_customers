package com.heath.api.service;

import com.heath.api.model.Order;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 訂單資料業務邏輯層
 */
@Service
public class OrderService {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 取得所有訂單（根據使用者 ID 過濾）
     */
    public List<Order> getAllOrders(String userId) {
        String sql = "SELECT o.*, c.name as customer_name FROM orders o " +
                     "LEFT JOIN customers c ON o.customer_id = c.id AND c.created_by = ? " +
                     "WHERE o.created_by = ? ORDER BY o.date DESC";
        
        List<Order> orders = jdbcTemplate.query(sql, new OrderRowMapper(), userId, userId);
        
        // 如果有客戶 ID，取得客戶名稱
        Map<String, String> customerMap = getCustomerNames(userId);
        orders.forEach(o -> {
            if (o.getCustomerId() != null) {
                o.setCustomerName(customerMap.getOrDefault(o.getCustomerId(), ""));
            }
        });
        
        return orders;
    }
    
    /**
     * 新增訂單
     */
    public Order addOrder(Order order, String userId) {
        String id = String.valueOf(System.currentTimeMillis());
        String sql = "INSERT INTO orders (id, date, customer_id, product, quantity, amount, paid, notes, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        jdbcTemplate.update(sql,
            id,
            order.getDate() != null ? order.getDate() : LocalDate.now(),
            order.getCustomerId(),
            order.getProduct() != null ? order.getProduct() : "",
            order.getQuantity() != null ? order.getQuantity() : 1,
            order.getAmount() != null ? order.getAmount() : BigDecimal.ZERO,
            order.getPaid() != null ? order.getPaid() : false,
            order.getNotes() != null ? order.getNotes() : "",
            userId
        );
        
        order.setId(id);
        order.setCreatedBy(userId);
        return order;
    }
    
    /**
     * 更新訂單
     */
    public Order updateOrder(String id, Order order, String userId) {
        // 先檢查是否為自己的資料
        String checkSql = "SELECT COUNT(*) FROM orders WHERE id = ? AND created_by = ?";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, id, userId);
        
        if (count == null || count == 0) {
            throw new RuntimeException("找不到指定的訂單或您沒有權限修改");
        }
        
        String sql = "UPDATE orders SET date = ?, customer_id = ?, product = ?, quantity = ?, " +
                     "amount = ?, paid = ?, notes = ? WHERE id = ? AND created_by = ?";
        
        jdbcTemplate.update(sql,
            order.getDate() != null ? order.getDate() : LocalDate.now(),
            order.getCustomerId(),
            order.getProduct() != null ? order.getProduct() : "",
            order.getQuantity() != null ? order.getQuantity() : 1,
            order.getAmount() != null ? order.getAmount() : BigDecimal.ZERO,
            order.getPaid() != null ? order.getPaid() : false,
            order.getNotes() != null ? order.getNotes() : "",
            id,
            userId
        );
        
        order.setId(id);
        return order;
    }
    
    /**
     * 刪除訂單
     */
    public void deleteOrder(String id, String userId) {
        // 先檢查是否為自己的資料
        String checkSql = "SELECT COUNT(*) FROM orders WHERE id = ? AND created_by = ?";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, id, userId);
        
        if (count == null || count == 0) {
            throw new RuntimeException("找不到指定的訂單或您沒有權限刪除");
        }
        
        String sql = "DELETE FROM orders WHERE id = ? AND created_by = ?";
        jdbcTemplate.update(sql, id, userId);
    }
    
    /**
     * 取得客戶名稱映射
     */
    private Map<String, String> getCustomerNames(String userId) {
        String sql = "SELECT id, name FROM customers WHERE created_by = ?";
        return jdbcTemplate.query(sql, (rs, rowNum) -> {
            return new String[]{rs.getString("id"), rs.getString("name")};
        }, userId).stream()
        .collect(Collectors.toMap(arr -> arr[0], arr -> arr[1]));
    }
    
    /**
     * RowMapper 用於將資料庫結果映射到 Order 物件
     */
    private static class OrderRowMapper implements RowMapper<Order> {
        @Override
        public Order mapRow(ResultSet rs, int rowNum) throws SQLException {
            Order order = new Order();
            order.setId(rs.getString("id"));
            if (rs.getDate("date") != null) {
                order.setDate(rs.getDate("date").toLocalDate());
            }
            order.setCustomerId(rs.getString("customer_id"));
            order.setCustomerName(rs.getString("customer_name"));
            order.setProduct(rs.getString("product"));
            order.setQuantity(rs.getInt("quantity"));
            if (rs.getBigDecimal("amount") != null) {
                order.setAmount(rs.getBigDecimal("amount"));
            }
            order.setPaid(rs.getBoolean("paid"));
            order.setNotes(rs.getString("notes"));
            order.setCreatedBy(rs.getString("created_by"));
            return order;
        }
    }
}

