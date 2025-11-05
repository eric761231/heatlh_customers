package com.heath.api.service;

import com.heath.api.model.Schedule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Service;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * 行程資料業務邏輯層
 */
@Service
public class ScheduleService {
    
    @Autowired
    private JdbcTemplate jdbcTemplate;
    
    /**
     * 取得所有行程（根據使用者 ID 過濾）
     */
    public List<Schedule> getAllSchedules(String userId) {
        String sql = "SELECT s.*, c.name as customer_name FROM schedules s " +
                     "LEFT JOIN customers c ON s.customer_id = c.id AND c.created_by = ? " +
                     "WHERE s.created_by = ? ORDER BY s.date ASC";
        
        List<Schedule> schedules = jdbcTemplate.query(sql, new ScheduleRowMapper(), userId, userId);
        
        // 如果有客戶 ID，取得客戶名稱
        Map<String, String> customerMap = getCustomerNames(userId);
        schedules.forEach(s -> {
            if (s.getCustomerId() != null) {
                s.setCustomerName(customerMap.getOrDefault(s.getCustomerId(), ""));
            }
        });
        
        return schedules;
    }
    
    /**
     * 新增行程
     */
    public Schedule addSchedule(Schedule schedule, String userId) {
        String id = String.valueOf(System.currentTimeMillis());
        String sql = "INSERT INTO schedules (id, title, date, start_time, end_time, type, customer_id, notes, created_by) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        jdbcTemplate.update(sql,
            id,
            schedule.getTitle() != null ? schedule.getTitle() : "",
            schedule.getDate() != null ? schedule.getDate() : LocalDate.now(),
            schedule.getStartTime(),
            schedule.getEndTime(),
            schedule.getType() != null ? schedule.getType() : "other",
            schedule.getCustomerId(),
            schedule.getNotes() != null ? schedule.getNotes() : "",
            userId
        );
        
        schedule.setId(id);
        schedule.setCreatedBy(userId);
        return schedule;
    }
    
    /**
     * 刪除行程
     */
    public void deleteSchedule(String id, String userId) {
        // 先檢查是否為自己的資料
        String checkSql = "SELECT COUNT(*) FROM schedules WHERE id = ? AND created_by = ?";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, id, userId);
        
        if (count == null || count == 0) {
            throw new RuntimeException("找不到指定的行程或您沒有權限刪除");
        }
        
        String sql = "DELETE FROM schedules WHERE id = ? AND created_by = ?";
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
     * RowMapper 用於將資料庫結果映射到 Schedule 物件
     */
    private static class ScheduleRowMapper implements RowMapper<Schedule> {
        @Override
        public Schedule mapRow(ResultSet rs, int rowNum) throws SQLException {
            Schedule schedule = new Schedule();
            schedule.setId(rs.getString("id"));
            schedule.setTitle(rs.getString("title"));
            if (rs.getDate("date") != null) {
                schedule.setDate(rs.getDate("date").toLocalDate());
            }
            if (rs.getTime("start_time") != null) {
                schedule.setStartTime(rs.getTime("start_time").toLocalTime());
            }
            if (rs.getTime("end_time") != null) {
                schedule.setEndTime(rs.getTime("end_time").toLocalTime());
            }
            schedule.setType(rs.getString("type"));
            schedule.setCustomerId(rs.getString("customer_id"));
            schedule.setCustomerName(rs.getString("customer_name"));
            schedule.setNotes(rs.getString("notes"));
            schedule.setCreatedBy(rs.getString("created_by"));
            return schedule;
        }
    }
}

