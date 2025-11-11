# 📱 iOS (iPad) 打包指南

## ✅ 好消息：您的應用程式已經配置了 iPad 支援！

檢查結果：
- ✅ iPad 方向支援已配置
- ✅ Bundle Identifier: `com.heath.heathApp`
- ✅ 支援 iPhone 和 iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)
- ✅ 最低 iOS 版本：12.0

## 🚀 打包方法

### ⚠️ 重要：iOS 打包需要在 macOS 上進行

iOS 應用程式必須在 **macOS** 系統上打包，無法在 Windows 上直接打包。

### 方法 1：使用 Flutter 命令（推薦）

#### 前提條件

1. **macOS 系統**（Mac 電腦）
2. **Xcode**（從 App Store 安裝）
3. **CocoaPods**（iOS 依賴管理工具）
   ```bash
   sudo gem install cocoapods
   ```

#### 打包步驟

```bash
# 1. 進入專案目錄
cd flutter_app

# 2. 安裝 iOS 依賴
cd ios
pod install
cd ..

# 3. 打包 iOS 應用程式
flutter build ios --release
```

**生成的檔案位置：**
```
flutter_app/build/ios/iphoneos/Runner.app
```

### 方法 2：使用 Xcode（圖形界面）

#### 步驟 1：打開 Xcode 專案

```bash
cd flutter_app/ios
open Runner.xcworkspace
```

#### 步驟 2：配置簽名

1. 在 Xcode 中選擇 `Runner` 專案
2. 選擇 `Signing & Capabilities` 標籤
3. 選擇您的 **Team**（需要 Apple Developer 帳號）
4. 確認 **Bundle Identifier** 是 `com.heath.heathApp`

#### 步驟 3：選擇目標裝置

- 選擇 **Any iOS Device** 或 **Generic iOS Device**
- 或選擇您的 iPad

#### 步驟 4：打包

1. 選單：**Product** → **Archive**
2. 等待建置完成
3. 在 Organizer 視窗中選擇 **Distribute App**

## 📦 安裝到 iPad

### 方法 1：使用 Xcode 直接安裝（開發測試）

#### 前提條件

1. iPad 連接 Mac（USB 或 WiFi）
2. 在 iPad 上信任此電腦
3. 在 Xcode 中選擇您的 iPad 作為目標裝置

#### 安裝步驟

```bash
# 1. 連接 iPad 到 Mac
# 2. 在 Xcode 中選擇 iPad
# 3. 點擊運行按鈕（▶️）
```

或使用 Flutter 命令：

```bash
cd flutter_app
flutter run -d <iPad設備ID>
```

### 方法 2：使用 TestFlight（推薦）

#### 前提條件

1. **Apple Developer 帳號**（年費 $99 USD）
2. 在 App Store Connect 中建立應用程式

#### 步驟

1. **打包並上傳到 App Store Connect**
   ```bash
   flutter build ipa
   ```
   或使用 Xcode：**Product** → **Archive** → **Distribute App** → **App Store Connect**

