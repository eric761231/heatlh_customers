# PowerShell 腳本：下載 Maven 依賴
# 如果 Maven 已安裝，使用此腳本下載依賴

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "下載 Java 後端依賴" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 檢查 Maven 是否可用
$mvnAvailable = $false
try {
    $mvnVersion = mvn -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $mvnAvailable = $true
        Write-Host "[✓] Maven 已安裝" -ForegroundColor Green
        Write-Host $mvnVersion[0] -ForegroundColor Gray
    }
} catch {
    $mvnAvailable = $false
}

if (-not $mvnAvailable) {
    Write-Host "[✗] Maven 未安裝或未加入 PATH" -ForegroundColor Red
    Write-Host ""
    Write-Host "請選擇以下方式之一：" -ForegroundColor Yellow
    Write-Host "1. 安裝 Maven（參考 INSTALL_MAVEN.md）" -ForegroundColor Yellow
    Write-Host "2. 在 VS Code 中安裝 'Extension Pack for Java' 擴充功能" -ForegroundColor Yellow
    Write-Host "3. 使用 IDE（如 IntelliJ IDEA）自動下載依賴" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "詳細說明請參考：VSCODE_SETUP.md" -ForegroundColor Cyan
    exit 1
}

# 檢查是否在正確的目錄
if (-not (Test-Path "pom.xml")) {
    Write-Host "[✗] 找不到 pom.xml，請在 java-backend 目錄中執行此腳本" -ForegroundColor Red
    exit 1
}

# 建立 lib 目錄（如果不存在）
if (-not (Test-Path "lib")) {
    New-Item -ItemType Directory -Path "lib" | Out-Null
    Write-Host "[✓] 已建立 lib 目錄" -ForegroundColor Green
}

# 下載依賴
Write-Host ""
Write-Host "[1/2] 正在下載依賴..." -ForegroundColor Yellow
Write-Host "這可能需要幾分鐘時間，請稍候..." -ForegroundColor Gray
Write-Host ""

mvn dependency:copy-dependencies -DoutputDirectory=lib

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "[2/2] 檢查下載結果..." -ForegroundColor Yellow
    
    $jarCount = (Get-ChildItem -Path "lib" -Filter "*.jar" -ErrorAction SilentlyContinue).Count
    
    if ($jarCount -gt 0) {
        Write-Host "[✓] 成功下載 $jarCount 個 JAR 檔案" -ForegroundColor Green
        Write-Host ""
        Write-Host "下一步：" -ForegroundColor Cyan
        Write-Host "1. 設定資料庫密碼（application.properties）" -ForegroundColor White
        Write-Host "2. 編譯專案：ant compile" -ForegroundColor White
        Write-Host "3. 執行應用程式：mvn spring-boot:run" -ForegroundColor White
    } else {
        Write-Host "[✗] 未找到 JAR 檔案，下載可能失敗" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host ""
    Write-Host "[✗] 下載失敗，請檢查錯誤訊息" -ForegroundColor Red
    exit 1
}

Write-Host ""


