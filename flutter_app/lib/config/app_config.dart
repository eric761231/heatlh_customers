/**
 * 應用程式配置類（常量類）
 * 
 * Java 對比：
 * - 類似 Java 的 Constants 類或 Configuration 類
 * - static const: 編譯時常量，類似 Java 的 public static final
 * - 類似 Spring 的 @Configuration 或 @Value 註解
 * 
 * 設計模式：
 * - 單例模式：所有欄位都是靜態的
 * - 常量類模式：提供應用程式配置常量
 */
class AppConfig {
  /**
   * Supabase URL
   * 
   * Java 對比：
   * - static const: 類似 Java 的 public static final String
   * - const: 編譯時常量，類似 Java 的 final + 編譯時確定值
   */
  static const String supabaseUrl = 'https://lvrcnmvnqbueghjyvxji.supabase.co';
  
  /**
   * Supabase 匿名 Key（公開的 API Key）
   * 
   * Java 對比：
   * - 類似 Java 的 public static final String API_KEY = "...";
   * - 注意：這是公開的 Key，可以安全地放在客戶端
   */
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imx2cmNubXZucWJ1ZWdoanl2eGppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIyNTgzOTUsImV4cCI6MjA3NzgzNDM5NX0.l6DMlnQx3YXqTe85yQqcDm3i9cIr7hAFdi3N-6OnAn0';
  
  /**
   * Google OAuth Client ID（如果需要 Google 登入）
   * 
   * Java 對比：
   * - 類似 Java 的 public static final String GOOGLE_CLIENT_ID = "...";
   */
  static const String googleClientId = '487197553483-ob3hv43l2kkvunkc0nqc9bd3kj6f8v8g.apps.googleusercontent.com';
}
