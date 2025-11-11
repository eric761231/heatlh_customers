import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../main.dart';
import 'login_screen.dart';

/// 註冊頁面
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 表單驗證鍵
  final _formKey = GlobalKey<FormState>();
  
  // 輸入控制器
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // 狀態變數
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// 處理註冊操作
  Future<void> _handleRegister() async {
    // 驗證表單
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 設定載入狀態
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // 取得認證提供者並執行註冊
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final name = _nameController.text.trim();
      
      await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        name.isEmpty ? null : name,
      );

      // 註冊成功，顯示成功訊息
      setState(() {
        _successMessage =
            '註冊成功！\n\n📧 請檢查您的 Email 收件匣（包括垃圾郵件資料夾）並點擊驗證連結。\n\n💡 郵件可能需要幾分鐘才能送達，請耐心等候。\n\n驗證完成後即可登入。';
        _isLoading = false;
      });
    } catch (e) {
      // 註冊失敗，顯示錯誤訊息
      setState(() {
        _errorMessage = _getErrorMessage(e.toString());
        _isLoading = false;
      });
    }
  }

  /// 根據錯誤訊息取得友善的錯誤提示
  String _getErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('user already registered') ||
        errorLower.contains('already registered')) {
      return '此 Email 已經註冊，請直接登入';
    }
    
    if (errorLower.contains('password')) {
      return '密碼不符合要求';
    }
    
    if (errorLower.contains('email')) {
      return 'Email 格式不正確';
    }
    
    return '註冊失敗，請重試';
  }

  /// 建立錯誤訊息顯示區塊
  Widget? _buildErrorMessage() {
    if (_errorMessage == null) return null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        _errorMessage!,
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

  /// 建立成功訊息顯示區塊
  Widget? _buildSuccessMessage() {
    if (_successMessage == null) return null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        _successMessage!,
        style: TextStyle(color: Colors.green.shade700),
      ),
    );
  }

  /// 建立姓名輸入欄位
  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '姓名（選填）',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.person),
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

  /// 建立確認密碼輸入欄位
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: '確認密碼',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock_outline),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '請確認密碼';
        }
        if (value != _passwordController.text) {
          return '密碼不一致';
        }
        return null;
      },
    );
  }

  /// 建立註冊按鈕
  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleRegister,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('註冊'),
    );
  }

  /// 建立登入連結
  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('已經有帳號？'),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
          child: const Text('立即登入'),
        ),
      ],
    );
  }

  /// 建立表單內容
  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        const Text(
          '註冊',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 24),
        if (_errorMessage != null) _buildErrorMessage()!,
        if (_successMessage != null) _buildSuccessMessage()!,
        _buildNameField(),
        const SizedBox(height: 16),
        _buildEmailField(),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildConfirmPasswordField(),
        const SizedBox(height: 24),
        _buildRegisterButton(),
        const SizedBox(height: 16),
        _buildLoginLink(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('註冊'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: _buildFormContent(),
          ),
        ),
      ),
    );
  }
}
