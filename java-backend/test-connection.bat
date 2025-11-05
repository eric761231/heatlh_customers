@echo off
REM 測試資料庫連線的批次檔（Windows）
REM 使用前請先設定 application.properties 中的資料庫密碼

echo ========================================
echo 測試 Java 後端資料庫連線
echo ========================================
echo.

REM 檢查是否已下載依賴
if not exist "lib\postgresql-*.jar" (
    echo [錯誤] 尚未下載依賴，請先執行：
    echo   mvn dependency:copy-dependencies -DoutputDirectory=lib
    echo.
    pause
    exit /b 1
)

REM 編譯專案
echo [1/3] 編譯專案...
call ant compile
if %errorlevel% neq 0 (
    echo [錯誤] 編譯失敗
    pause
    exit /b 1
)

echo.
echo [2/3] 啟動應用程式進行連線測試...
echo 注意：如果連線成功，會看到 "後端 API 已啟動"
echo       如果連線失敗，會看到資料庫連線錯誤訊息
echo.

REM 執行應用程式（使用 Maven）
call mvn spring-boot:run

echo.
echo [3/3] 測試完成
pause

