# Netlify 部署 - Supabase 重置密碼設定指南

## 重要說明

由於您的網站部署在 Netlify 上，需要在 Supabase Dashboard 中設定正確的 Netlify URL。

## 步驟 1：取得您的 Netlify 網址

1. 登入 [Netlify Dashboard](https://app.netlify.com/)
2. 選擇您的站點
3. 在站點概覽頁面，可以看到您的網址：
   - **生產網址**：通常是 `https://your-site-name.netlify.app`
   - **自訂網域**（如果已設定）：例如 `https://your-domain.com`

## 步驟 2：設定 Supabase Redirect URLs

1. 登入 [Supabase Dashboard](https://app.supabase.com/)
2. 選擇您的專案
3. 前往 **Authentication** > **URL Configuration**
4. 在 **Redirect URLs** 區域，點擊 **Add URL**
5. 添加您的 Netlify 網址：

### 如果使用 Netlify 預設網址：

```
https://your-site-name.netlify.app/reset-password.html
```

**範例：**
如果您的 Netlify 網址是 `https://amazing-site-123.netlify.app`，則添加：
```
https://amazing-site-123.netlify.app/reset-password.html
```

### 如果使用自訂網域：

```
https://your-domain.com/reset-password.html
```

### 如果有多個環境（預覽部署）：

如果您有 Netlify 的預覽部署（例如 pull request 部署），也需要添加：
```
https://deploy-preview-123--your-site-name.netlify.app/reset-password.html
```

## 步驟 3：設定 Site URL

在 **Site URL** 欄位中，輸入您的 Netlify 網址：

- 使用 Netlify 預設網址：`https://your-site-name.netlify.app`
- 使用自訂網域：`https://your-domain.com`

## 步驟 4：驗證設定

1. 在 Netlify 上部署您的網站
2. 前往忘記密碼頁面：`https://your-site.netlify.app/forgot-password.html`
3. 輸入 Email 並點擊「發送重置郵件」
4. 檢查 Email 收件匣
5. 點擊郵件中的重置連結
6. 應該會跳轉到 `https://your-site.netlify.app/reset-password.html`

## 常見問題

### Q: 為什麼需要設定 Redirect URLs？

A: Supabase 為了安全，只允許重定向到已預先設定的 URL。這樣可以防止惡意重定向攻擊。

### Q: 我可以添加多個 URL 嗎？

A: 可以！您可以添加：
- 本地開發 URL（localhost）
- Netlify 生產 URL
- Netlify 預覽 URL
- 自訂網域 URL

### Q: URL 必須完全匹配嗎？

A: 是的！包括：
- 協議（`http://` 或 `https://`）
- 域名（必須完全一致）
- 路徑（`/reset-password.html`）

### Q: 如何知道我的 Netlify 網址？

A: 
1. 在 Netlify Dashboard 中選擇您的站點
2. 在站點概覽頁面頂部可以看到網址
3. 或者查看您的 Netlify 部署日誌

## 注意事項

1. **路徑說明**：由於 `netlify.toml` 設定 `publish = "html"`，`html` 資料夾的檔案會直接部署在根目錄，所以路徑是 `/reset-password.html`，而不是 `/html/reset-password.html`

2. **HTTPS 必須**：Netlify 使用 HTTPS，所以 URL 必須以 `https://` 開頭

3. **連結有效期**：重置連結通常在 24 小時內有效，過期後需要重新申請

4. **測試建議**：設定完成後，建議先在本地測試，然後再在 Netlify 上測試

## 相關文件

- [Supabase Auth 文件](https://supabase.com/docs/guides/auth)
- [密碼重置設定](https://supabase.com/docs/guides/auth/auth-password-reset)
- [Netlify 部署文件](https://docs.netlify.com/)
