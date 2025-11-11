/**
 * 訂單模型（Entity / DTO）
 * 
 * Java 對比：
 * - 類似 Java 的 @Entity 類或 DTO 類
 * - 表示一個訂單記錄，可以關聯到客戶
 * 
 * 欄位說明：
 * - 基本資訊：id, date, product, quantity, amount, paid
 * - 關聯資訊：customerId, customerName（客戶名稱是關聯查詢後填充的）
 * - 其他：notes, userLogin
 */
class OrderModel {
  final String id;              // 訂單 ID（主鍵）
  final DateTime date;          // 訂單日期（必填，類似 Java 的 LocalDate）
  final String? customerId;     // 關聯的客戶 ID（外鍵，可空）
  final String? customerName;   // 客戶名稱（關聯查詢後填充，不在資料庫中）
  final String product;         // 產品名稱（必填）
  final int quantity;           // 數量（預設 1，類似 Java 的 int）
  final double amount;          // 金額（預設 0.0，類似 Java 的 double）
  final bool paid;              // 是否已付款（預設 false，類似 Java 的 boolean）
  final String? notes;          // 備註
  final String userLogin;       // 用於資料串聯的登入帳號（必填）

  /**
   * 建構函數
   * 
   * Java 對比：
   * - quantity = 1: 預設參數值，類似 Java 的 public OrderModel(..., int quantity = 1)
   * - amount = 0.0: 預設參數值，類似 Java 的 public OrderModel(..., double amount = 0.0)
   * - paid = false: 預設參數值，類似 Java 的 public OrderModel(..., boolean paid = false)
   */
  OrderModel({
    required this.id,
    required this.date,
    this.customerId,
    this.customerName,
    required this.product,
    this.quantity = 1,          // 預設值：1
    this.amount = 0.0,          // 預設值：0.0
    this.paid = false,          // 預設值：false
    this.notes,
    required this.userLogin,
  });

  /**
   * 工廠方法：從 JSON 建立 OrderModel
   * 
   * Java 對比：
   * - 類似 Java 的 public static OrderModel fromJson(Map<String, Object> json)
   * 
   * 類型轉換說明：
   * - (json['quantity'] as num?)?.toInt(): 
   *   1. as num?: 轉換為數字類型（可能是 int 或 double）
   *   2. ?.toInt(): 安全調用，如果為 null 則不調用
   *   3. ?? 1: 如果為 null 則使用預設值 1
   *   類似 Java: Optional.ofNullable((Number) json.get("quantity")).map(Number::intValue).orElse(1)
   * 
   * - (json['amount'] as num?)?.toDouble():
   *   類似 Java: Optional.ofNullable((Number) json.get("amount")).map(Number::doubleValue).orElse(0.0)
   * 
   * - json['paid'] == true || json['paid'] == 'true':
   *   處理布林值可能以字串形式儲存的情況
   *   類似 Java: Boolean.parseBoolean(json.get("paid").toString())
   */
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      // DateTime.parse(): 解析日期字串
      date: DateTime.parse(json['date'] as String),
      customerId: json['customer_id'] as String?,
      customerName: json['customer_name'] as String?, // 關聯查詢後填充
      product: json['product'] as String? ?? '',
      // 類型轉換：num 是 int 和 double 的父類型
      // 類似 Java: ((Number) json.get("quantity")).intValue()
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      // 類似 Java: ((Number) json.get("amount")).doubleValue()
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      // 處理布林值：可能以 true/false 或 "true"/"false" 形式儲存
      // 類似 Java: Boolean.parseBoolean(json.get("paid").toString())
      paid: json['paid'] == true || json['paid'] == 'true',
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
   * - toStringAsFixed(2): 將 double 格式化為小數點後 2 位
   *   類似 Java: String.format("%.2f", amount) 或 DecimalFormat("#.00").format(amount)
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // 只取日期部分
      'date': date.toIso8601String().split('T')[0],
      'customer_id': customerId,
      // 注意：customerName 不儲存到資料庫，只是顯示用
      'product': product,
      'quantity': quantity,
      'amount': amount,
      'paid': paid,
      'notes': notes,
      'user_login': userLogin,
    };
  }
}
