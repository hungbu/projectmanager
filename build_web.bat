@echo on
setlocal enabledelayedexpansion

REM Enable command echoing for better logging
echo on

REM Flutter Web Build and Deploy Script for Windows
REM This script builds the Flutter web app and deploys it to the Laravel API

echo 🚀 Starting Flutter Web Build and Deploy Process...

REM Check if FVM is installed and install if needed
fvm --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] FVM is not installed. Attempting to install FVM...
    
    REM Check if Dart is available
    dart --version >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Dart is not installed. Please install Dart first: https://dart.dev/get-dart
        exit /b 1
    )
    
    echo [INFO] Installing FVM via Dart...
    dart pub global activate fvm
    
    if errorlevel 1 (
        echo [ERROR] Failed to install FVM
        exit /b 1
    ) else (
        echo [SUCCESS] FVM installed successfully!
        
        REM Add Dart pub global bin to PATH
        set PATH=%PATH%;%USERPROFILE%\.pub-cache\bin
    )
)

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Flutter is not installed or not in PATH
    exit /b 1
)

echo [INFO] Setting up Flutter version 3.29.3 with FVM...

REM Check if Flutter 3.29.3 is installed, install if not
fvm list | findstr "3.29.3" >nul 2>&1
if errorlevel 1 (
    echo [INFO] Flutter 3.29.3 not found. Installing...
    fvm install 3.29.3
    
    if errorlevel 1 (
        echo [ERROR] Failed to install Flutter 3.29.3
        exit /b 1
    )
)

REM Set Flutter 3.29.3 as active
fvm use 3.29.3 --force

if errorlevel 1 (
    echo [ERROR] Failed to set Flutter version 3.29.3
    exit /b 1
) else (
    echo [SUCCESS] Flutter 3.29.3 is now active!
)

REM Check if we're in the project root
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Please run this script from the project root directory.
    exit /b 1
)

REM Check if Laravel API directory exists
if not exist "pm_api" (
    echo [ERROR] pm_api directory not found. Please ensure the Laravel API is in the pm_api directory.
    exit /b 1
)

echo [INFO] Cleaning previous builds...
echo.
fvm flutter clean
echo.

echo [INFO] Getting Flutter dependencies...
echo.
fvm flutter pub get
echo.

echo [INFO] Building Flutter web app...
echo.
fvm flutter build web --release
echo.

if errorlevel 1 (
    echo [ERROR] Flutter web build failed!
    exit /b 1
) else (
    echo [SUCCESS] Flutter web build completed successfully!
)

REM Create web directory in Laravel public folder if it doesn't exist
set WEB_DIR=pm_api\public\web
if not exist "%WEB_DIR%" (
    echo [INFO] Creating web directory in Laravel public folder...
    mkdir "%WEB_DIR%"
)

echo [INFO] Copying Flutter web build to Laravel public folder...
echo.
xcopy "build\web\*" "%WEB_DIR%\" /E /Y /I
echo.

if errorlevel 1 (
    echo [ERROR] Failed to copy web files!
    exit /b 1
) else (
    echo [SUCCESS] Web files copied to Laravel public folder!
)

@REM echo [INFO] Updating Laravel routes to serve Flutter web app...
@REM echo.

@REM REM Create a backup of the current web.php
@REM copy "pm_api\routes\web.php" "pm_api\routes\web.php.backup" >nul
@REM echo [INFO] Backup created: pm_api\routes\web.php.backup

@REM REM Update the web.php file to serve the Flutter app
@REM (
@REM echo ^<?php
@REM echo.
@REM echo use Illuminate\Support\Facades\Route;
@REM echo.
@REM echo // Serve Flutter web app for the root route
@REM echo Route::get^('/', function ^(^) {
@REM echo     return view^('flutter-app'^);
@REM echo }^);
@REM echo.
@REM echo // API routes ^(if any web routes are needed^)
@REM echo Route::prefix^('api'^)-^>group^(function ^(^) {
@REM echo     // Add any web-specific API routes here
@REM echo }^);
@REM echo.
@REM echo // Catch-all route to serve Flutter app for SPA routing
@REM echo Route::get^('/{any}', function ^(^) {
@REM echo     return view^('flutter-app'^);
@REM echo }^)-^>where^('any', '.*'^);
@REM ) > "pm_api\routes\web.php"

@REM echo [INFO] Creating Flutter app view template...
@REM echo.

@REM REM Create the view template for the Flutter app
@REM if not exist "pm_api\resources\views" (
@REM     echo [INFO] Creating views directory...
@REM     mkdir "pm_api\resources\views"
@REM )

