/**
 * 客戶模型（Entity / DTO）
 * 
 * Java 對比：
 * - 類似 Java 的 @Entity 類或 DTO 類
 * - 包含客戶的完整資訊：基本資料、地址、健康狀況等
 * 
 * 欄位說明：
 * - 基本資料：id, name, phone
 * - 地址資訊：city, district, village, neighborhood, streetType, streetName, lane, alley, number, floor, fullAddress
 * - 健康資訊：healthStatus, medications, supplements
 * - 其他：avatar, createdAt, userLogin
 */
class CustomerModel {
  // 基本資料欄位
  final String id;              // 客戶 ID（主鍵，類似 Java 的 @Id）
  final String name;            // 客戶姓名（必填）
  final String? phone;          // 電話（可空，類似 Java 的 @Nullable String）
  
  // 地址相關欄位（台灣地址結構）
  final String? city;           // 縣市
  final String? district;       // 區
  final String? village;        // 里
  final String? neighborhood;   // 鄰
  final String? streetType;     // 街道類型（如：路、街、巷）
  final String? streetName;     // 街道名稱
  final String? lane;           // 巷
  final String? alley;         // 弄
  final String? number;        // 號
  final String? floor;         // 樓層
  final String? fullAddress;   // 完整地址（組合後的地址字串）
  
  // 健康相關欄位
  final String? healthStatus;   // 健康狀況
  final String? medications;   // 用藥記錄
  final String? supplements;   // 保健品記錄
  
  // 其他欄位
  final String? avatar;        // 頭像 URL
  final DateTime? createdAt;   // 建立時間（類似 Java 的 LocalDateTime）
  final String userLogin;       // 用於資料串聯的登入帳號（必填）

  /**
   * 建構函數
   * 
   * Java 對比：
   * - 命名參數類似 Java 的 Builder Pattern
   * - required: 必填參數，類似 Java 的 @NotNull
   */
  CustomerModel({
    required this.id,
    required this.name,
    this.phone,
    this.city,
    this.district,
    this.village,
    this.neighborhood,
    this.streetType,
    this.streetName,
    this.lane,
    this.alley,
    this.number,
    this.floor,
    this.fullAddress,
    this.healthStatus,
    this.medications,
    this.supplements,
    this.avatar,
    this.createdAt,
    required this.userLogin,
  });

  /**
   * 工廠方法：從 JSON 建立 CustomerModel
   * 
   * Java 對比：
   * - 類似 Java 的 public static CustomerModel fromJson(Map<String, Object> json)
   * - 類似 Jackson 的 @JsonCreator 或 Gson 的 fromJson()
   * 
   * 注意：
   * - 資料庫欄位使用 snake_case（如 street_type），Dart 使用 camelCase（streetType）
   * - DateTime.parse(): 類似 Java 的 LocalDateTime.parse() 或 DateFormat.parse()
   */
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      // ?? 運算符：如果為 null 則使用空字串，類似 Java 的 Optional.orElse("")
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      district: json['district'] as String?,
      village: json['village'] as String?,
      neighborhood: json['neighborhood'] as String?,
      // 資料庫欄位名稱轉換：street_type -> streetType
      streetType: json['street_type'] as String?,
      streetName: json['street_name'] as String?,
      lane: json['lane'] as String?,
      alley: json['alley'] as String?,
      number: json['number'] as String?,
      floor: json['floor'] as String?,
      fullAddress: json['full_address'] as String?,
      healthStatus: json['health_status'] as String?,
      medications: json['medications'] as String?,
      supplements: json['supplements'] as String?,
      avatar: json['avatar'] as String?,
      // DateTime 解析：類似 Java 的 LocalDateTime.parse(json.getString("created_at"))
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      userLogin: json['user_login'] as String? ?? '',
    );
  }

  /**
   * 轉換為 JSON（序列化）
   * 
   * Java 對比：
   * - 類似 Java 的 toJson() 或 ObjectMapper.writeValueAsString()
   * - 類似 Java 的 Map<String, Object> toMap()
   * 
   * 注意：
   * - toIso8601String(): 將 DateTime 轉換為 ISO 8601 字串
   * - 類似 Java 的 DateTimeFormatter.ISO_LOCAL_DATE_TIME.format(dateTime)
   * - ?. 安全調用：如果 createdAt 為 null 則不調用方法
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'city': city,
      'district': district,
      'village': village,
      'neighborhood': neighborhood,
      // 轉換回資料庫欄位名稱：streetType -> street_type
      'street_type': streetType,
      'street_name': streetName,
      'lane': lane,
      'alley': alley,
      'number': number,
      'floor': floor,
      'full_address': fullAddress,
      'health_status': healthStatus,
      'medications': medications,
      'supplements': supplements,
      'avatar': avatar,
      // 日期轉換：類似 Java 的 dateTime.format(DateTimeFormatter.ISO_LOCAL_DATE_TIME)
      'created_at': createdAt?.toIso8601String(),
      'user_login': userLogin,
    };
  }
}
