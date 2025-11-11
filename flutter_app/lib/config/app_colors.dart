/**
 * 應用程式顏色配置
 * 
 * 此檔案定義了應用程式的所有顏色，參考網頁版本的 CSS 樣式
 * 
 * Java 對比：
 * - 類似 Java 的常量類（Constants Class）
 * - static final 類似 Java 的 public static final
 * - Color(0xFF...) 是 Flutter 的顏色表示方式，類似 Java 的 Color 類
 * 
 * 顏色說明：
 * - 0xFF 表示完全不透明（Alpha = 255）
 * - 後面的 6 位數字是 RGB 十六進制值
 * - 例如：0xFF14B8A6 = #14B8A6（網頁格式）
 */
import 'package:flutter/material.dart';

/// 應用程式顏色配置類（類似 Java 的 Constants 類）
class AppColors {
  // 私有建構函數，防止實例化（類似 Java 的 private constructor）
  AppColors._();

  // ==================== 主色調（青綠色 Teal）====================
  // 參考網頁：background: linear-gradient(135deg, #14B8A6 0%, #0D9488 100%);
  
  /// 主色調 - 青綠色（Teal 500）
  /// 用於：按鈕、連結、強調元素
  /// 網頁對應：#14B8A6
  static const Color primary = Color(0xFF14B8A6);
  
  /// 主色調深色變體（Teal 600）
  /// 用於：按鈕懸停、漸變背景
  /// 網頁對應：#0D9488
  static const Color primaryDark = Color(0xFF0D9488);
  
  /// 主色調淺色變體（用於背景）
  /// 網頁對應：rgba(20, 184, 166, 0.05)
  static const Color primaryLight = Color(0x0D14B8A6);
  
  /// 主色調半透明（用於卡片背景）
  /// 網頁對應：rgba(20, 184, 166, 0.1)
  static const Color primarySemiTransparent = Color(0x1A14B8A6);

  // ==================== 背景顏色 ====================
  
  /// 主要背景色 - 白色
  /// 網頁對應：background: #FFFFFF;
  static const Color background = Color(0xFFFFFFFF);
  
  /// 次要背景色 - 淺灰色
  /// 用於：卡片背景、輸入框背景
  static const Color backgroundSecondary = Color(0xFFF9FAFB);
  
  /// 卡片背景色
  static const Color cardBackground = Color(0xFFFFFFFF);

  // ==================== 文字顏色 ====================
  
  /// 主要文字顏色 - 深灰色
  /// 網頁對應：color: #1F2937;
  static const Color textPrimary = Color(0xFF1F2937);
  
  /// 次要文字顏色 - 中灰色
  /// 網頁對應：color: #6B7280;
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// 輔助文字顏色 - 淺灰色
  /// 網頁對應：color: #9CA3AF;
  static const Color textHint = Color(0xFF9CA3AF);
  
  /// 白色文字（用於深色背景）
  /// 網頁對應：color: #FFFFFF;
  static const Color textWhite = Color(0xFFFFFFFF);

  // ==================== 狀態顏色 ====================
  
  /// 成功狀態 - 深綠色
  /// 網頁對應：color: #065F46;
  static const Color success = Color(0xFF065F46);
  
  /// 成功背景 - 淺綠色
  /// 網頁對應：background: #D1FAE5;
  static const Color successBackground = Color(0xFFD1FAE5);
  
  /// 錯誤狀態 - 深紅色
  /// 網頁對應：color: #991B1B;
  static const Color error = Color(0xFF991B1B);
  
  /// 錯誤背景 - 淺紅色
  /// 網頁對應：background: #FEE2E2;
  static const Color errorBackground = Color(0xFFFEE2E2);
  
  /// 錯誤邊框
  /// 網頁對應：border-color: rgba(239, 68, 68, 0.5);
  static const Color errorBorder = Color(0x80EF4444);

  // ==================== 邊框顏色 ====================
  
  /// 主要邊框顏色
  /// 網頁對應：border-color: #14B8A6;
  static const Color border = Color(0xFF14B8A6);
  
  /// 邊框淺色（用於輸入框）
  /// 網頁對應：border-color: rgba(20, 184, 166, 0.4);
  static const Color borderLight = Color(0x6614B8A6);
  
  /// 分割線顏色
  static const Color divider = Color(0xFFE5E7EB);

  // ==================== 漸變色 ====================
  
  /// 主色調漸變（用於按鈕、背景）
  /// 網頁對應：linear-gradient(135deg, #14B8A6 0%, #0D9488 100%);
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDark],
  );
  
  /// 垂直漸變（用於某些背景）
  /// 網頁對應：linear-gradient(180deg, #14B8A6 0%, #0D9488 100%);
  static const LinearGradient primaryGradientVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );

  // ==================== 陰影顏色 ====================
  
  /// 卡片陰影顏色
  static const Color shadow = Color(0x1A000000);
  
  /// 按鈕陰影顏色
  static const Color shadowButton = Color(0x3314B8A6);
}

