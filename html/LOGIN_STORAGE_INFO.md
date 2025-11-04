# 登入資料儲存位置說明

## 資料儲存位置

### 1. localStorage（瀏覽器本地儲存）
**主要儲存位置：`localStorage.getItem('googleLogin')`**

**儲存的資料內容：**
```javascript
{
    email: "使用者email",
    name: "使用者名稱",
    picture: "頭像URL",
    googleId: "Google使用者ID",
    exp: 過期時間戳記 (24小時後)
}
```

**儲存位置：**
- 瀏覽器的 localStorage 中
- 鍵名：`googleLogin`
- 可在瀏覽器開發者工具 > Application > Local Storage 中查看

**為什麼會自動登入：**
- 當頁面載入時，`checkLoginStatus()` 函數會檢查 `localStorage.getItem('googleLogin')`
- 如果存在且未過期，會自動跳轉到 `calendar.html`
- 這就是為什麼會「記住」登入狀態的原因

### 2. Google Sign-In 會話（Google 的儲存）
**儲存位置：**
- Google 的 Cookie（在 `accounts.google.com` 網域）
- Google 的瀏覽器儲存（透過 Google Sign-In SDK）

**儲存的資料：**
- Google 帳號的認證狀態
- 已選擇的帳號資訊
- 自動登入的偏好設定

**注意：**
- 由於瀏覽器的同源政策（Same-Origin Policy），我們無法直接清除 Google 網域的 Cookie
- 但可以透過 `google.accounts.id.disableAutoSelect()` 和 `google.accounts.id.storeCredential(null)` 來禁用自動選擇

### 3. 其他可能的儲存位置

**sessionStorage：**
- 目前沒有使用，但 `clearAllLoginData()` 函數會清除它

**window 物件變數：**
- `window.dataCache` - 客戶資料快取
- `window.currentUser` - 當前使用者快取

## 如何清除所有登入資料

### 方法 1：使用登出按鈕
1. 在登入頁面點擊「登出帳號」按鈕
2. 確認清除操作
3. 系統會自動清除所有相關資料

### 方法 2：手動清除
1. 開啟瀏覽器開發者工具（F12）
2. 前往 Application（應用程式）> Local Storage
3. 找到您的網站網域
4. 刪除 `googleLogin` 鍵
5. 清除所有包含 `google`、`login`、`cache` 的鍵
6. 重新整理頁面

### 方法 3：清除瀏覽器 Cookie
1. 開啟瀏覽器設定
2. 清除瀏覽資料
3. 選擇「Cookie 和其他網站資料」
4. 清除所有 Cookie（或只清除 Google 相關的 Cookie）

## 為什麼會自動使用帳號登入？

### 原因 1：localStorage 中的登入資訊
- `localStorage.getItem('googleLogin')` 存在且未過期
- `checkLoginStatus()` 函數檢測到有效登入資訊後自動跳轉

**解決方法：**
- 使用「登出帳號」按鈕清除
- 或手動刪除 `localStorage` 中的 `googleLogin`

### 原因 2：Google 的自動選擇功能
- Google Sign-In SDK 會記住上次選擇的帳號
- 如果啟用了自動選擇，會自動使用該帳號

**解決方法：**
- 程式已設定 `auto_select: false` 來禁用自動選擇
- 但如果 Google 的 Cookie 仍存在，可能仍會提示上次的帳號
- 清除瀏覽器的 Cookie 可以解決此問題

## 程式碼中的清除邏輯

`clearAllLoginData()` 函數會清除：
1. ✅ `localStorage.googleLogin`
2. ✅ 所有包含 `googleLogin`、`cache`、`google`、`login` 的 localStorage 鍵
3. ✅ `sessionStorage` 中的所有資料
4. ✅ Google Sign-In 的會話狀態
5. ✅ `window.dataCache` 和 `window.currentUser` 變數

## 注意事項

⚠️ **無法清除 Google 網域的 Cookie**
- 由於瀏覽器安全政策，JavaScript 無法清除其他網域（如 `accounts.google.com`）的 Cookie
- 需要使用者手動清除瀏覽器的 Cookie，或使用「登出帳號」按鈕後，Google 會在下一次登入時要求重新選擇

⚠️ **清除後需要重新登入**
- 清除所有資料後，下次登入時 Google 可能會根據瀏覽器的 Cookie 提示上次使用的帳號
- 但不會自動選擇，需要手動確認

