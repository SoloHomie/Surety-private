# ── Surety Installer 打包脚本 ───────────────────────
# 1. 编译 Release 版本
# 2. windeployqt 收集依赖
# 3. binarycreator 打包安装包

param(
    [string]$Version = "1.0.0",
    [string]$QtDir = "C:\Qt\6.11.1\msvc2022_64",
    [string]$IFWDir = "C:\Qt\Tools\QtInstallerFramework\4.11"
)

$ErrorActionPreference = "Stop"
$Root = "D:\Dev-Cpp\Surety"
$BuildDir = "$Root\x64\Release"
$PkgDir = "$Root\installer\packages\com.surety.app\data"
$MetaDir = "$Root\installer\packages\com.surety.app\meta"
$ConfigDir = "$Root\installer\config"
$Output = "$Root\installer\Surety-$Version-win64.exe"

Write-Host "=== 1. 编译 Release ===" -ForegroundColor Cyan
& "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe" "$Root\Surety.vcxproj" /p:Configuration=Release /p:Platform=x64 /m

Write-Host "=== 2. 更新版本号 ===" -ForegroundColor Cyan
$pkgXml = "$MetaDir\package.xml"
(Get-Content $pkgXml) -replace '<Version>.*</Version>', "<Version>$Version</Version>" | Set-Content $pkgXml
$cfgXml = "$ConfigDir\config.xml"
(Get-Content $cfgXml) -replace '<Version>.*</Version>', "<Version>$Version</Version>" | Set-Content $cfgXml

Write-Host "=== 3. windeployqt 收集 Qt 依赖 ===" -ForegroundColor Cyan
Remove-Item -Recurse -Force $PkgDir -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $PkgDir | Out-Null
Copy-Item "$BuildDir\Surety.exe" $PkgDir -Force
& "$QtDir\bin\windeployqt.exe" "$PkgDir\Surety.exe" --qmldir "$Root\qml" --no-translations

Write-Host "=== 4. 额外资源 ===" -ForegroundColor Cyan
# 可选: 复制 VC++ 运行时
# Copy-Item "C:\Program Files\Microsoft Visual Studio\18\Community\VC\Redist\MSVC\*\x64\*.dll" $PkgDir

Write-Host "=== 5. 打包安装包 ===" -ForegroundColor Cyan
Remove-Item $Output -ErrorAction SilentlyContinue
& "$IFWDir\bin\binarycreator.exe" --offline-only -c "$ConfigDir\config.xml" -p "$Root\installer\packages" $Output

Write-Host "=== 完成: $Output ===" -ForegroundColor Green
