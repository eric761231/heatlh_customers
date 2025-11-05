# Java 後端（目前未使用）

## 狀態

目前系統使用 **Supabase 直接連線**，不需要 Java 後端。

## 為什麼保留這個資料夾？

Java 後端程式碼已經寫好了，如果未來需要：
- 更複雜的業務邏輯
- 資料處理和驗證
- 報表生成
- 其他需要 Java 處理的功能

可以隨時啟用。

## 如何啟用 Java 後端？

1. 安裝 Maven（或使用 IntelliJ IDEA）
2. 下載依賴：`mvn dependency:copy-dependencies -DoutputDirectory=lib`
3. 設定資料庫密碼（`application.properties`）
4. 啟動後端：`mvn spring-boot:run`
5. 修改 `html/js/config.js`：`DATA_SOURCE = 'java-api'`

## 目前建議

**繼續使用 Supabase**，因為：
- ✅ 已經運作正常
- ✅ 不需要額外設定
- ✅ 程式碼已經完成
