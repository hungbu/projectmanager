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

echo [INFO] Updating Laravel routes to serve Flutter web app...
echo.

REM Create a backup of the current web.php
copy "pm_api\routes\web.php" "pm_api\routes\web.php.backup" >nul
echo [INFO] Backup created: pm_api\routes\web.php.backup

REM Update the web.php file to serve the Flutter app
(
echo ^<?php
echo.
echo use Illuminate\Support\Facades\Route;
echo.
echo // Serve Flutter web app for the root route
echo Route::get^('/', function ^(^) {
echo     return view^('flutter-app'^);
echo }^);
echo.
echo // API routes ^(if any web routes are needed^)
echo Route::prefix^('api'^)-^>group^(function ^(^) {
echo     // Add any web-specific API routes here
echo }^);
echo.
echo // Catch-all route to serve Flutter app for SPA routing
echo Route::get^('/{any}', function ^(^) {
echo     return view^('flutter-app'^);
echo }^)-^>where^('any', '.*'^);
) > "pm_api\routes\web.php"

echo [INFO] Creating Flutter app view template...
echo.

REM Create the view template for the Flutter app
if not exist "pm_api\resources\views" (
    echo [INFO] Creating views directory...
    mkdir "pm_api\resources\views"
)

(
echo ^<!DOCTYPE html^>
echo ^<html lang="en"^>
echo ^<head^>
echo     ^<meta charset="UTF-8"^>
echo     ^<meta name="viewport" content="width=device-width, initial-scale=1.0"^>
echo     ^<title^>Project Manager App^</title^>
echo     ^<meta name="description" content="A project management app similar to monday.com"^>
echo     
echo     ^<!-- Flutter Web App --^>
echo     ^<script src="{{ asset^('web/flutter.js'^) }}" defer^>^</script^>
echo     
echo     ^<!-- Favicon --^>
echo     ^<link rel="icon" type="image/x-icon" href="{{ asset^('web/favicon.png'^) }}"^>
echo     
echo     ^<!-- Preload critical resources --^>
echo     ^<link rel="preload" href="{{ asset^('web/main.dart.js'^) }}" as="script"^>
echo     ^<link rel="preload" href="{{ asset^('web/flutter.js'^) }}" as="script"^>
echo ^</head^>
echo ^<body^>
echo     ^<div id="flutter-app"^>
echo         ^<div id="loading"^>
echo             ^<div style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: Arial, sans-serif;"^>
echo                 ^<div style="text-align: center;"^>
echo                     ^<div style="width: 50px; height: 50px; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%%; animation: spin 1s linear infinite; margin: 0 auto 20px;"^>^</div^>
echo                     ^<p^>Loading Project Manager App...^</p^>
echo                 ^</div^>
echo             ^</div^>
echo         ^</div^>
echo     ^</div^>
echo     
echo     ^<style^>
echo         @keyframes spin {
echo             0%% { transform: rotate^(0deg^); }
echo             100%% { transform: rotate^(360deg^); }
echo         }
echo         
echo         body {
echo             margin: 0;
echo             padding: 0;
echo             font-family: Arial, sans-serif;
echo         }
echo         
echo         #flutter-app {
echo             width: 100%%;
echo             height: 100vh;
echo         }
echo         
echo         #loading {
echo             position: fixed;
echo             top: 0;
echo             left: 0;
echo             width: 100%%;
echo             height: 100%%;
echo             background: white;
echo             z-index: 9999;
echo         }
echo     ^</style^>
echo     
echo     ^<script^>
echo         window.addEventListener^('load', function^(^) {
echo             // Initialize Flutter
echo             _flutter.loader.loadEntrypoint^({
echo                 serviceWorker: {
echo                     serviceWorkerVersion: serviceWorkerVersion,
echo                 },
echo                 onEntrypointLoaded: function^(engineInitializer^) {
echo                     engineInitializer.initializeEngine^(^).then^(function^(appRunner^) {
echo                         appRunner.runApp^(^);
echo                     }^);
echo                 }
echo             }^);
echo             
echo             // Hide loading screen when Flutter app is ready
echo             window.addEventListener^('flutter-first-frame', function^(^) {
echo                 document.getElementById^('loading'^).style.display = 'none';
echo             }^);
echo         }^);
echo     ^</script^>
echo ^</body^>
echo ^</html^>
) > "pm_api\resources\views\flutter-app.blade.php"

echo [SUCCESS] Flutter app view template created!
echo.

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