#!/bin/bash
# 測試資料庫連線的腳本（Linux/Mac）
# 使用前請先設定 application.properties 中的資料庫密碼

echo "========================================"
echo "測試 Java 後端資料庫連線"
echo "========================================"
echo ""

# 檢查是否已下載依賴
if [ ! -f "lib/postgresql-"*.jar ]; then
    echo "[錯誤] 尚未下載依賴，請先執行："
    echo "  mvn dependency:copy-dependencies -DoutputDirectory=lib"
    echo ""
    exit 1
fi

# 編譯專案
echo "[1/3] 編譯專案..."
ant compile
if [ $? -ne 0 ]; then
    echo "[錯誤] 編譯失敗"
    exit 1
fi

echo ""
echo "[2/3] 啟動應用程式進行連線測試..."
echo "注意：如果連線成功，會看到 '後端 API 已啟動'"
echo "      如果連線失敗，會看到資料庫連線錯誤訊息"
echo ""

# 執行應用程式（使用 Maven）
mvn spring-boot:run

echo ""
echo "[3/3] 測試完成"

