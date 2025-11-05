package com.heath.api.controller;

import com.heath.api.model.Order;
import com.heath.api.service.OrderService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 訂單資料 REST API 控制器
 */
@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*") // 允許跨域請求
public class OrderController {
    
    @Autowired
    private OrderService orderService;
    
    /**
     * 取得所有訂單
     * GET /api/orders?userId=xxx
     */
    @GetMapping
    public ResponseEntity<?> getAllOrders(@RequestParam String userId) {
        try {
            List<Order> orders = orderService.getAllOrders(userId);
            return ResponseEntity.ok(orders);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "取得訂單資料失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 新增訂單
     * POST /api/orders?userId=xxx
     */
    @PostMapping
    public ResponseEntity<?> addOrder(@RequestBody Order order, @RequestParam String userId) {
        try {
            Order savedOrder = orderService.addOrder(order, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedOrder);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "新增訂單失敗: " + e.getMessage");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 更新訂單
     * PUT /api/orders/{id}?userId=xxx
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable String id, 
                                        @RequestBody Order order, 
                                        @RequestParam String userId) {
        try {
            Order updatedOrder = orderService.updateOrder(id, order, userId);
            return ResponseEntity.ok(updatedOrder);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "更新訂單失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 刪除訂單
     * DELETE /api/orders/{id}?userId=xxx
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteOrder(@PathVariable String id, @RequestParam String userId) {
        try {
            orderService.deleteOrder(id, userId);
            Map<String, Boolean> result = new HashMap<>();
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "刪除訂單失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}

