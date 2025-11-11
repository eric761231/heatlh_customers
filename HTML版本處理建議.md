# 📄 HTML 版本處理建議

## 📊 當前狀況

### HTML 版本狀態
- ✅ **檔案完整**：所有 HTML 檔案都存在
- ⚠️ **標記為舊版本**：README.md 中標記為「舊版本」
- ⚠️ **Netlify 配置**：`netlify.toml` 仍配置為發布 `html` 目錄

### Flutter 版本狀態
- ✅ **完整實現**：所有功能都已實現
- ✅ **標記為推薦**：README.md 中標記為「推薦」
- ✅ **功能更完整**：包含新增客戶/訂單/行程功能

## 🤔 是否還需要 HTML 版本？

### 需要保留的情況

1. **仍在 Netlify 上部署**
   - 如果您的網站仍在 Netlify 上運行
   - 用戶可能仍在使用網頁版本
   - 建議：保留，但標記為舊版本

2. **作為備用方案**
   - 如果 Flutter 版本有問題，可以回退
   - 作為參考實現
   - 建議：保留，但標記為已棄用

3. **需要網頁版本**
   - 某些用戶可能無法安裝 App
   - 需要在瀏覽器中直接使用
   - 建議：保留並維護

### 可以移除的情況

1. **完全遷移到 Flutter**
   - 所有用戶都已使用 Flutter 版本
   - 不再需要網頁版本
   - 建議：移除，減少維護負擔

2. **Flutter Web 已部署**
   - 如果已部署 Flutter Web 版本
   - HTML 版本功能重複
   - 建議：移除 HTML，使用 Flutter Web

## 💡 建議方案

### 方案 1：保留 HTML 版本（推薦，如果仍在使用）

**優點：**
- 用戶可以繼續使用網頁版本
- 作為備用方案
- 不需要立即遷移

**做法：**
1. 保留 `html/` 目錄
2. 在 README 中明確標記為「舊版本，建議使用 Flutter 版本」
3. 更新 `netlify.toml` 說明（如果需要）

### 方案 2：移除 HTML 版本（如果不再使用）

**優點：**
- 減少專案複雜度
- 減少維護負擔
- 專注於 Flutter 版本

**做法：**
1. 確認不再需要網頁版本
2. 移除 `html/` 目錄
3. 更新 `netlify.toml`（如果不再部署）
4. 更新 README.md

### 方案 3：遷移到 Flutter Web（最佳方案）

**優點：**
- 統一程式碼庫
- 更好的維護性
- 功能一致

**做法：**
1. 保留 HTML 版本作為過渡
2. 部署 Flutter Web 版本
3. 逐步遷移用戶
4. 最後移除 HTML 版本

## 🔍 檢查清單

在決定是否移除 HTML 版本前，請確認：

- [ ] 是否仍在 Netlify 上部署？
- [ ] 是否有用戶仍在使用網頁版本？
- [ ] 是否需要網頁版本作為備用？
- [ ] 是否計劃部署 Flutter Web 版本？
- [ ] 是否所有功能都已遷移到 Flutter？

## 📝 如果決定移除

### 步驟 1：備份（可選）

```bash
# 建立備份分支
git checkout -b backup-html-version
git add html/
git commit -m "backup: HTML 版本備份"
git push origin backup-html-version
```

### 步驟 2：移除檔案

```bash
# 移除 html 目錄
git rm -r html/

# 更新 netlify.toml（如果不再部署）
# 或移除 netlify.toml
```

### 步驟 3：更新文檔

更新 `README.md`：
- 移除 HTML 版本說明
- 只保留 Flutter 版本說明

### 步驟 4：提交更改

```bash
git add .
git commit -m "chore: 移除 HTML 版本，專注於 Flutter 版本"
git push origin main
```

## 🎯 我的建議

### 如果 Netlify 仍在運行

**建議：暫時保留**
- 標記為「舊版本」
- 在 README 中說明建議使用 Flutter 版本
- 逐步引導用戶遷移到 Flutter

### 如果不再使用

**建議：移除**
- 減少專案複雜度
- 專注於 Flutter 版本開發
- 可以建立備份分支以防萬一

### 長期方案

**建議：遷移到 Flutter Web**
- 使用 `flutter build web` 打包網頁版本
- 統一程式碼庫
- 更好的維護性

## 📋 決策流程

```
是否需要網頁版本？
├─ 是 → 是否仍在 Netlify 上部署？
│   ├─ 是 → 保留 HTML 版本（標記為舊版本）
│   └─ 否 → 考慮 Flutter Web
│
└─ 否 → 移除 HTML 版本
    └─ 建立備份分支（可選）
```

---

**請根據您的實際情況決定是否保留 HTML 版本。**

