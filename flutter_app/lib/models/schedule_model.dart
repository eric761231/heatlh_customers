/**
 * 行程模型（Entity / DTO）
 * 
 * Java 對比：
 * - 類似 Java 的 @Entity 類或 DTO 類
 * - 表示一個行程事項，可以關聯到客戶
 * 
 * 欄位說明：
 * - 基本資訊：id, title, date, startTime, endTime, type
 * - 關聯資訊：customerId, customerName（客戶名稱是關聯查詢後填充的）
 * - 其他：notes, userLogin
 */
class ScheduleModel {
  final String id;              // 行程 ID（主鍵）
  final String title;           // 行程標題（必填）
  final DateTime date;          // 行程日期（必填，類似 Java 的 LocalDate）
  final String? startTime;     // 開始時間（可空，格式如 "09:00"）
  final String? endTime;        // 結束時間（可空，格式如 "10:00"）
  final String type;            // 行程類型（預設 'other'，如：meeting, call, visit）
  final String? customerId;     // 關聯的客戶 ID（外鍵，可空）
  final String? customerName;   // 客戶名稱（關聯查詢後填充，不在資料庫中）
  final String? notes;          // 備註
  final String userLogin;       // 用於資料串聯的登入帳號（必填）

  /**
   * 建構函數
   * 
   * Java 對比：
   * - type = 'other': 預設參數值，類似 Java 的 public ScheduleModel(..., String type = "other")
   * - 類似 Java 的 Builder Pattern 或建構函數重載
   */
  ScheduleModel({
    required this.id,
    required this.title,
    required this.date,
    this.startTime,
    this.endTime,
    this.type = 'other',        // 預設值，類似 Java 的預設參數
    this.customerId,
    this.customerName,
    this.notes,
    required this.userLogin,
  });

  /**
   * 工廠方法：從 JSON 建立 ScheduleModel
   * 
   * Java 對比：
   * - 類似 Java 的 public static ScheduleModel fromJson(Map<String, Object> json)
   * - DateTime.parse(): 類似 Java 的 LocalDate.parse() 或 DateFormat.parse()
   */
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      // DateTime.parse(): 解析日期字串，類似 Java 的 LocalDate.parse("2024-01-01")
      date: DateTime.parse(json['date'] as String),
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      type: json['type'] as String? ?? 'other',
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?, // 關聯查詢後填充
      notes: json['notes'] as String?,
      userLogin: json['user_login'] as String? ?? '',
    );
  }

  /**
   * 轉換為 JSON（序列化）
   * 
   * Java 對比：
   * - 類似 Java 的 toJson() 或 ObjectMapper.writeValueAsString()
   * 
   * 注意：
   * - toIso8601String().split('T')[0]: 只取日期部分（YYYY-MM-DD）
   * - 類似 Java 的 date.format(DateTimeFormatter.ISO_LOCAL_DATE)
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // 只取日期部分，不包含時間
      // 類似 Java: date.format(DateTimeFormatter.ISO_LOCAL_DATE)
      'date': date.toIso8601String().split('T')[0],
      'start_time': startTime,
      'end_time': endTime,
      'type': type,
      'customer_id': customerId,
      // 注意：customerName 不儲存到資料庫，只是顯示用
      'notes': notes,
      'user_login': userLogin,
    };
  }
}
