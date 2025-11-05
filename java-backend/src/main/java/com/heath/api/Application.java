package com.heath.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

/**
 * Spring Boot 主程式
 * 這是應用程式的入口點
 */
@SpringBootApplication
public class Application extends SpringBootServletInitializer {
    
    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
        System.out.println("=========================================");
        System.out.println("葡眾愛客戶管理系統 - 後端 API 已啟動");
        System.out.println("API 端點: http://localhost:8080/api");
        System.out.println("=========================================");
    }
}

