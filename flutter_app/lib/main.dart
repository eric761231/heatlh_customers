import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'config/app_colors.dart'; // 導入顏色配置
import 'models/user_model.dart'; // 導入 UserModel
import 'services/supabase_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';

/**
 * 應用程式入口點
 * 
 * Java 對比：
 * - 類似 Java 的 public static void main(String[] args)
 * - async 關鍵字表示這是異步方法（類似 Java 的 CompletableFuture）
 * - await 類似 Java 的 .get() 或 .join()，等待異步操作完成
 */
void main() async {
  // 確保 Flutter 綁定已初始化
  // 類似 Java 中初始化框架的靜態方法
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Supabase 服務（單例模式）
  // 類似 Java: SupabaseService.getInstance().initialize()
  await SupabaseService().initialize();

  // 啟動應用程式
  // 類似 Java Swing 的 JFrame.setVisible(true) 或 Spring Boot 的 run()
  runApp(const MyApp());
}

/**
 * 應用程式根 Widget
 * 
 * Java 對比：
 * - StatelessWidget 類似 Java 的無狀態組件（如 JPanel）
 * - extends 關鍵字用法相同
 * - @override 類似 Java 的 @Override 註解
 * 
 * Flutter 概念：
 * - Widget 是 Flutter 的 UI 組件，類似 Java Swing 的 Component
 * - StatelessWidget 表示這個組件不會改變狀態（類似不可變對象）
 * - build() 方法類似 Java 的 paint() 或 render() 方法
 */
class MyApp extends StatelessWidget {
  // const 建構函數：類似 Java 的 final 變數，編譯時常量
  // super.key：類似 Java 的 super()，調用父類建構函數
  const MyApp({super.key});

  /**
   * 建立 Widget 樹（UI 結構）
   * 
   * Java 對比：
   * - context 類似 Java 的 Graphics 或 Component，提供繪製上下文
   * - return 的 Widget 類似 Java 返回 JPanel 或 Container
   * 
   * Provider 模式：
   * - ChangeNotifierProvider 類似 Java 的觀察者模式（Observer Pattern）
   * - 類似 Spring 的 @Component 或 @Service，提供依賴注入
   */
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // create: 類似 Java 的工廠方法或 Spring 的 @Bean 方法
      // (_) => 是 Dart 的箭頭函數，類似 Java 8 的 Lambda: () -> new AuthProvider()
      create: (_) => AuthProvider(),
      
