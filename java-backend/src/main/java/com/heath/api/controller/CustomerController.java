package com.heath.api.controller;

import com.heath.api.model.Customer;
import com.heath.api.service.CustomerService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 客戶資料 REST API 控制器
 */
@RestController
@RequestMapping("/api/customers")
@CrossOrigin(origins = "*") // 允許跨域請求
public class CustomerController {
    
    @Autowired
    private CustomerService customerService;
    
    /**
     * 取得所有客戶
     * GET /api/customers?userId=xxx
     */
    @GetMapping
    public ResponseEntity<?> getAllCustomers(@RequestParam String userId) {
        try {
            List<Customer> customers = customerService.getAllCustomers(userId);
            return ResponseEntity.ok(customers);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "取得客戶資料失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 根據 ID 取得客戶
     * GET /api/customers/{id}?userId=xxx
     */
    @GetMapping("/{id}")
    public ResponseEntity<?> getCustomerById(@PathVariable String id, @RequestParam String userId) {
        try {
            Customer customer = customerService.getCustomerById(id, userId);
            if (customer == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "找不到指定的客戶資料");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
            }
            return ResponseEntity.ok(customer);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "取得客戶資料失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 新增客戶
     * POST /api/customers?userId=xxx
     */
    @PostMapping
    public ResponseEntity<?> addCustomer(@RequestBody Customer customer, @RequestParam String userId) {
        try {
            Customer savedCustomer = customerService.addCustomer(customer, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedCustomer);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "新增客戶失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 更新客戶
     * PUT /api/customers/{id}?userId=xxx
     */
    @PutMapping("/{id}")
    public ResponseEntity<?> updateCustomer(@PathVariable String id, 
                                           @RequestBody Customer customer, 
                                           @RequestParam String userId) {
        try {
            Customer updatedCustomer = customerService.updateCustomer(id, customer, userId);
            return ResponseEntity.ok(updatedCustomer);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "更新客戶失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 刪除客戶
     * DELETE /api/customers/{id}?userId=xxx
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCustomer(@PathVariable String id, @RequestParam String userId) {
        try {
            customerService.deleteCustomer(id, userId);
            Map<String, Boolean> result = new HashMap<>();
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "刪除客戶失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}

