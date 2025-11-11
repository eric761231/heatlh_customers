/**
 * 使用者模型（Entity / DTO）
 * 
 * Java 對比：
 * - 類似 Java 的 Entity 類（JPA @Entity）或 DTO（Data Transfer Object）
 * - final 欄位類似 Java 的 private final，表示不可變
 * - 類似 Java 的 POJO (Plain Old Java Object)
 * 
 * 設計模式：
 * - Builder Pattern：命名參數建構函數類似 Builder
 * - Factory Pattern：fromJson 是工廠方法
 */
class UserModel {
  // final: 類似 Java 的 private final，表示不可變欄位
  final String id;           // 使用者 ID（類似 Java 的 @Id）
  final String email;        // Email 地址
  final String? name;        // 姓名（可空，類似 Java 的 @Nullable String）
  final String? picture;     // 頭像 URL（可空）
  final String userLogin;    // 用於資料串聯的登入帳號

  /**
   * 建構函數（命名參數）
   * 
   * Java 對比：
   * - required: 必填參數，類似 Java 的 @NotNull
   * - 命名參數類似 Java 的 Builder Pattern：
   *   new UserModel.Builder()
   *     .id("123")
   *     .email("test@example.com")
   *     .build();
   */
  UserModel({
    required this.id,        // required: 必填，類似 Java 的 @NotNull
    required this.email,
    this.name,              // 可選參數，類似 Java 的 @Nullable
    this.picture,
    required this.userLogin,
  });

  /**
   * 工廠方法：從 JSON 建立 UserModel
   * 
   * Java 對比：
   * - factory: 類似 Java 的靜態工廠方法 public static UserModel fromJson(Map<String, Object> json)
   * - 類似 Jackson 的 @JsonCreator 或 Gson 的 fromJson()
   * 
   * 使用範例：
   * UserModel user = UserModel.fromJson(jsonMap);
   */
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // json['id']: 類似 Java 的 json.get("id")
      // as String: 類型轉換，類似 Java 的 (String) json.get("id")
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,  // String?: 可空類型，類似 Java 的 @Nullable
      picture: json['picture'] as String?,
      // ?? 運算符：空值合併，類似 Java 的 Optional.orElse()
      // 如果 user_login 為 null，則使用 email
      userLogin: json['user_login'] as String? ?? json['email'] as String,
    );
  }

  /**
   * 轉換為 JSON（序列化）
   * 
   * Java 對比：
   * - 類似 Java 的 toJson() 或 Jackson 的 ObjectMapper.writeValueAsString()
   * - 類似 Java 的 Map<String, Object> toMap()
   * 
   * 使用範例：
   * Map<String, dynamic> json = user.toJson();
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'picture': picture,
      'user_login': userLogin,
    };
  }
}
