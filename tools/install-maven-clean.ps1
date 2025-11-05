<#
.SYNOPSIS
  安裝 Apache Maven（優先使用 Chocolatey，其次 Scoop，否則自動下載並設定到使用者 PATH）

.NOTES
  - 在使用 Chocolatey 安裝時可能需要以系統管理員權限執行 PowerShell。
  - 若要在非互動環境執行，請以 PowerShell 7+ 或 Windows PowerShell 執行此腳本。
  - 這個腳本會修改使用者層級的 PATH（不需要 admin），但若使用 choco 會改變系統環境變數（可能需要 admin）。

USAGE
  在 PowerShell 中執行：
    .\tools\install-maven-clean.ps1

#>

param(
    [switch]$ForceDownload
)

function Write-Info($m) { Write-Host "[INFO] $m" -ForegroundColor Cyan }
function Write-Err($m) { Write-Host "[ERROR] $m" -ForegroundColor Red }

Write-Info "檢查是否已安裝 mvn..."
try {
    & mvn -version 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Info "已偵測到 mvn，可用："
        & mvn -version
        return
    }
} catch {
    # 忽略
}

Write-Info "嘗試使用 Chocolatey 安裝 Maven（若系統已安裝 Chocolatey）..."
try {
    $choco = Get-Command choco -ErrorAction SilentlyContinue
    if ($choco) {
        Write-Info "使用 choco 安裝 maven...（可能需要 admin）"
        choco install maven -y
        Write-Info "安裝完成，重新載入環境變數並驗證..."
        & mvn -version
        if ($LASTEXITCODE -eq 0) { Write-Info "Maven 安裝成功！"; return }
    } else {
        Write-Info "Chocolatey 未安裝，接下來嘗試 Scoop..."
    }
} catch {
    Write-Err "透過 Chocolatey 安裝失敗： $_"
}

try {
    $scoop = Get-Command scoop -ErrorAction SilentlyContinue
    if ($scoop) {
        Write-Info "使用 scoop 安裝 maven..."
        scoop install maven
        & mvn -version
        if ($LASTEXITCODE -eq 0) { Write-Info "Maven 安裝成功（scoop）！"; return }
    } else {
        Write-Info "Scoop 未安裝，將使用自動下載方式安裝 Apache Maven 到使用者目錄。"
    }
} catch {
    Write-Err "透過 Scoop 安裝失敗： $_"
}

# 若都沒有 choco 或 scoop，下載 Apache Maven 並設定 PATH（user scope）
$mavenVersion = '3.9.6'
$baseUrl = "https://dlcdn.apache.org/maven/maven-3/$mavenVersion/binaries"
$zipName = "apache-maven-$mavenVersion-bin.zip"
$downloadUrl = "$baseUrl/$zipName"
$installDir = Join-Path $env:USERPROFILE "tools\\apache-maven-$mavenVersion"

if (-not (Test-Path $installDir) -or $ForceDownload) {
    Write-Info "下載 Apache Maven $mavenVersion..."
    $tmp = Join-Path $env:TEMP $zipName
    if (Test-Path $tmp) { Remove-Item $tmp -Force }
    try {
        Invoke-WebRequest -Uri $downloadUrl -OutFile $tmp -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-Err "無法下載 Maven，請檢查網路或手動下載： $downloadUrl`n錯誤：$_"
        exit 1
    }

    Write-Info "解壓縮到 $installDir ..."
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
    try {
        Expand-Archive -Path $tmp -DestinationPath (Split-Path $installDir -Parent) -Force
        # 下載的 zip 會解出 apache-maven-<version> 資料夾
        if (Test-Path (Join-Path (Split-Path $installDir -Parent) "apache-maven-$mavenVersion")) {
            Move-Item -Path (Join-Path (Split-Path $installDir -Parent) "apache-maven-$mavenVersion") -Destination $installDir -Force
        }
    } catch {
        Write-Err "解壓縮失敗： $_"
        exit 1
    }
}

$mavenBin = Join-Path $installDir 'bin'
Write-Info "將 Maven 加入使用者 PATH（持久化）..."
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($currentPath -notlike "*${mavenBin}*") {
    $newPath = "$currentPath;$mavenBin"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Info "已更新使用者 PATH（新加入 $mavenBin）。請重新開啟您的終端以使變更生效。"
    $cmd = '$env:Path += ";' + $mavenBin + '"'
    Write-Info "要在當前會話生效，執行： $cmd"
} else {
    Write-Info "使用者 PATH 已包含 Maven。"
}

Write-Info "驗證 mvn..."
try {
    & mvn -version
    if ($LASTEXITCODE -eq 0) { Write-Info "Maven 安裝與驗證成功！"; exit 0 }
} catch {
    Write-Err "驗證失敗，請重開終端後再試： mvn -version"
    exit 1
}
