# 不用安裝 Maven 的解決方案

## 🎯 方案 1：使用 IntelliJ IDEA（推薦 - 最簡單）

### 為什麼推薦？
- ✅ **不需要安裝 Maven**
- ✅ IntelliJ 會自動下載所有依賴
- ✅ 一鍵啟動應用程式
- ✅ 免費（Community 版本）

### 步驟：

1. **下載 IntelliJ IDEA Community（免費）**
   - 前往：https://www.jetbrains.com/idea/download/
   - 選擇 **Community** 版本（完全免費）
   - 下載並安裝（約 5 分鐘）

2. **開啟專案**
   - 開啟 IntelliJ IDEA
   - 點擊 "Open" 或 File > Open
   - 選擇 `java-backend` 資料夾
   - 點擊 "OK"

3. **等待自動設定**
   - IntelliJ 會自動識別這是 Maven 專案
   - 右下角會顯示 "Importing Maven projects..."
   - 等待完成（可能需要 2-5 分鐘，第一次較久）

4. **啟動應用程式**
   - 找到 `src/main/java/com/heath/api/Application.java`
   - 右鍵點擊 > "Run 'Application.main()'"
   - 或點擊右上角的綠色三角形 ▶️

5. **完成！**
   - 看到 "後端 API 已啟動" 就成功了

---

## 🔧 方案 2：安裝 Maven（如果一定要用 VS Code）

如果您堅持使用 VS Code，需要安裝 Maven：

### Windows 安裝 Maven（5 分鐘）

1. **下載 Maven**
   - 前往：https://maven.apache.org/download.cgi
   - 下載 `apache-maven-3.9.6-bin.zip`（或最新版本）

2. **解壓縮**
   - 解壓到：`C:\Program Files\Apache\maven`

3. **設定環境變數**
   - 按 `Win + R`，輸入 `sysdm.cpl`，按 Enter
   - 點擊「進階」標籤 > 「環境變數」
   - 在「系統變數」中：
     - 點擊「新增」
     - 變數名稱：`MAVEN_HOME`
     - 變數值：`C:\Program Files\Apache\maven`
     - 點擊「確定」
   - 找到 `Path`，點擊「編輯」
   - 點擊「新增」，輸入：`%MAVEN_HOME%\bin`
   - 點擊「確定」關閉所有視窗

4. **驗證安裝**
   - **重新開啟** VS Code 終端機
   - 執行：`mvn -version`
   - 應該會看到版本資訊

5. **下載依賴並啟動**
   ```powershell
   cd java-backend
   mvn dependency:copy-dependencies -DoutputDirectory=lib
   mvn spring-boot:run
   ```

---

## 📊 方案比較

| 項目 | IntelliJ IDEA | 安裝 Maven + VS Code |
|------|--------------|---------------------|
| 安裝時間 | 5 分鐘 | 10-15 分鐘 |
| 設定複雜度 | 簡單 | 中等 |
| 自動處理依賴 | ✅ 是 | ❌ 需要手動 |
| 除錯功能 | ✅ 強大 | ❌ 基本 |
| 推薦度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## 🎯 我的建議

**強烈建議使用 IntelliJ IDEA**，因為：
1. 不需要安裝 Maven
2. 不需要設定環境變數
3. 自動處理所有依賴
4. 更容易除錯和開發
5. 完全免費

---

## ✅ 快速檢查清單

### 如果選擇 IntelliJ IDEA：
- [ ] 下載 IntelliJ IDEA Community
- [ ] 開啟 `java-backend` 資料夾
- [ ] 等待依賴下載完成
- [ ] 點擊 Run ▶️
- [ ] 看到 "後端 API 已啟動"

### 如果選擇安裝 Maven：
- [ ] 下載 Maven
- [ ] 解壓到指定位置
- [ ] 設定環境變數
- [ ] 驗證安裝（`mvn -version`）
- [ ] 下載依賴並啟動

---

需要我協助哪個方案？

