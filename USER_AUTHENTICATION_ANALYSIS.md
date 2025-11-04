# 使用者登入系統分析與建議

## 目前的做法

### 現況
- **登入方式**：Google Sign-In（OAuth 2.0）
- **登入狀態儲存**：僅存在瀏覽器的 `localStorage` 中
- **儲存內容**：
  ```javascript
  {
    email: "user@example.com",
    name: "使用者名稱",
    picture: "頭像URL",
    exp: 過期時間戳記
  }
  ```

### 優點
- ✅ 簡單快速，無需後端資料庫
- ✅ 不需要管理使用者密碼
- ✅ 利用 Google 的認證系統

### 缺點
- ❌ **換裝置無法使用**：登入狀態只存在單一瀏覽器
- ❌ **無法追蹤操作**：不知道是誰新增/修改了資料
- ❌ **無法管理權限**：所有使用者權限相同
- ❌ **無法做審計記錄**：無法追蹤資料變更歷史
- ❌ **資料遺失風險**：清除瀏覽器資料會失去登入狀態

## 建議方案

### 方案 A：基礎使用者資料表（推薦）

**適合場景：**
- 需要追蹤誰做了什麼操作
- 需要多裝置登入
- 未來可能需要權限管理

**實作內容：**
1. 建立 `users` 資料表
2. 首次登入時自動建立使用者記錄
3. 記錄操作者資訊（誰新增/修改了資料）

**優點：**
- ✅ 可以追蹤操作者
- ✅ 支援多裝置登入
- ✅ 可以記錄登入歷史
- ✅ 為未來權限管理做準備

**缺點：**
- ⚠️ 需要額外的資料表維護

### 方案 B：完整使用者管理系統

**適合場景：**
- 需要多使用者協作
- 需要權限管理（管理員、一般使用者）
- 需要審計記錄

**實作內容：**
1. 建立 `users` 資料表
2. 建立 `roles` 資料表（權限管理）
3. 在客戶、行程、訂單表中添加 `created_by` 和 `updated_by` 欄位
4. 記錄操作歷史

**優點：**
- ✅ 完整的權限管理
- ✅ 完整的審計記錄
- ✅ 支援團隊協作

**缺點：**
- ⚠️ 實作較複雜
- ⚠️ 需要更多資料表

### 方案 C：保持現狀（不推薦）

**適合場景：**
- 單一使用者系統
- 不需要追蹤操作者
- 不需要多裝置登入

**缺點：**
- ❌ 無法追蹤操作者
- ❌ 無法多裝置使用

## 建議

根據您的需求「葡眾愛客戶」系統，我建議採用**方案 A：基礎使用者資料表**，因為：

1. **追蹤操作者**：可以知道是誰新增/修改了客戶資料、行程、訂單
2. **多裝置支援**：使用者可以在不同裝置上登入
3. **未來擴展**：為權限管理做準備
4. **實作簡單**：只需新增一個資料表和少量代碼

## 實作建議

### 1. 建立使用者資料表

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    name TEXT,
    picture TEXT,
    google_id TEXT UNIQUE,
    last_login TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### 2. 在現有資料表中添加操作者欄位（可選）

```sql
-- 客戶表
ALTER TABLE customers ADD COLUMN created_by TEXT;
ALTER TABLE customers ADD COLUMN updated_by TEXT;

-- 行程表
ALTER TABLE schedules ADD COLUMN created_by TEXT;
ALTER TABLE schedules ADD COLUMN updated_by TEXT;

-- 訂單表
ALTER TABLE orders ADD COLUMN created_by TEXT;
ALTER TABLE orders ADD COLUMN updated_by TEXT;
```

### 3. 登入流程

1. 使用者使用 Google 登入
2. 檢查 Supabase 中是否存在該使用者
3. 如果不存在，自動建立使用者記錄
4. 更新 `last_login` 時間
5. 儲存使用者 ID 到 localStorage（用於識別操作者）

## 結論

**建議：建立使用者資料表**

理由：
- 可以追蹤操作者（誰新增/修改了資料）
- 支援多裝置登入
- 為未來功能擴展做準備
- 實作相對簡單

是否要我協助實作使用者資料表？