      // child: 類似 Java 的組合模式（Composite Pattern）
      // MaterialApp 是 Flutter 的應用程式容器，類似 Java Swing 的 JFrame
      child: MaterialApp(
        title: '葡眾愛客戶管理系統',
        debugShowCheckedModeBanner: false, // 隱藏右上角的 Debug 標籤
        
        // ThemeData: 類似 Java 的 UIManager.setLookAndFeel()，設定應用程式主題
        // 參考網頁版本的顏色配置（styles.css）
        theme: ThemeData(
          useMaterial3: true, // 使用 Material Design 3
          
          // 顏色配置：使用網頁版本的青綠色主題
          // 網頁對應：primary: #14B8A6, primaryDark: #0D9488
          colorScheme: ColorScheme.light(
            // 主色調：青綠色（參考網頁的登入頁面漸變色）
            primary: AppColors.primary, // #14B8A6
            primaryContainer: AppColors.primaryLight, // 淺色背景
            onPrimary: AppColors.textWhite, // 主色調上的文字（白色）
            
            // 次要顏色
            secondary: AppColors.primaryDark, // #0D9488
            secondaryContainer: AppColors.primarySemiTransparent,
            onSecondary: AppColors.textWhite,
            
            // 表面顏色（卡片、背景）
            surface: AppColors.background, // 白色背景
            surfaceContainerHighest: AppColors.cardBackground,
            onSurface: AppColors.textPrimary, // #1F2937
            
            // 錯誤顏色
            error: AppColors.error, // #991B1B
            errorContainer: AppColors.errorBackground, // #FEE2E2
            onError: AppColors.textWhite,
            
            // 背景顏色
            background: AppColors.background, // 白色
            onBackground: AppColors.textPrimary,
            
            // 亮度
            brightness: Brightness.light,
          ),
          
          // 輸入框主題
          inputDecorationTheme: InputDecorationTheme(
            // 邊框顏色：使用主色調
            // 網頁對應：border-color: #14B8A6;
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.border, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderLight, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.errorBorder, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.error, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: AppColors.backgroundSecondary,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          
          // 按鈕主題
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              // 使用主色調漸變（網頁對應：linear-gradient(135deg, #14B8A6 0%, #0D9488 100%)）
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textWhite,
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          // 卡片主題
          // 注意：使用 CardThemeData 而不是 CardTheme
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          
          // AppBar 主題
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary, // 使用主色調
            foregroundColor: AppColors.textWhite, // 白色文字
            elevation: 0,
            centerTitle: true,
          ),
          
          // 底部導航欄主題
          // 注意：NavigationBarThemeData 的 API 可能因 Flutter 版本而異
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.background,
            indicatorColor: AppColors.primaryLight,
            labelTextStyle: MaterialStateProperty.resolveWith((states) {
              // 選中狀態使用主色調，未選中使用次要文字顏色
              if (states.contains(MaterialState.selected)) {
                return const TextStyle(color: AppColors.primary);
              }
              return const TextStyle(color: AppColors.textPrimary);
            }),
            iconTheme: MaterialStateProperty.resolveWith((states) {
              // 選中狀態使用主色調，未選中使用次要文字顏色
              if (states.contains(MaterialState.selected)) {
                return const IconThemeData(color: AppColors.primary);
              }
              return const IconThemeData(color: AppColors.textSecondary);
            }),
          ),
        ),
        
        // home: 應用程式的首頁，類似 Java Swing 的 setContentPane()
        home: const AuthWrapper(),
      ),
    );
  }
}

/**
 * 認證狀態提供者（觀察者模式）
 * 
 * Java 對比：
 * - ChangeNotifier 類似 Java 的 Observable 類
 * - notifyListeners() 類似 Java 的 notifyObservers()
 * - 類似 Spring 的 @Service 或 @Component，管理業務邏輯
 * 
 * 設計模式：
 * - 單例模式：SupabaseService 使用單例
 * - 觀察者模式：ChangeNotifier 實現觀察者模式
 * - 狀態管理：類似 Java 的 State Pattern
 */
class AuthProvider extends ChangeNotifier {
  // final: 類似 Java 的 final，表示不可變引用
  // 單例模式：SupabaseService() 返回同一個實例
  final SupabaseService _supabaseService = SupabaseService();
  
  // 私有欄位：使用 _ 前綴，類似 Java 的 private
  // UserModel?: 可空類型，類似 Java 的 Optional<UserModel> 或 @Nullable
  UserModel? _currentUser;
  bool _isLoading = true;

  /**
   * Getter 方法：取得當前使用者
   * 
   * Java 對比：
   * - get currentUser 類似 Java 的 public UserModel getCurrentUser()
   * - => 是 Dart 的箭頭函數，直接返回表達式
   */
  UserModel? get currentUser => _currentUser;
  
  /**
   * Getter 方法：是否正在載入
   * 類似 Java: public boolean isLoading() { return _isLoading; }
   */
  bool get isLoading => _isLoading;
  
  /**
   * Getter 方法：是否已認證
   * 類似 Java: public boolean isAuthenticated() { return _currentUser != null; }
   */
  bool get isAuthenticated => _currentUser != null;

  /**
   * 建構函數
   * 
   * Java 對比：
   * - 類似 Java 的 public AuthProvider() { ... }
   * - 在構造函數中初始化，類似 Java 的 @PostConstruct
   */
  AuthProvider() {
    // 初始化時檢查認證狀態
    _checkAuthState();
    
    // 監聽認證狀態變化（觀察者模式）
    // listen: 類似 Java 的 addObserver() 或 RxJava 的 subscribe()
    // (data) => 是 Lambda 表達式，類似 Java 8 的 Consumer<AuthStateChange>
    _supabaseService.client.auth.onAuthStateChange.listen((data) {
      _checkAuthState();
    });
  }

