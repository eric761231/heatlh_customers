# 安裝 Maven 詳細步驟（Windows）

## 步驟 1：下載 Maven

1. 前往 Maven 官方網站：
   - https://maven.apache.org/download.cgi

2. 下載檔案：
   - 找到 "Files" 區塊
   - 下載 `apache-maven-3.9.6-bin.zip`（或最新版本）
   - 檔案大小約 10MB

## 步驟 2：解壓縮

1. 解壓縮下載的 ZIP 檔案
2. 建議解壓到：`C:\Program Files\Apache\maven`
   - 如果沒有 `Apache` 資料夾，先建立它
   - 最終路徑應該是：`C:\Program Files\Apache\maven\apache-maven-3.9.6`

## 步驟 3：設定環境變數

### 方法 A：使用圖形介面（推薦）

1. **開啟系統內容**
   - 按 `Win + R`
   - 輸入 `sysdm.cpl`
   - 按 Enter

2. **開啟環境變數設定**
   - 點擊「進階」標籤
   - 點擊「環境變數」按鈕

3. **新增 MAVEN_HOME**
   - 在「系統變數」區塊中，點擊「新增」
   - 變數名稱：`MAVEN_HOME`
   - 變數值：`C:\Program Files\Apache\maven\apache-maven-3.9.6`
     （注意：如果您的 Maven 版本不同，請使用實際的資料夾名稱）
   - 點擊「確定」

4. **編輯 Path 變數**
   - 在「系統變數」中找到 `Path`
   - 點擊「編輯」
   - 點擊「新增」
   - 輸入：`%MAVEN_HOME%\bin`
   - 點擊「確定」
   - 點擊「確定」關閉環境變數視窗
   - 點擊「確定」關閉系統內容視窗

### 方法 B：使用 PowerShell（管理員權限）

```powershell
# 以管理員身份執行 PowerShell，然後執行：

# 設定 MAVEN_HOME（請替換為實際路徑）
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", "C:\Program Files\Apache\maven\apache-maven-3.9.6", "Machine")

# 更新 Path
$path = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = "$path;%MAVEN_HOME%\bin"
[System.Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
```

## 步驟 4：驗證安裝

1. **重新開啟所有終端機和 VS Code**
   - 這很重要！環境變數需要重新載入

2. **在 VS Code 終端機中執行：**
   ```powershell
   mvn -version
   ```

3. **預期輸出：**
   ```
   Apache Maven 3.9.6
   Maven home: C:\Program Files\Apache\maven\apache-maven-3.9.6
   Java version: 21.0.9
   ...
   ```

## 步驟 5：下載依賴並啟動

```powershell
cd java-backend
mvn dependency:copy-dependencies -DoutputDirectory=lib
mvn spring-boot:run
```

## ⚠️ 常見問題

### 問題 1：仍然找不到 mvn 命令

**解決方案：**
- 確認已重新開啟 VS Code 和終端機
- 確認環境變數設定正確
- 檢查 `%MAVEN_HOME%\bin` 是否存在 `mvn.cmd` 檔案

### 問題 2：權限不足

**解決方案：**
- 確認以管理員身份執行 PowerShell（如果使用方法 B）
- 或使用圖形介面方法（方法 A）

### 問題 3：路徑錯誤

**解決方案：**
- 確認 Maven 解壓的路徑
- 確認 `MAVEN_HOME` 指向正確的資料夾
- 確認 `%MAVEN_HOME%\bin` 中有 `mvn.cmd` 檔案

## 💡 建議

如果安裝 Maven 遇到困難，**強烈建議使用 IntelliJ IDEA**：
- 不需要設定環境變數
- 自動處理所有依賴
- 更容易使用


