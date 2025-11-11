import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';
import '../models/user_model.dart';
import '../models/customer_model.dart';
import '../models/schedule_model.dart';
import '../models/order_model.dart';

/**
 * Supabase 服務類（單例模式 + DAO 模式）
 * 
 * Java 對比：
 * - 單例模式：類似 Java 的 private static final instance
 * - 類似 Spring 的 @Service 或 @Repository，提供資料訪問層
 * - 類似 Java 的 DAO (Data Access Object) 模式
 * 
 * 設計模式：
 * - 單例模式：確保只有一個實例
 * - DAO 模式：封裝資料庫操作
 * - 工廠模式：factory 建構函數
 */
class SupabaseService {
  // 單例模式的實現
  // Java 對比：private static final SupabaseService instance = new SupabaseService();
  static final SupabaseService _instance = SupabaseService._internal();
  
  // 工廠建構函數：類似 Java 的 getInstance() 方法
  // Java 對比：public static SupabaseService getInstance() { return instance; }
  factory SupabaseService() => _instance;
  
  // 私有建構函數：防止外部直接實例化
  // Java 對比：private SupabaseService() { }
  SupabaseService._internal();

  // late: 延遲初始化，類似 Java 的懶加載
  // 類似 Java: private SupabaseClient client;
  late SupabaseClient _client;
  
  // 初始化標記：類似 Java 的 boolean initialized = false;
  bool _initialized = false;

  /**
   * 初始化 Supabase 客戶端
   * 
   * Java 對比：
   * - Future<void> 類似 Java 的 CompletableFuture<Void>
   * - async 類似 Java 的 @Async 或 CompletableFuture.supplyAsync()
   * - await 類似 Java 的 .get() 或 .join()
   */
  Future<void> initialize() async {
    // 如果已初始化，直接返回（單例模式的雙重檢查）
    // 類似 Java: if (initialized) return;
    if (_initialized) return;

    // 初始化 Supabase SDK
    // 類似 Java: Supabase.initialize(url, key);
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,      // 類似 Java 的常量類
      anonKey: AppConfig.supabaseAnonKey,
    );

