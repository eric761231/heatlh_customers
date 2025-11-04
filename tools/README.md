# 工具說明

## XLSX 轉 CSV 轉換工具

提供兩種方式將 XLSX 檔案轉換為 CSV 格式：

### 方法 1：Python 腳本（推薦）

**優點：**
- 快速、穩定
- 支援大量資料
- 可批次處理

**使用方式：**

1. 安裝依賴：
```bash
pip install pandas openpyxl
```

2. 執行轉換：
```bash
# 轉換單個檔案（輸出到同目錄）
python tools/xlsx_to_csv.py data.xlsx

# 指定輸出目錄
python tools/xlsx_to_csv.py data.xlsx output/
```

3. 範例：
```bash
# 轉換客戶資料.xlsx
python tools/xlsx_to_csv.py "客戶資料.xlsx"

# 輸出結果：
# 客戶資料_Sheet1.csv
# 客戶資料_Sheet2.csv
# ...
```

### 方法 2：瀏覽器工具（簡單方便）

**優點：**
- 不需要安裝任何軟體
- 直接在瀏覽器中使用
- 支援拖放檔案

**使用方式：**

1. 在瀏覽器中打開 `tools/xlsx_to_csv.html`
2. 點擊或拖放 XLSX 檔案到上傳區域
3. 點擊「轉換為 CSV」按鈕
4. 下載轉換後的 CSV 檔案

**注意事項：**
- 大型檔案（> 10MB）可能處理較慢
- 需要在瀏覽器中開啟，建議使用 Chrome 或 Edge

## 使用場景

### 場景 1：資料遷移到 Supabase

如果您有 Excel 格式的資料需要遷移到 Supabase：

1. 將 Excel 轉換為 CSV
2. 在 Supabase Dashboard > Table Editor 中匯入 CSV
3. 或使用 SQL 匯入功能

### 場景 2：資料備份

將 Google Sheets 匯出為 Excel，然後轉換為 CSV 備份

### 場景 3：資料處理

將 Excel 資料轉換為 CSV 以便於其他程式處理

## 疑難排解

### Python 腳本錯誤：找不到 pandas

**解決方案：**
```bash
pip install pandas openpyxl
```

### 瀏覽器工具無法載入

**解決方案：**
- 確保網路連線正常（需要載入 CDN 資源）
- 嘗試重新整理頁面
- 檢查瀏覽器控制台是否有錯誤訊息

### 中文亂碼問題

**解決方案：**
- Python 腳本已使用 UTF-8 編碼（utf-8-sig），應該可以正常顯示中文
- 瀏覽器工具已加入 UTF-8 BOM，應該可以正常顯示中文
- 如果仍有問題，請檢查 Excel 檔案本身的編碼

