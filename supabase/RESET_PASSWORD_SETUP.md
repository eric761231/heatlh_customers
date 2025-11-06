# 重置密碼設定指南

## 問題說明

如果重置密碼連結顯示 `error=access_denied&error_code=otp_expired`，通常是以下原因：

1. **Supabase Redirect URLs 未設定**：需要在 Supabase Dashboard 中添加正確的 URL
2. **連結已過期**：重置連結通常有 24 小時的有效期
3. **URL 不匹配**：重定向 URL 必須與 Supabase 設定的完全一致

## 解決步驟

### 1. 設定 Supabase Redirect URLs

1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 選擇您的專案
3. 前往 **Authentication** > **URL Configuration**
4. 在 **Redirect URLs** 區域，添加以下 URL：

#### 本地開發環境：

```
http://localhost:3000/reset-password.html
http://localhost:3000/html/reset-password.html
http://localhost:8000/reset-password.html
http://localhost:8000/html/reset-password.html
http://localhost:5500/reset-password.html
http://localhost:5500/html/reset-password.html
```

#### 生產環境（Netlify 部署）：

**重要：** 請將 `your-site.netlify.app` 替換為您的實際 Netlify 網址

```
https://your-site.netlify.app/reset-password.html
```

**如果使用自訂網域：**
```
https://your-domain.com/reset-password.html
```

**注意：** 
- 由於 `netlify.toml` 設定 `publish = "html"`，檔案會直接部署在根目錄
- 所以路徑應該是 `/reset-password.html`，而不是 `/html/reset-password.html`
- 如果您有多個 Netlify 站點（例如預覽部署），也需要添加對應的 URL

#### 使用自訂網域：

```
https://your-domain.com/reset-password.html
https://your-domain.com/html/reset-password.html
```

### 2. 設定 Site URL

在 **Site URL** 欄位中，輸入您的網站基本 URL：

- 本地開發：`http://localhost:3000` 或 `http://localhost:8000`（根據您使用的端口）
- **Netlify 生產環境：** `https://your-site.netlify.app`（替換為您的實際 Netlify 網址）
- 使用自訂網域：`https://your-domain.com`

### 3. 檢查 Email 模板

1. 前往 **Authentication** > **Email Templates**
2. 確認 **Reset Password** 模板存在
3. 檢查模板中的連結格式是否正確

### 4. 測試流程

1. 在忘記密碼頁面輸入 Email
2. 點擊「發送重置郵件」
3. 檢查 Email 收件匣（包括垃圾郵件資料夾）
4. 點擊郵件中的連結
5. 應該會跳轉到 `reset-password.html` 頁面
6. 輸入新密碼完成重置

## 常見錯誤

### 錯誤：`otp_expired`

**原因：** 連結已過期（通常 24 小時後過期）

**解決方案：** 重新申請重置密碼郵件

### 錯誤：`access_denied`

**原因：** 
- Redirect URL 未在 Supabase 中設定
- URL 格式不匹配（例如缺少 `/` 或路徑不正確）

**解決方案：**
1. 檢查 Supabase Dashboard 中的 Redirect URLs
2. 確保 URL 完全匹配（包括協議 http/https、域名、端口、路徑）
3. 重新申請重置密碼郵件

### 連結無法點擊或跳轉失敗

**原因：** 
- 瀏覽器阻擋了重定向
- URL 格式錯誤

**解決方案：**
1. 檢查瀏覽器控制台的錯誤訊息
2. 確認 Supabase Dashboard 中的設定正確
3. 嘗試複製連結直接貼到瀏覽器地址欄

## 重要注意事項

1. **URL 必須完全匹配**：Supabase 會嚴格檢查重定向 URL，必須與 Redirect URLs 列表中的完全一致

2. **本地開發**：
   - 使用 `http://` 而不是 `https://`
   - 端口號必須正確
   - 路徑大小寫必須正確

3. **生產環境**：
   - 使用 `https://`
   - 確保網域正確

4. **測試建議**：
   - 先在本地測試
   - 確認功能正常後再部署到生產環境
   - 每次更改 URL 設定後，重新申請重置郵件

## 相關文件

- [Supabase Auth 文件](https://supabase.com/docs/guides/auth)
- [密碼重置設定](https://supabase.com/docs/guides/auth/auth-password-reset)
