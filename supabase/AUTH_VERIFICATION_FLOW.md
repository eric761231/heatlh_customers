# 登入驗證流程說明

## 驗證機制

### 登入驗證使用 Supabase Auth，不是直接查詢 users 表

登入流程分為兩個階段：

### 階段 1：帳號密碼驗證（Supabase Auth）

```javascript
// 使用 Supabase Auth 驗證
const { data, error } = await client.auth.signInWithPassword({
    email: email,
    password: password
});
```

**驗證位置：**
- Supabase 的 `auth.users` 表（由 Supabase 自動管理）
- **不是** 查詢 `users` 表

**驗證過程：**
1. Supabase Auth 檢查 Email 是否存在於 `auth.users` 表
2. 驗證密碼的 hash 值（密碼是加密儲存的）
3. 如果驗證成功，建立 session 並返回用戶資料

### 階段 2：獲取業務資料（users 表）

登入成功後，才會查詢 `users` 表來獲取業務相關資料：

```javascript
// 登入成功後，查詢 users 表獲取業務資料
const { data: existingUser } = await client
    .from('users')
    .select('user_login, name')
    .eq('id', data.user.id)
    .single();
```

**用途：**
- 獲取 `user_login`（用於資料串聯）
- 獲取 `name`（用戶名稱）
- 更新 `last_login`（最後登入時間）

## 資料表說明

### auth.users（Supabase Auth 管理）

**位置：** Supabase 內部系統表，無法直接查詢

**儲存資料：**
- `id` - 用戶 ID（UUID）
- `email` - Email 地址
- `encrypted_password` - 加密的密碼
- `email_confirmed_at` - Email 確認時間
- `user_metadata` - 用戶元資料（如 name）

**用途：** 認證和授權

### users（業務資料表）

**位置：** 您的專案資料庫中

**儲存資料：**
- `id` - 對應 `auth.users.id`
- `user_login` - 用於資料串聯（通常等於 email）
- `name` - 用戶名稱
- `last_login` - 最後登入時間

**用途：** 業務邏輯和資料串聯

## 完整登入流程

```
1. 用戶輸入 Email 和密碼
   ↓
2. client.auth.signInWithPassword()
   ↓
3. Supabase Auth 驗證（查詢 auth.users 表）
   ├─ ❌ 失敗 → 顯示錯誤訊息
   └─ ✅ 成功 → 建立 session
   ↓
4. 查詢 users 表獲取業務資料
   ├─ 獲取 user_login
   ├─ 獲取 name
   └─ 更新 last_login
   ↓
5. 登入成功，跳轉到主頁面
```

## 重要說明

### ❌ 不是這樣驗證的：

```javascript
// 錯誤：直接查詢 users 表驗證
const { data } = await client
    .from('users')
    .select('*')
    .eq('email', email)
    .eq('password', password) // 密碼是加密的，無法這樣比較
```

### ✅ 正確的驗證方式：

```javascript
// 正確：使用 Supabase Auth
const { data, error } = await client.auth.signInWithPassword({
    email: email,
    password: password
});
```

## 為什麼使用 Supabase Auth？

1. **安全性**：
   - 密碼是加密儲存的（使用 bcrypt）
   - 不會在前端暴露密碼
   - 自動處理 session 管理

2. **功能完整**：
   - Email 驗證
   - 密碼重置
   - Session 管理
   - JWT Token 生成

3. **不需要自己實現**：
   - 不需要處理密碼加密
   - 不需要管理 session
   - 不需要處理安全漏洞

## 常見問題

### Q: 可以自己查詢 users 表來驗證嗎？

**A:** 不建議，因為：
1. 密碼是加密儲存的，無法直接比較
2. 需要自己處理安全問題
3. 無法使用 Supabase 的 session 管理

### Q: users 表的作用是什麼？

**A:** 
- 儲存業務相關的用戶資料
- 用於資料串聯（`user_login`）
- 儲存用戶的個人資訊（name, picture 等）

### Q: 如果 users 表沒有資料，登入會失敗嗎？

**A:** 不會！登入驗證只看 `auth.users` 表。如果 `users` 表沒有資料：
- 登入仍然會成功
- 但業務資料可能無法正常顯示
- 系統會在登入時自動建立 `users` 表記錄

## 相關文件

- [Supabase Auth 文件](https://supabase.com/docs/guides/auth)
- [密碼驗證](https://supabase.com/docs/guides/auth/auth-password)