  /**
   * 檢查認證狀態（私有方法）
   * 
   * Java 對比：
   * - Future<void> 類似 Java 的 CompletableFuture<Void>
   * - async 表示異步方法，類似 Java 的 @Async 或 CompletableFuture.supplyAsync()
   * - await 類似 Java 的 .get() 或 .join()
   */
  Future<void> _checkAuthState() async {
    _isLoading = true;
    // 通知所有觀察者狀態已改變
    // 類似 Java 的 notifyObservers() 或 Spring 的 ApplicationEventPublisher
    notifyListeners();

    try {
      // await: 等待異步操作完成，類似 Java 的 future.get()
      _currentUser = await _supabaseService.getCurrentUser();
    } catch (e) {
      // print: 類似 Java 的 System.out.println() 或 Logger
      print('檢查認證狀態失敗: $e');
      _currentUser = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  /**
   * 登入方法
   * 
   * Java 對比：
   * - Future<void> 類似 Java 的 CompletableFuture<Void>
   * - 拋出異常的方式類似 Java 的 throws Exception
   */
  Future<void> signIn(String email, String password) async {
    try {
      await _supabaseService.signIn(email, password);
      await _checkAuthState();
    } catch (e) {
      // rethrow: 重新拋出異常，類似 Java 的 throw e;
      rethrow;
    }
  }

  /**
   * 註冊方法
   * String? 表示可空字符串，類似 Java 的 @Nullable String
   */
  Future<void> signUp(String email, String password, String? name) async {
    try {
      await _supabaseService.signUp(email, password, name);
      await _checkAuthState();
    } catch (e) {
      rethrow;
    }
  }

  /**
   * 登出方法
   */
  Future<void> signOut() async {
    await _supabaseService.signOut();
    _currentUser = null;
    notifyListeners();
  }
}

/**
 * 認證包裝器（策略模式）
 * 
 * Java 對比：
 * - StatelessWidget 類似 Java 的無狀態組件
 * - Consumer 類似 Java 的觀察者或 Spring 的 @Autowired 注入依賴
 * 
 * 設計模式：
 * - 策略模式：根據認證狀態選擇不同的頁面（策略）
 * - 類似 Java 的 if-else 或 switch 選擇不同的實現
 */
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  /**
   * 建立 Widget（UI 組件）
   * 
   * Java 對比：
   * - Consumer<AuthProvider> 類似 Java 的 Consumer<T> 函數式接口
   * - builder: 類似 Java 的 Builder Pattern 或工廠方法
   */
  @override
  Widget build(BuildContext context) {
    // Consumer: 類似 Java 的觀察者模式，監聽 AuthProvider 的變化
    // 類似 Spring 的 @Autowired 注入 AuthProvider
    return Consumer<AuthProvider>(
      // builder: 類似 Java 的函數式接口 Function<T, R>
      // (context, authProvider, _) => 是 Lambda，類似 Java 8 的 (ctx, provider, _) -> { ... }
      builder: (context, authProvider, _) {
        // 正在載入，顯示載入指示器
        // 類似 Java Swing 的 JProgressBar 或 Web 的 Loading Spinner
        if (authProvider.isLoading) {
          return const Scaffold(
            // Scaffold: 類似 Java Swing 的 JFrame，提供基本的頁面結構
            body: Center(
              // Center: 類似 CSS 的 text-align: center，居中對齊
              child: CircularProgressIndicator(), // 類似 Java 的 JProgressBar
            ),
          );
        }

        // 已認證，顯示主頁面
        // 類似 Java 的條件渲染或路由選擇
        if (authProvider.isAuthenticated) {
          return const HomeScreen();
        }

        // 未認證，顯示登入頁面
        return const LoginScreen();
      },
    );
  }
}
