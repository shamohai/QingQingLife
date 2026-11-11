# Temporary compatibility patch for Umeng plugins on Gradle 9 / AGP 9.
# Remove after the upstream packages publish compatible Android build scripts.
$ErrorActionPreference = 'Stop'

$packageDir = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev\umeng_common_sdk-1.3.1'
$buildFile = Join-Path $packageDir 'android\build.gradle'
$templateKotlinFile = Join-Path $packageDir 'android\src\main\kotlin\com\umeng\umeng_common_sdk\UmengCommonSdkPlugin.kt'
$pushPackageDir = Join-Path $env:LOCALAPPDATA 'Pub\Cache\hosted\pub.dev\umeng_push_sdk-2.4.0'
$pushBuildFile = Join-Path $pushPackageDir 'android\build.gradle'
$pushProguardFile = Join-Path $pushPackageDir 'android\proguard-rules.pro'

if (-not (Test-Path -LiteralPath $buildFile)) {
    throw "umeng_common_sdk 1.3.1 is missing. Run flutter pub get first."
}

if (Test-Path -LiteralPath $templateKotlinFile) {
    Remove-Item -LiteralPath $templateKotlinFile -Force
    Write-Output "Removed duplicate Kotlin plugin stub $templateKotlinFile"
}

if ((Test-Path -LiteralPath (Split-Path -Parent $pushProguardFile)) -and
    -not (Test-Path -LiteralPath $pushProguardFile)) {
    Set-Content -LiteralPath $pushProguardFile -Value '' -NoNewline
    Write-Output "Created missing push ProGuard file $pushProguardFile"
}

if (Test-Path -LiteralPath $pushBuildFile) {
    $pushContent = Get-Content -Raw -LiteralPath $pushBuildFile
    $pushPatched = $pushContent `
        -replace 'compileSdkVersion 33', 'compileSdk = 37' `
        -replace 'targetSdkVersion 33', 'targetSdk = 33' `
        -replace 'minSdkVersion 21', 'minSdk = 21'

    if ($pushPatched -ne $pushContent) {
        Set-Content -LiteralPath $pushBuildFile -Value $pushPatched -NoNewline
        Write-Output "Patched $pushBuildFile"
    } else {
        Write-Output "Already patched $pushBuildFile"
    }
}

$content = Get-Content -Raw -LiteralPath $buildFile
$patched = $content `
    -replace "(?ms)^buildscript \{.*?^\}\r?\n\r?\n", '' `
    -replace "(?ms)^rootProject\.allprojects \{.*?^\}\r?\n\r?\n", '' `
    -replace 'compileSdkVersion 33', 'compileSdk = 37' `
    -replace 'minSdkVersion 21', 'minSdk = 21' `
    -replace "(?ms)lintOptions \{\r?\n\s*disable 'InvalidPackage'\r?\n\s*\}", "lint {`n        disable += 'InvalidPackage'`n    }"

if ($patched -notmatch '(?m)^\s*compileOptions\s*\{') {
    $compileOptions = @"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = '17'
    }
"@
    $patched = $patched -replace '(?m)^(android\s*\{)', "`$1$compileOptions"
}

if ($patched -match 'jcenter\(\)|com\.android\.tools\.build:gradle:7\.3\.0') {
    throw 'Failed to remove incompatible Umeng Gradle configuration.'
}

if ($patched -ne $content) {
    Set-Content -LiteralPath $buildFile -Value $patched -NoNewline
    Write-Output "Patched $buildFile"
} else {
    Write-Output "Already patched $buildFile"
}
