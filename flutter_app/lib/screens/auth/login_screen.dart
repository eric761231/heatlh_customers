import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import '../../config/app_colors.dart'; // 導入顏色配置
import 'register_screen.dart';
import 'forgot_password_screen.dart';

/// 登入頁面
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 表單驗證鍵
  final _formKey = GlobalKey<FormState>();
  
  // 輸入控制器
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // 狀態變數
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// 處理登入操作
  Future<void> _handleLogin() async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 設定載入狀態
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 取得認證提供者並執行登入
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } catch (e) {
      // 登入失敗，顯示錯誤訊息
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }

  /// 根據錯誤訊息取得友善的錯誤提示
  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    // 網路連線錯誤
    if (errorLower.contains('network') ||
        errorLower.contains('connection') ||
        errorLower.contains('timeout') ||
        errorLower.contains('socket') ||
        errorLower.contains('failed host lookup')) {
      return '網路連線失敗，請檢查您的網路連線後重試';
    }
    
    // 認證錯誤
    if (errorLower.contains('invalid login credentials') ||
        errorLower.contains('invalid credentials') ||
        errorLower.contains('email or password') ||
        errorLower.contains('wrong password')) {
      return 'Email 或密碼錯誤，請檢查後重試';
    }
    
    // Email 未驗證
    if (errorLower.contains('email not confirmed') ||
        errorLower.contains('email confirmation') ||
        errorLower.contains('not confirmed')) {
      return '請先確認您的 Email。請檢查您的收件匣（包括垃圾郵件）並點擊確認連結。';
    }
    
    // 用戶不存在
    if (errorLower.contains('user not found') ||
        errorLower.contains('does not exist')) {
      return '此 Email 尚未註冊，請先註冊帳號';
    }
    
    // 速率限制
    if (errorLower.contains('too many requests') ||
        errorLower.contains('rate limit')) {
      return '登入嘗試過於頻繁，請稍後再試';
    }
    
    // 其他錯誤：顯示原始錯誤訊息（簡化版）
    if (errorLower.length > 100) {
      return '登入失敗：${errorLower.substring(0, 100)}...';
    }
    
    return '登入失敗：$error';
  }

  /// 建立錯誤訊息顯示區塊
  /// 參考網頁版本：.error-message 樣式
  Widget? _buildErrorMessage() {
    if (_errorMessage == null) return null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // 網頁對應：background: rgba(239, 68, 68, 0.2); border-color: rgba(239, 68, 68, 0.5);
        color: AppColors.errorBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.errorBorder),
      ),
      child: Text(
        _errorMessage!,
        // 網頁對應：color: #991B1B;
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  /// 建立 Email 輸入欄位
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
        hintText: 'your@email.com',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入 Email';
        }
        if (!value.contains('@')) {
          return 'Email 格式不正確';
        }
        return null;
      },
    );
  }

  /// 建立密碼輸入欄位
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: '密碼',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請輸入密碼';
        }
        if (value.length < 6) {
          return '密碼長度至少需要 6 個字元';
        }
        return null;
      },
    );
  }

  /// 建立忘記密碼按鈕
  /// 參考網頁版本：.forgot-password 樣式
  Widget _buildForgotPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ForgotPasswordScreen(),
            ),
          );
        },
        // 網頁對應：color: #14B8A6;
        child: const Text(
          '忘記密碼？',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  /// 建立登入按鈕
  /// 參考網頁版本：.btn-login-gradient 樣式
  /// 網頁對應：background: linear-gradient(135deg, #14B8A6 0%, #0D9488 100%);
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        // 使用漸變色（參考網頁版本）
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        // 網頁對應：box-shadow: 0 4px 12px rgba(20, 184, 166, 0.3);
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowButton,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _handleLogin,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
                    ),
                  )
                : const Text(
                    '登入',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// 建立註冊連結
  /// 參考網頁版本：.signup-link 樣式
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 網頁對應：color: #6B7280;
        Text(
          '還沒有帳號？',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegisterScreen(),
              ),
            );
          },
          // 網頁對應：color: #14B8A6;
          child: const Text(
            '立即註冊',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 建立表單內容
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Text(
          '歡迎回來，葡眾愛客戶',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        const Text(
          '登入',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) _buildErrorMessage()!,
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 8),
        _buildForgotPasswordButton(),
        const SizedBox(height: 24),
        _buildLoginButton(),
        const SizedBox(height: 16),
        _buildRegisterLink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 參考網頁版本的登入頁面設計
    // 網頁對應：.login-page 和 .login-header 樣式
    return Scaffold(
      // 背景色：白色（網頁對應：background: #FFFFFF;）
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // 頂部青綠色區域（參考網頁的 .login-header）
            // 網頁對應：background: linear-gradient(135deg, #14B8A6 0%, #0D9488 100%);
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Text(
                    '歡迎回來',
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
            ),
            // 底部白色卡片（參考網頁的 .login-content-card）
            // 網頁對應：border-radius: 48px 48px 0 0;
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(48),
                    topRight: Radius.circular(48),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: _buildFormContent(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
