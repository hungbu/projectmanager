# Flutter Web Build and Deploy Script for Windows PowerShell
# This script builds the Flutter web app and deploys it to the Laravel API

Write-Host " Starting Flutter Web Build and Deploy Process..." -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if FVM is installed and install if needed
try {
    $fvmVersion = fvm --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "FVM not found"
    }
} catch {
    Write-Warning "FVM is not installed. Attempting to install FVM..."
    
    # Check if Dart is available
    try {
        $dartVersion = dart --version 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Dart not found"
        }
    } catch {
        Write-Error "Dart is not installed. Please install Dart first: https://dart.dev/get-dart"
        exit 1
    }
    
    Write-Status "Installing FVM via Dart..."
    dart pub global activate fvm
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "FVM installed successfully!"
        
        # Add Dart pub global bin to PATH
        #$env:PATH += ";$env:USERPROFILE\.pub-cache\bin"
    } else {
        Write-Error "Failed to install FVM"
        exit 1
    }
}

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Flutter not found"
    }
} catch {
    Write-Error "Flutter is not installed or not in PATH"
    exit 1
}

Write-Status "Setting up Flutter version 3.29.3 with FVM..."

# Check if Flutter 3.29.3 is installed, install if not
try {
    $flutterVersions = fvm list 2>$null
    if ($flutterVersions -notmatch "3.29.3") {
        Write-Status "Flutter 3.29.3 not found. Installing..."
        fvm install 3.29.3
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to install Flutter 3.29.3"
            exit 1
        }
    }
} catch {
    Write-Status "Flutter 3.29.3 not found. Installing..."
    fvm install 3.29.3
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to install Flutter 3.29.3"
        exit 1
    }
}

# Set Flutter 3.29.3 as active
fvm use 3.29.3 --force

if ($LASTEXITCODE -eq 0) {
    Write-Success "Flutter 3.29.3 is now active!"
} else {
    Write-Error "Failed to set Flutter version 3.29.3"
    exit 1
}

# Check if we're in the project root
if (-not (Test-Path "pubspec.yaml")) {
    Write-Error "pubspec.yaml not found. Please run this script from the project root directory."
    exit 1
}

# Check if Laravel API directory exists
if (-not (Test-Path "pm_api")) {
    Write-Error "pm_api directory not found. Please ensure the Laravel API is in the pm_api directory."
    exit 1
}

Write-Status "Cleaning previous builds..."
Write-Host ""
fvm flutter clean
Write-Host ""

Write-Status "Getting Flutter dependencies..."
Write-Host ""
fvm flutter pub get
Write-Host ""

Write-Status "Building Flutter web app..."
Write-Host ""
fvm flutter build web --release
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Success "Flutter web build completed successfully!"
} else {
    Write-Error "Flutter web build failed!"
    exit 1
}

# Create web directory in Laravel public folder if it doesn't exist
$WEB_DIR = "pm_api\public"
if (-not (Test-Path $WEB_DIR)) {
    Write-Status "Creating web directory in Laravel public folder..."
    New-Item -ItemType Directory -Path $WEB_DIR -Force | Out-Null
}

Write-Status "Copying Flutter web build to Laravel public folder..."
Write-Host ""
Copy-Item -Path "build\web\*" -Destination $WEB_DIR -Recurse -Force
Write-Host ""

if ($LASTEXITCODE -eq 0) {
    Write-Success "Web files copied to Laravel public folder!"
} else {
    Write-Error "Failed to copy web files!"
    exit 1
}


Write-Status "Creating Flutter app view template..."
Write-Host ""

# Create the view template for the Flutter app
$viewsDir = "pm_api\resources\views"
if (-not (Test-Path $viewsDir)) {
    Write-Status "Creating views directory..."
    New-Item -ItemType Directory -Path $viewsDir -Force | Out-Null
}

$flutterAppTemplate = @'
<!DOCTYPE html>
<html>
<head>
  <base href="/">

  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Project Manager is a web application for managing projects, tasks, and teams.">

  <!-- iOS meta tags & icons -->
  <meta name="mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Project Manager">
  <link rel="apple-touch-icon" href="{{ asset('icons/Icon-192.png') }}">

  <!-- Favicon -->
  <link rel="icon" type="image/png" href="{{ asset('favicon.png') }}"/>

  <title>Project Manager</title>
  <link rel="manifest" href="{{ asset('manifest.json') }}">
</head>
<body>
  <script src="{{ asset('flutter_bootstrap.js') }}" async></script>
</body>
</html>
'@

Set-Content -Path "pm_api\resources\views\flutter-app.blade.php" -Value $flutterAppTemplate

Write-Success "Flutter app view template created!"
Write-Host ""

Write-Status "Setting proper permissions..."
try {
    $acl = Get-Acl $WEB_DIR
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","FullControl","ContainerInherit,ObjectInherit","None","Allow")
    $acl.SetAccessRule($accessRule)
    Set-Acl $WEB_DIR $acl
    Write-Status "Permissions set successfully."
} catch {
    Write-Warning "Could not set permissions automatically. You may need to set them manually."
}
Write-Host ""

Write-Success " Deployment completed successfully!"
Write-Host ""
Write-Host " Summary:" -ForegroundColor Cyan
Write-Host "   Flutter web app built successfully" -ForegroundColor Green
Write-Host "   Web files copied to: $WEB_DIR" -ForegroundColor Green
Write-Host "   Laravel routes updated to serve Flutter app" -ForegroundColor Green
Write-Host "   View template created" -ForegroundColor Green
Write-Host ""
Write-Host " Your Flutter web app is now available at:" -ForegroundColor Cyan
Write-Host ""
Write-Host " To start the Laravel development server:" -ForegroundColor Cyan
Write-Host "   cd pm_api && php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host " To build and deploy again, simply run:" -ForegroundColor Cyan
Write-Host "  .\build_web.ps1" -ForegroundColor White
Write-Host ""
Write-Host " Press any key to close this window..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")