    // 取得 Supabase 客戶端實例
    // 類似 Java: this.client = Supabase.getInstance().getClient();
    _client = Supabase.instance.client;
    _initialized = true;
  }

  /**
   * Getter：取得 Supabase 客戶端
   * 
   * Java 對比：
   * - get client 類似 Java 的 public SupabaseClient getClient()
   * - 類似 Java 的懶加載單例：if (client == null) { client = new ...(); }
   */
  SupabaseClient get client {
    if (!_initialized) {
      // throw: 拋出異常，類似 Java 的 throw new IllegalStateException(...)
      throw Exception('Supabase 尚未初始化，請先調用 initialize()');
    }
    return _client;
  }

  /**
   * 取得當前使用者
   * 
   * Java 對比：
   * - Future<UserModel?> 類似 Java 的 CompletableFuture<Optional<UserModel>>
   * - UserModel? 可空類型，類似 Java 的 Optional<UserModel> 或 @Nullable
   * 
   * 業務邏輯：
   * 1. 從 Supabase Auth 取得當前會話
   * 2. 從 users 表查詢用戶詳細資料
   * 3. 如果查詢失敗，使用 Auth 的預設資料
   */
  Future<UserModel?> getCurrentUser() async {
    try {
      // 取得當前會話（類似 Java 的 Session.getCurrentSession()）
      final session = client.auth.currentSession;
      
      // null 檢查：類似 Java 的 if (session == null || session.getUser() == null)
      if (session == null || session.user == null) {
        return null; // 類似 Java 的 return Optional.empty();
      }

      final user = session.user;
      // ?? 運算符：空值合併，類似 Java 的 Optional.orElse("")
      final userEmail = user.email ?? '';

      // 從 users 表獲取用戶資料（類似 Java 的 UserDAO.findById()）
      UserModel? userModel;
      try {
        // Supabase 查詢：類似 Java 的 JPA: SELECT name, picture, user_login FROM users WHERE id = ?
        final response = await client
            .from('users')                    // 類似 Java 的 @Table(name = "users")
            .select('name, picture, user_login') // 類似 Java 的 @Select
            .eq('id', user.id)                // 類似 Java 的 WHERE id = ?
            .maybeSingle();                   // 類似 Java 的 findById()，可能返回 null

        // 如果查詢成功，建立 UserModel
        // 類似 Java: if (response != null) { userModel = new UserModel(...); }
        if (response != null) {
          userModel = UserModel(
            id: user.id,
            email: userEmail,
            // as String?: 類型轉換，類似 Java 的 (String) response.get("name")
            name: response['name'] as String?,
            picture: response['picture'] as String?,
            // ?? 運算符：如果為 null 則使用 email，類似 Java 的 Optional.orElse()
            userLogin: response['user_login'] as String? ?? userEmail,
          );
        }
      } catch (e) {
        // 查詢失敗不影響登入，只記錄錯誤
        // 類似 Java 的 Logger.warn("無法從 users 表獲取用戶資料", e);
        print('無法從 users 表獲取用戶資料: $e');
      }

      // 如果沒有 user_login，使用 email 作為 fallback
      // 類似 Java: String userLogin = userModel != null ? userModel.getUserLogin() : userEmail;
      final userLogin = userModel?.userLogin ?? userEmail;

      // 返回 UserModel，如果查詢失敗則使用 Auth 的預設資料
      // 類似 Java 的 Optional.orElse() 或三目運算符
      return userModel ??
          UserModel(
            id: user.id,
            email: userEmail,
            // ?. 安全調用運算符：類似 Java 的 Optional.map() 或 if (user.getMetadata() != null)
            name: user.userMetadata?['name'] as String? ??
                userEmail.split('@')[0], // 如果沒有名稱，使用 email 的前綴
            picture: user.userMetadata?['picture'] as String?,
            userLogin: userLogin,
          );
    } catch (e) {
      // 異常處理：類似 Java 的 catch (Exception e) { Logger.error(...); return null; }
      print('取得使用者資訊失敗: $e');
      return null;
    }
  }

  /**
   * 登入方法
   * 
   * Java 對比：
   * - Future<AuthResponse> 類似 Java 的 CompletableFuture<AuthResponse>
   * - 類似 Java 的 UserService.login(String email, String password)
   */
  Future<AuthResponse> signIn(String email, String password) async {
    // 調用 Supabase Auth 的登入方法
    // 類似 Java: return authService.signInWithPassword(email, password);
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /**
   * 註冊方法
   * 
   * Java 對比：
   * - String? 可空類型，類似 Java 的 @Nullable String
   * - 類似 Java 的 UserService.register(String email, String password, String name)
   */
  Future<AuthResponse> signUp(String email, String password, String? name) async {
    // 註冊新用戶
    // 類似 Java: AuthResponse response = authService.signUp(email, password, metadata);
    final response = await client.auth.signUp(
      email: email,
      password: password,
      // data: 類似 Java 的 Map<String, Object> metadata
      data: name != null ? {'name': name} : null,
    );

    // 如果註冊成功，建立 users 表記錄
    // 類似 Java: if (response.getUser() != null) { userDAO.insert(...); }
    if (response.user != null) {
      try {
        // 插入 users 表記錄
        // 類似 Java 的 JPA: userRepository.save(new User(...))
        await client.from('users').insert({
          'id': response.user!.id,
          'user_login': email, // 使用 email 作為 user_login
          'name': name ?? email.split('@')[0], // 如果沒有名稱，使用 email 前綴
        });
      } catch (e) {
        // 插入失敗不影響註冊流程，只記錄錯誤
        // 類似 Java 的 Logger.warn("建立 users 表記錄失敗", e);
        print('建立 users 表記錄失敗: $e');
      }
    }

    return response;
  }

  /**
   * 登出方法
   * 
   * Java 對比：
   * - 類似 Java 的 Session.invalidate() 或 SecurityContext.logout()
   */
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  /**
   * 重置密碼（發送重置郵件）
   * 
   * Java 對比：
   * - 類似 Java 的 PasswordService.sendResetEmail(String email)
   */
  Future<void> resetPassword(String email) async {
    await client.auth.resetPasswordForEmail(email);
  }

  /**
   * 更新密碼
   * 
   * Java 對比：
   * - 類似 Java 的 PasswordService.updatePassword(String newPassword)
   */
  Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  // ==================== 客戶資料操作（DAO 模式）====================

  /**
   * 取得所有客戶（查詢操作）
   * 
   * Java 對比：
   * - Future<List<CustomerModel>> 類似 Java 的 CompletableFuture<List<Customer>>
   * - 類似 Java 的 CustomerDAO.findAll() 或 CustomerRepository.findAll()
   * 
   * 業務邏輯：
   * 1. 檢查使用者是否登入
   * 2. 使用 user_login 過濾資料（資料隔離）
   * 3. 按建立時間降序排列
   */
  Future<List<CustomerModel>> getAllCustomers() async {
    // 取得當前使用者（類似 Java 的 SecurityContext.getCurrentUser()）
    final user = await getCurrentUser();
    
    // 驗證使用者是否登入
    // 類似 Java: if (user == null || user.getUserLogin().isEmpty()) { throw new UnauthorizedException(); }
    if (user == null || user.userLogin.isEmpty) {
      throw Exception('未登入，無法取得客戶資料');
    }

    // 查詢客戶資料
    // 類似 Java 的 JPA: SELECT * FROM customers WHERE user_login = ? ORDER BY created_at DESC
    final response = await client
        .from('customers')                           // 類似 @Table(name = "customers")
        .select('*')                                 // SELECT *
        .eq('user_login', user.userLogin)           // WHERE user_login = ?
        .order('created_at', ascending: false);     // ORDER BY created_at DESC

    // 將 JSON 轉換為 CustomerModel 列表
    // 類似 Java 的 Stream.map(): response.stream().map(json -> CustomerModel.fromJson(json)).collect(Collectors.toList())
    return (response as List)
        .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /**
   * 根據 ID 取得客戶（查詢操作）
   * 
   * Java 對比：
   * - Future<CustomerModel?> 類似 Java 的 CompletableFuture<Optional<Customer>>
   * - 類似 Java 的 CustomerDAO.findById(String id)
   */
  Future<CustomerModel?> getCustomerById(String id) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法取得客戶資料');
    }

    // 查詢單筆資料
    // 類似 Java 的 JPA: SELECT * FROM customers WHERE id = ? AND user_login = ?
    final response = await client
        .from('customers')
        .select('*')
        .eq('id', id)
        .eq('user_login', user.userLogin)  // 確保只能查詢自己的資料
        .maybeSingle();                    // 可能返回 null

    if (response == null) return null;
    return CustomerModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 新增客戶（插入操作）
   * 
   * Java 對比：
   * - 類似 Java 的 CustomerDAO.save(Customer customer) 或 CustomerRepository.save()
   */
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final user = await getCurrentUser();
    // 產生 ID：使用時間戳，類似 Java 的 UUID.randomUUID().toString()
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    // 將 CustomerModel 轉換為 Map（類似 Java 的 toMap() 或 JSON 序列化）
    final data = customer.toJson();
    data['id'] = id;
    data['user_login'] = user?.userLogin ?? '';

    // 插入資料
    // 類似 Java 的 JPA: customerRepository.save(new Customer(...))
    final response = await client
        .from('customers')
        .insert(data)      // INSERT INTO customers VALUES (...)
        .select()          // 返回插入的資料
        .single();         // 確保只返回一筆

    return CustomerModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 更新客戶（更新操作）
   * 
   * Java 對比：
   * - 類似 Java 的 CustomerDAO.update(String id, Customer customer)
   */
  Future<CustomerModel> updateCustomer(String id, CustomerModel customer) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法更新客戶資料');
    }

    // 準備更新資料（移除不需要更新的欄位）
    final data = customer.toJson();
    data.remove('id');        // 移除 ID（不允許更新）
    data.remove('user_login'); // 移除 user_login（不允許更新）

    // 更新資料
    // 類似 Java 的 JPA: UPDATE customers SET ... WHERE id = ? AND user_login = ?
    final response = await client
        .from('customers')
        .update(data)                    // UPDATE ... SET ...
        .eq('id', id)                    // WHERE id = ?
        .eq('user_login', user.userLogin) // AND user_login = ?
        .select()                        // 返回更新的資料
        .single();

    return CustomerModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 刪除客戶（刪除操作）
   * 
   * Java 對比：
   * - 類似 Java 的 CustomerDAO.deleteById(String id)
   */
  Future<void> deleteCustomer(String id) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法刪除客戶資料');
    }

    // 刪除資料
    // 類似 Java 的 JPA: DELETE FROM customers WHERE id = ? AND user_login = ?
    await client
        .from('customers')
        .delete()                       // DELETE FROM ...
        .eq('id', id)                   // WHERE id = ?
        .eq('user_login', user.userLogin); // AND user_login = ?
  }

  // ==================== 行程資料操作 ====================

  /**
   * 取得所有行程
   * 
   * Java 對比：
   * - 類似 Java 的 ScheduleDAO.findAll()
   * 
   * 業務邏輯：
   * 1. 查詢所有行程
   * 2. 如果有客戶 ID，查詢客戶名稱並關聯
   * 3. 類似 Java 的 JOIN 查詢或關聯查詢
   */
  Future<List<ScheduleModel>> getAllSchedules() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法取得行程資料');
    }

    // 查詢行程資料
    // 類似 Java 的 JPA: SELECT * FROM schedules WHERE user_login = ? ORDER BY date ASC
    final response = await client
        .from('schedules')
        .select('*')
        .eq('user_login', user.userLogin)
        .order('date', ascending: true);

    // 轉換為 ScheduleModel 列表
    final schedules = (response as List)
        .map((json) => ScheduleModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // 如果有客戶 ID，取得客戶名稱（類似 Java 的 JOIN 查詢）
    // 類似 Java: Set<String> customerIds = schedules.stream().map(Schedule::getCustomerId).filter(Objects::nonNull).collect(Collectors.toSet());
    final customerIds = schedules
        .where((s) => s.customerId != null)  // 過濾出有客戶 ID 的行程
        .map((s) => s.customerId!)           // 提取客戶 ID
        .toSet()                              // 去重
        .toList();

    if (customerIds.isNotEmpty) {
      // 批量查詢客戶名稱（類似 Java 的 IN 查詢）
      // 類似 Java 的 JPA: SELECT id, name FROM customers WHERE id IN (?) AND user_login = ?
      final customersResponse = await client
          .from('customers')
          .select('id, name')
          .inFilter('id', customerIds)        // WHERE id IN (...)
          .eq('user_login', user.userLogin);

      // 建立客戶 ID 到名稱的映射（類似 Java 的 Map<String, String>）
      // 類似 Java: Map<String, String> customerMap = customers.stream().collect(Collectors.toMap(Customer::getId, Customer::getName));
      final customerMap = <String, String>{};
      for (var customer in customersResponse as List) {
        final customerData = customer as Map<String, dynamic>;
        customerMap[customerData['id'] as String] =
            customerData['name'] as String? ?? '';
      }

      // 更新行程的客戶名稱（類似 Java 的關聯資料填充）
      // 類似 Java: schedules.forEach(schedule -> schedule.setCustomerName(customerMap.get(schedule.getCustomerId())));
      for (var schedule in schedules) {
        if (schedule.customerId != null) {
          schedule = ScheduleModel(
            id: schedule.id,
            title: schedule.title,
            date: schedule.date,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
            type: schedule.type,
            customerId: schedule.customerId,
            customerName: customerMap[schedule.customerId], // 關聯客戶名稱
            notes: schedule.notes,
            userLogin: schedule.userLogin,
          );
        }
      }
    }

    return schedules;
  }

  /**
   * 新增行程
   * 
   * Java 對比：
   * - 類似 Java 的 ScheduleDAO.save(Schedule schedule)
   */
  Future<ScheduleModel> addSchedule(ScheduleModel schedule) async {
    final user = await getCurrentUser();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final data = schedule.toJson();
    data['id'] = id;
    data['user_login'] = user?.userLogin ?? '';

    final response = await client
        .from('schedules')
        .insert(data)
        .select()
        .single();

    return ScheduleModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 刪除行程
   * 
   * Java 對比：
   * - 類似 Java 的 ScheduleDAO.deleteById(String id)
   */
  Future<void> deleteSchedule(String id) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法刪除行程');
    }

    await client
        .from('schedules')
        .delete()
        .eq('id', id)
        .eq('user_login', user.userLogin);
  }

  // ==================== 訂單資料操作 ====================

  /**
   * 取得所有訂單
   * 
   * Java 對比：
   * - 類似 Java 的 OrderDAO.findAll()
   * - 邏輯與 getAllSchedules() 類似，包含客戶名稱關聯
   */
  Future<List<OrderModel>> getAllOrders() async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法取得訂單資料');
    }

    // 查詢訂單資料（按日期降序）
    final response = await client
        .from('orders')
        .select('*')
        .eq('user_login', user.userLogin)
        .order('date', ascending: false);

    final orders = (response as List)
        .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
        .toList();

    // 關聯客戶名稱（邏輯與 getAllSchedules() 相同）
    final customerIds = orders
        .where((o) => o.customerId != null)
        .map((o) => o.customerId!)
        .toSet()
        .toList();

    if (customerIds.isNotEmpty) {
      final customersResponse = await client
          .from('customers')
          .select('id, name')
          .inFilter('id', customerIds)
          .eq('user_login', user.userLogin);

      final customerMap = <String, String>{};
      for (var customer in customersResponse as List) {
        final customerData = customer as Map<String, dynamic>;
        customerMap[customerData['id'] as String] =
            customerData['name'] as String? ?? '';
      }

      // 更新訂單的客戶名稱
      for (var order in orders) {
        if (order.customerId != null) {
          order = OrderModel(
            id: order.id,
            date: order.date,
            customerId: order.customerId,
            customerName: customerMap[order.customerId],
            product: order.product,
            quantity: order.quantity,
            amount: order.amount,
            paid: order.paid,
            notes: order.notes,
            userLogin: order.userLogin,
          );
        }
      }
    }

    return orders;
  }

  /**
   * 新增訂單
   * 
   * Java 對比：
   * - 類似 Java 的 OrderDAO.save(Order order)
   */
  Future<OrderModel> addOrder(OrderModel order) async {
    final user = await getCurrentUser();
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    final data = order.toJson();
    data['id'] = id;
    data['user_login'] = user?.userLogin ?? '';

    final response = await client
        .from('orders')
        .insert(data)
        .select()
        .single();

    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 更新訂單
   * 
   * Java 對比：
   * - 類似 Java 的 OrderDAO.update(String id, Order order)
   */
  Future<OrderModel> updateOrder(String id, OrderModel order) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法更新訂單');
    }

    final data = order.toJson();
    data.remove('id');
    data.remove('user_login');

    final response = await client
        .from('orders')
        .update(data)
        .eq('id', id)
        .eq('user_login', user.userLogin)
        .select()
        .single();

    return OrderModel.fromJson(response as Map<String, dynamic>);
  }

  /**
   * 刪除訂單
   * 
   * Java 對比：
   * - 類似 Java 的 OrderDAO.deleteById(String id)
   */
  Future<void> deleteOrder(String id) async {
    final user = await getCurrentUser();
    if (user == null) {
      throw Exception('未登入，無法刪除訂單');
    }

    await client
        .from('orders')
        .delete()
        .eq('id', id)
        .eq('user_login', user.userLogin);
  }
}
