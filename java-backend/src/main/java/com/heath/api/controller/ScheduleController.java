package com.heath.api.controller;

import com.heath.api.model.Schedule;
import com.heath.api.service.ScheduleService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 行程資料 REST API 控制器
 */
@RestController
@RequestMapping("/api/schedules")
@CrossOrigin(origins = "*") // 允許跨域請求
public class ScheduleController {
    
    @Autowired
    private ScheduleService scheduleService;
    
    /**
     * 取得所有行程
     * GET /api/schedules?userId=xxx
     */
    @GetMapping
    public ResponseEntity<?> getAllSchedules(@RequestParam String userId) {
        try {
            List<Schedule> schedules = scheduleService.getAllSchedules(userId);
            return ResponseEntity.ok(schedules);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "取得行程資料失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 新增行程
     * POST /api/schedules?userId=xxx
     */
    @PostMapping
    public ResponseEntity<?> addSchedule(@RequestBody Schedule schedule, @RequestParam String userId) {
        try {
            Schedule savedSchedule = scheduleService.addSchedule(schedule, userId);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedSchedule);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "新增行程失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
    
    /**
     * 刪除行程
     * DELETE /api/schedules/{id}?userId=xxx
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteSchedule(@PathVariable String id, @RequestParam String userId) {
        try {
            scheduleService.deleteSchedule(id, userId);
            Map<String, Boolean> result = new HashMap<>();
            result.put("success", true);
            return ResponseEntity.ok(result);
        } catch (RuntimeException e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", e.getMessage());
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "刪除行程失敗: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }
}

