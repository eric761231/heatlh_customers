# 使用 Java 後端完整指南

## 📋 前置需求檢查

### 1. 檢查 Java 是否安裝

```powershell
java -version
```

需要 Java 11 或更高版本。

### 2. 檢查是否有 Maven（可選）

```powershell
mvn -version
```

如果沒有 Maven，我們會提供替代方案。

## 🚀 快速開始（推薦方案）

### 方案 A：使用 IntelliJ IDEA（最簡單）

1. **下載 IntelliJ IDEA Community（免費）**
   - https://www.jetbrains.com/idea/download/
   - 選擇 Community 版本（免費）

2. **開啟專案**
   - 開啟 IntelliJ IDEA
   - File > Open
   - 選擇 `java-backend` 資料夾
   - IntelliJ 會自動識別 Maven 專案

3. **自動下載依賴**
   - IntelliJ 會自動下載所有依賴
   - 等待右下角進度條完成

4. **設定資料庫密碼**
   - 編輯 `src/main/resources/application.properties`
   - 將 `YOUR_DATABASE_PASSWORD` 替換為 Supabase 資料庫密碼

5. **啟動應用程式**
   - 右鍵點擊 `src/main/java/com/heath/api/Application.java`
   - 選擇 "Run 'Application.main()'"
   - 或點擊右上角的綠色三角形

### 方案 B：使用 VS Code + Maven（需要安裝 Maven）

如果不想用 IntelliJ，需要先安裝 Maven。

## 📝 詳細步驟

### 步驟 1：取得 Supabase 資料庫密碼

1. 前往：https://supabase.com/dashboard/project/lvrcnmvnqbueghjyvxji/settings/database
2. 找到 **Connection string** 或 **Database password**
3. 複製密碼

### 步驟 2：設定資料庫連線

編輯 `java-backend/src/main/resources/application.properties`：

```properties
spring.datasource.password=你的實際密碼
```

### 步驟 3：下載依賴

#### 如果使用 IntelliJ IDEA：
- 自動下載，不需要手動操作

#### 如果使用 VS Code + Maven：
```powershell
cd java-backend
mvn dependency:copy-dependencies -DoutputDirectory=lib
```

### 步驟 4：啟動後端

#### IntelliJ IDEA：
- 右鍵 `Application.java` > Run

#### VS Code + Maven：
```powershell
cd java-backend
mvn spring-boot:run
```

**預期結果：**
```
=========================================
葡眾愛客戶管理系統 - 後端 API 已啟動
API 端點: http://localhost:8080/api
=========================================
```

### 步驟 5：更新前端設定

編輯 `html/js/config.js`：

```javascript
const DATA_SOURCE = 'java-api'; // 改為使用 Java 後端
```

### 步驟 6：更新前端 API URL（如果需要）

如果後端不在 localhost:8080，編輯 `html/js/java-api-client.js`：

```javascript
const JAVA_API_BASE_URL = 'http://localhost:8080/api';
```

### 步驟 7：重新載入前端 HTML 檔案

確保 HTML 檔案載入了 `java-api-client.js`（已經在之前的步驟中完成）。

## ✅ 驗證

### 1. 測試後端 API

在瀏覽器訪問：
```
http://localhost:8080/api/customers?userId=test-user-id
```

應該會返回 JSON（可能是空陣列 `[]`）。

### 2. 測試前端

1. 開啟前端（`html/login.html`）
2. 登入系統
3. 查看是否能正常載入資料

## 🔍 疑難排解

### 問題 1：找不到 Maven

**解決方案：**
- 使用 IntelliJ IDEA（推薦）
- 或安裝 Maven（參考 `INSTALL_MAVEN_SIMPLE.md`）

### 問題 2：資料庫連線失敗

**檢查：**
- 密碼是否正確
- Supabase 專案是否正常運行

### 問題 3：後端無法啟動

**檢查：**
- Java 版本是否正確（需要 11+）
- 依賴是否已下載
- 資料庫密碼是否設定

### 問題 4：前端無法連接後端

**檢查：**
- 後端是否在運行（`localhost:8080`）
- `config.js` 中 `DATA_SOURCE = 'java-api'`
- 瀏覽器控制台是否有錯誤

## 📌 快速檢查清單

- [ ] Java 11+ 已安裝
- [ ] 使用 IntelliJ IDEA 或已安裝 Maven
- [ ] 已設定資料庫密碼
- [ ] 後端已啟動（看到 "後端 API 已啟動"）
- [ ] 前端 `config.js` 設定為 `java-api`
- [ ] 可以訪問 `http://localhost:8080/api/customers?userId=test`

## 🎯 推薦流程

1. **下載 IntelliJ IDEA Community**（免費，最簡單）
2. **開啟 `java-backend` 資料夾**
3. **設定資料庫密碼**
4. **點擊 Run**
5. **更新前端設定**
6. **完成！**

需要我協助哪個步驟？