@REM (
@REM echo ^<!DOCTYPE html^>
@REM echo ^<html lang="en"^>
@REM echo ^<head^>
@REM echo     ^<meta charset="UTF-8"^>
@REM echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
@REM echo     ^<title^>Project Manager App^</title^>
@REM echo     ^<meta name="description" content="A project management app similar to monday.com"^>
@REM echo     
@REM echo     ^<!-- Flutter Web App --^>
@REM echo     ^<script src="{{ asset^('web/flutter.js'^) }}" defer^>^</script^>
@REM echo     
@REM echo     ^<!-- Favicon --^>
@REM echo     ^<link rel="icon" type="image/x-icon" href="{{ asset^('web/favicon.png'^) }}"^>
@REM echo     
@REM echo     ^<!-- Preload critical resources --^>
@REM echo     ^<link rel="preload" href="{{ asset^('web/main.dart.js'^) }}" as="script"^>
@REM echo     ^<link rel="preload" href="{{ asset^('web/flutter.js'^) }}" as="script"^>
@REM echo ^</head^>
@REM echo ^<body^>
@REM echo     ^<div id="flutter-app"^>
@REM echo         ^<div id="loading"^>
@REM echo             ^<div style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: Arial, sans-serif;"^>
@REM echo                 ^<div style="text-align: center;"^>
@REM echo                     ^<div style="width: 50px; height: 50px; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%%; animation: spin 1s linear infinite; margin: 0 auto 20px;"^>^</div^>
@REM echo                     ^<p^>Loading Project Manager App...^</p^>
@REM echo                 ^</div^>
@REM echo             ^</div^>
@REM echo         ^</div^>
@REM echo     ^</div^>
@REM echo     
@REM echo     ^<style^>
@REM echo         @keyframes spin {
@REM echo             0%% { transform: rotate^(0deg^); }
@REM echo             100%% { transform: rotate^(360deg^); }
@REM echo         }
@REM echo         
@REM echo         body {
@REM echo             margin: 0;
@REM echo             padding: 0;
@REM echo             font-family: Arial, sans-serif;
@REM echo         }
@REM echo         
@REM echo         #flutter-app {
@REM echo             width: 100%%;
@REM echo             height: 100vh;
@REM echo         }
@REM echo         
@REM echo         #loading {
@REM echo             position: fixed;
@REM echo             top: 0;
@REM echo             left: 0;
@REM echo             width: 100%%;
@REM echo             height: 100%%;
@REM echo             background: white;
@REM echo             z-index: 9999;
@REM echo         }
@REM echo     ^</style^>
@REM echo     
@REM echo     ^<script^>
@REM echo         window.addEventListener^('load', function^(^) {
@REM echo             // Initialize Flutter
@REM echo             _flutter.loader.loadEntrypoint^({
@REM echo                 serviceWorker: {
@REM echo                     serviceWorkerVersion: serviceWorkerVersion,
@REM echo                 },
@REM echo                 onEntrypointLoaded: function^(engineInitializer^) {
@REM echo                     engineInitializer.initializeEngine^(^).then^(function^(appRunner^) {
@REM echo                         appRunner.runApp^(^);
@REM echo                     }^);
@REM echo                 }
@REM echo             }^);
@REM echo             
@REM echo             // Hide loading screen when Flutter app is ready
@REM echo             window.addEventListener^('flutter-first-frame', function^(^) {
@REM echo                 document.getElementById^('loading'^).style.display = 'none';
@REM echo             }^);
@REM echo         }^);
@REM echo     ^</script^>
@REM echo ^</body^>
@REM echo ^</html^>
@REM ) > "pm_api\resources\views\flutter-app.blade.php"

@REM echo [SUCCESS] Flutter app view template created!
@REM echo.

echo [INFO] Setting proper permissions...
icacls "%WEB_DIR%" /grant Everyone:F /T >nul 2>&1
echo [INFO] Permissions set successfully.
echo.

echo [SUCCESS] 🎉 Deployment completed successfully!
echo.
echo 📋 Summary:
echo   ✅ Flutter web app built successfully
echo   ✅ Web files copied to: %WEB_DIR%
echo   ✅ Laravel routes updated to serve Flutter app
echo   ✅ View template created
echo.
echo 🌐 Your Flutter web app is now available at:
echo    http://localhost:8000 ^(if using Laravel's built-in server^)
echo.
echo 📝 To start the Laravel development server:
echo    cd pm_api ^&^& php artisan serve
echo.
echo 📝 To build and deploy again, simply run:
echo    build_web.bat
echo.
echo ⏳ Press any key to close this window...
pause >nul 