2. **在 App Store Connect 中設定 TestFlight**
   - 登入 [App Store Connect](https://appstoreconnect.apple.com)
   - 選擇您的應用程式
   - 進入 **TestFlight** 標籤
   - 上傳建置版本

3. **邀請測試者**
   - 添加測試者的 Email
   - 測試者會收到邀請郵件
   - 在 iPad 上安裝 **TestFlight** App
   - 透過 TestFlight 安裝您的應用程式

### 方法 3：使用 Ad Hoc 分發（限 100 台裝置）

#### 前提條件

1. **Apple Developer 帳號**
2. 在 Apple Developer 中註冊 iPad 的 UDID

#### 步驟

1. **在 Xcode 中建立 Ad Hoc 分發**
   - **Product** → **Archive**
   - **Distribute App** → **Ad Hoc**
   - 選擇已註冊的裝置

2. **生成 .ipa 檔案**
   - 匯出 .ipa 檔案
   - 透過 iTunes 或 Finder 安裝到 iPad

### 方法 4：使用企業分發（需要企業帳號）

適用於企業內部大量分發。

## 🔧 配置檢查

### 1. Bundle Identifier

當前配置：`com.heath.heathApp`

如果需要修改：
- 在 Xcode 中：**Runner** → **Signing & Capabilities** → **Bundle Identifier**

### 2. 應用程式名稱

當前配置：`Heath App`

在 `ios/Runner/Info.plist` 中：
```xml
<key>CFBundleDisplayName</key>
<string>Heath App</string>
```

### 3. 版本號

當前配置：`1.0.0+1`

在 `pubspec.yaml` 中：
```yaml
version: 1.0.0+1
```

### 4. iPad 支援確認

在 `ios/Runner/Info.plist` 中已配置：
```xml
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
</array>
```

## 📋 打包命令總覽

| 命令 | 用途 | 輸出 |
|------|------|------|
| `flutter build ios` | 建置 iOS 應用程式 | `build/ios/iphoneos/Runner.app` |
| `flutter build ios --release` | 建置 Release 版本 | 同上 |
| `flutter build ipa` | 建置 .ipa 檔案 | `build/ios/ipa/*.ipa` |
| `flutter run -d <device>` | 直接運行到裝置 | - |

## ⚠️ 重要注意事項

### 1. 必須在 macOS 上打包

- ❌ 無法在 Windows 上直接打包 iOS
- ✅ 必須使用 Mac 電腦或 macOS 虛擬機

### 2. Apple Developer 帳號

**開發測試：**
- 免費帳號可以安裝到自己的裝置（7 天有效期）
- 需要每年重新簽名

**正式分發：**
- 需要付費 Apple Developer 帳號（$99 USD/年）
- 可以上傳到 App Store
- 可以使用 TestFlight

### 3. 簽名問題

如果遇到簽名錯誤：
1. 確認 Xcode 中選擇了正確的 Team
2. 確認 Bundle Identifier 唯一
3. 確認 Apple Developer 帳號有效

### 4. 網路權限

iOS 應用程式預設允許網路連線，不需要特別配置（與 Android 不同）。

## 🎯 快速開始（在 Mac 上）

```bash
# 1. 進入專案目錄
cd flutter_app

# 2. 安裝 iOS 依賴
cd ios
pod install
cd ..

# 3. 檢查連接的裝置
flutter devices

# 4. 如果 iPad 已連接，直接運行
flutter run -d <iPad設備ID>

# 或打包
flutter build ios --release
```

## 🔍 檢查 iPad 是否連接

```bash
flutter devices
```

應該會顯示：
```
iPhone (mobile) • <device-id> • ios • iOS 15.0
iPad (mobile)   • <device-id> • ios • iOS 15.0
```

## 💡 替代方案（如果沒有 Mac）

### 方案 1：使用雲端 Mac 服務

- **MacStadium**：租用 Mac 雲端服務
- **MacinCloud**：Mac 雲端服務
- **AWS EC2 Mac**：Amazon 的 Mac 實例

### 方案 2：使用 CI/CD 服務

- **Codemagic**：專門為 Flutter 設計的 CI/CD
- **Bitrise**：支援 iOS 建置
- **GitHub Actions**：使用 macOS runner

### 方案 3：請有 Mac 的朋友幫忙

打包一次後，可以透過 TestFlight 分發給您。

## 🆘 常見問題

### Q: 我沒有 Mac，怎麼辦？
**A:** 
1. 使用雲端 Mac 服務
2. 使用 CI/CD 服務（如 Codemagic）
3. 請有 Mac 的朋友幫忙打包

### Q: 需要 Apple Developer 帳號嗎？
**A:** 
- 開發測試：免費帳號即可（7 天有效期）
- 正式分發：需要付費帳號（$99 USD/年）

### Q: 可以在 Windows 上打包 iOS 嗎？
**A:** 不行，必須在 macOS 上打包。

### Q: 打包後如何安裝到 iPad？
**A:** 
1. 透過 Xcode 直接安裝（開發測試）
2. 透過 TestFlight（推薦）
3. 透過 Ad Hoc 分發
4. 上傳到 App Store

### Q: iPad 和 iPhone 是同一個檔案嗎？
**A:** 是的！同一個 .ipa 或 .app 可以在 iPhone 和 iPad 上使用。

---

## 📝 總結

1. **必須在 macOS 上打包** ⚠️
2. **您的應用程式已配置 iPad 支援** ✅
3. **推薦使用 TestFlight 分發** 📱
4. **需要 Apple Developer 帳號才能正式分發** 💰

**如果您有 Mac：**
```bash
cd flutter_app
cd ios && pod install && cd ..
flutter build ios --release
```

**如果您沒有 Mac：**
- 考慮使用雲端 Mac 服務
- 或使用 CI/CD 服務（如 Codemagic）
- 或請有 Mac 的朋友幫忙

