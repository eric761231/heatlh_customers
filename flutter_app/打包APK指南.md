# 📦 打包 APK 指南

## 🚀 快速打包（測試用）

### 方法 1：使用 Flutter 命令（最簡單）

```bash
cd flutter_app
flutter build apk
```

**生成的 APK 位置：**
```
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

### 方法 2：打包多個架構版本

```bash
cd flutter_app
flutter build apk --split-per-abi
```

這會生成三個 APK（針對不同 CPU 架構）：
- `app-armeabi-v7a-release.apk` (32位 ARM)
- `app-arm64-v8a-release.apk` (64位 ARM) ⭐ 推薦
- `app-x86_64-release.apk` (64位 x86)

**優點：** 每個 APK 檔案較小
**缺點：** 需要選擇正確的版本安裝

## 📱 安裝到手機

### 方法 1：使用 USB 連接

```bash
# 連接手機後
cd flutter_app
flutter install
```

### 方法 2：手動安裝

1. 將 APK 檔案傳輸到手機（USB、藍牙、雲端等）
2. 在手機上打開檔案管理器
3. 點擊 APK 檔案
4. 允許「安裝未知來源的應用程式」（如果提示）
5. 安裝完成

## ⚙️ 當前配置說明

### 簽名配置

目前使用 **debug 簽名**（適合測試）：
```kotlin
signingConfig = signingConfigs.getByName("debug")
```

### 應用程式資訊

- **應用程式 ID：** `com.heath.heath_app`
- **版本號：** `1.0.0+1`
- **應用程式名稱：** `heath_app`

## 🔐 正式發布簽名（可選）

如果要發布到 Google Play，需要配置正式簽名：

### 步驟 1：生成簽名金鑰

```bash
cd flutter_app/android
keytool -genkey -v -keystore heath-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias heath
```

### 步驟 2：創建 key.properties

在 `flutter_app/android/` 目錄下創建 `key.properties`：

```properties
storePassword=您的密碼
keyPassword=您的密碼
keyAlias=heath
storeFile=heath-release-key.jks
```

### 步驟 3：更新 build.gradle.kts

修改 `flutter_app/android/app/build.gradle.kts`：

```kotlin
// 在 android { 之前添加
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... 現有配置 ...
    
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // 可選：啟用程式碼混淆
            // isMinifyEnabled = true
            // proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}
```

## 📊 APK 大小優化

### 方法 1：啟用程式碼混淆（減小檔案大小）

在 `build.gradle.kts` 的 `release` 區塊中：

```kotlin
buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
        isMinifyEnabled = true
        proguardFiles(
            getDefaultProguardFile("proguard-android-optimize.txt"),
            "proguard-rules.pro"
        )
    }
}
```

### 方法 2：使用 App Bundle（Google Play 推薦）

```bash
flutter build appbundle
```

生成 `app-release.aab`，檔案更小，Google Play 會自動優化。

## 🎯 打包命令總覽

| 命令 | 用途 | 輸出位置 |
|------|------|---------|
| `flutter build apk` | 打包單一 APK | `build/app/outputs/flutter-apk/app-release.apk` |
| `flutter build apk --split-per-abi` | 打包多個架構版本 | `build/app/outputs/flutter-apk/` |
| `flutter build appbundle` | 打包 App Bundle | `build/app/outputs/bundle/release/app-release.aab` |
| `flutter build apk --release` | 打包 Release 版本 | 同上 |

## ⚠️ 注意事項

1. **首次打包時間較長**
   - 需要下載依賴和編譯
   - 可能需要 5-10 分鐘

2. **簽名金鑰安全**
   - 不要將 `key.properties` 和 `.jks` 檔案提交到 Git
   - 已加入 `.gitignore`

3. **測試建議**
   - 先在模擬器或測試手機上安裝測試
   - 確認所有功能正常後再發布

4. **版本號更新**
   - 修改 `pubspec.yaml` 中的 `version: 1.0.0+1`
   - 格式：`版本名稱+版本代碼`

## 🆘 常見問題

### 問題 1：打包失敗

**解決：**
```bash
cd flutter_app
flutter clean
flutter pub get
flutter build apk
```

### 問題 2：找不到 APK

**檢查位置：**
```
flutter_app/build/app/outputs/flutter-apk/
```

### 問題 3：安裝失敗（簽名錯誤）

**解決：**
- 卸載舊版本
- 重新安裝新 APK

## 📝 版本更新流程

1. **更新版本號**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2  # 版本名稱+版本代碼
   ```

2. **打包新版本**
   ```bash
   flutter build apk
   ```

3. **測試新版本**
   - 安裝到測試手機
   - 確認功能正常

4. **發布**
   - 上傳到 Google Play
   - 或分發給用戶

---

**現在開始打包：執行 `flutter build apk`**

