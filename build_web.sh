#!/bin/bash

# Flutter Web Build and Deploy Script
# This script builds the Flutter web app and deploys it to the Laravel API

echo "🚀 Starting Flutter Web Build and Deploy Process..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if FVM is installed and install if needed
if ! command -v fvm &> /dev/null; then
    print_warning "FVM is not installed. Attempting to install FVM..."
    
    # Check if Dart is available
    if ! command -v dart &> /dev/null; then
        print_error "Dart is not installed. Please install Dart first: https://dart.dev/get-dart"
        exit 1
    fi
    
    print_status "Installing FVM via Dart..."
    dart pub global activate fvm
    
    if [ $? -eq 0 ]; then
        print_success "FVM installed successfully!"
        
        # Add Dart pub global bin to PATH if not already there
        if [[ ":$PATH:" != *":$HOME/.pub-cache/bin:"* ]]; then
            export PATH="$PATH:$HOME/.pub-cache/bin"
        fi
    else
        print_error "Failed to install FVM"
        exit 1
    fi
fi

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

print_status "Setting up Flutter version 3.29.3 with FVM..."

# Check if Flutter 3.29.3 is installed, install if not
if ! fvm list | grep -q "3.29.3"; then
    print_status "Flutter 3.29.3 not found. Installing..."
    fvm install 3.29.3
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install Flutter 3.29.3"
        exit 1
    fi
fi

# Set Flutter 3.29.3 as active
fvm use 3.29.3 --force

if [ $? -eq 0 ]; then
    print_success "Flutter 3.29.3 is now active!"
else
    print_error "Failed to set Flutter version 3.29.3"
    exit 1
fi

# Check if we're in the project root
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root directory."
    exit 1
fi

# Check if Laravel API directory exists
if [ ! -d "pm_api" ]; then
    print_error "pm_api directory not found. Please ensure the Laravel API is in the pm_api directory."
    exit 1
fi

print_status "Cleaning previous builds..."
echo ""
fvm flutter clean
echo ""

print_status "Getting Flutter dependencies..."
echo ""
fvm flutter pub get
echo ""

print_status "Building Flutter web app..."
echo ""
fvm flutter build web --release
echo ""

if [ $? -eq 0 ]; then
    print_success "Flutter web build completed successfully!"
else
    print_error "Flutter web build failed!"
    exit 1
fi

# Create web directory in Laravel public folder if it doesn't exist
WEB_DIR="pm_api/public/web"
if [ ! -d "$WEB_DIR" ]; then
    print_status "Creating web directory in Laravel public folder..."
    mkdir -p "$WEB_DIR"
fi

print_status "Copying Flutter web build to Laravel public folder..."
echo ""

# Check if build/web directory exists
if [ ! -d "build/web" ]; then
    print_error "build/web directory not found. Build may have failed."
    exit 1
fi

# Copy all files from build/web to Laravel public/web
cp -r build/web/* "$WEB_DIR/"

# Check if main.dart.js exists (newer Flutter versions)
if [ ! -f "$WEB_DIR/main.dart.js" ]; then
    print_warning "main.dart.js not found. Checking for alternative structure..."
    # Look for the main entry point in the build directory
    if [ -f "$WEB_DIR/index.html" ]; then
        print_success "Found index.html, build structure looks correct."
    else
        print_error "No index.html found in build output. Build may have failed."
        exit 1
    fi
fi

echo ""

if [ $? -eq 0 ]; then
    print_success "Web files copied to Laravel public folder!"
else
    print_error "Failed to copy web files!"
    exit 1
fi

print_status "Updating Laravel routes to serve Flutter web app..."
echo ""

# Create a backup of the current web.php
cp pm_api/routes/web.php pm_api/routes/web.php.backup
print_status "Backup created: pm_api/routes/web.php.backup"

# Update the web.php file to serve the Flutter app
cat > pm_api/routes/web.php << 'EOF'
<?php

use Illuminate\Support\Facades\Route;

// Serve Flutter static files with correct MIME types (must come before catch-all)
Route::get('/web/{file}', function ($file) {
    $path = public_path("web/{$file}");
    if (file_exists($path)) {
        $extension = pathinfo($file, PATHINFO_EXTENSION);
        $mimeType = match($extension) {
            'js' => 'application/javascript',
            'css' => 'text/css',
            'png', 'jpg', 'jpeg', 'gif', 'ico' => 'image/' . $extension,
            'json' => 'application/json',
            'wasm' => 'application/wasm',
            'html' => 'text/html',
            default => 'text/plain'
        };
        
        return response()->file($path, [
            'Content-Type' => $mimeType,
            'Cache-Control' => 'public, max-age=31536000'
        ]);
    }
    return response('File not found', 404);
})->where('file', '.*');

// Serve Flutter service worker
Route::get('/flutter_service_worker.js', function () {
    $path = public_path('web/flutter_service_worker.js');
    if (file_exists($path)) {
        return response()->file($path, [
            'Content-Type' => 'application/javascript',
            'Cache-Control' => 'public, max-age=31536000'
        ]);
    }
    return response('Service worker not found', 404);
});

// Serve Flutter web app for the root route
Route::get('/', function () {
    return view('flutter-app');
});

// API routes (if any web routes are needed)
Route::prefix('api')->group(function () {
    // Add any web-specific API routes here
});

// Catch-all route to serve Flutter app for SPA routing (must be last)
Route::get('/{any}', function () {
    return view('flutter-app');
})->where('any', '.*');
EOF

print_status "Creating Flutter app view template..."
echo ""

# Create the view template for the Flutter app
if [ ! -d "pm_api/resources/views" ]; then
    print_status "Creating views directory..."
    mkdir -p pm_api/resources/views
fi
cat > pm_api/resources/views/flutter-app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Project Manager App</title>
    <meta name="description" content="A project management app similar to monday.com">
    
    <!-- Favicon -->
    <link rel="icon" type="image/x-icon" href="/web/favicon.png">
    
    <!-- Preload critical resources -->
    <link rel="preload" href="/web/main.dart.js" as="script">
    <link rel="preload" href="/web/flutter.js" as="script">
    <link rel="preload" href="/web/flutter_bootstrap.js" as="script">
</head>
<body>
    <div id="flutter-app">
        <div id="loading">
            <div style="display: flex; justify-content: center; align-items: center; height: 100vh; font-family: Arial, sans-serif;">
                <div style="text-align: center;">
                    <div style="width: 50px; height: 50px; border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; animation: spin 1s linear infinite; margin: 0 auto 20px;"></div>
                    <p>Loading Project Manager App...</p>
                </div>
            </div>
        </div>
    </div>
    
    <style>
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        body {
            margin: 0;
            padding: 0;
            font-family: Arial, sans-serif;
        }
        
        #flutter-app {
            width: 100%;
            height: 100vh;
        }
        
        #loading {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: white;
            z-index: 9999;
        }
    </style>
    
    <!-- Load Flutter bootstrap script which handles initialization -->
    <script src="/web/flutter_bootstrap.js"></script>
    
    <script>
        window.addEventListener('load', function() {
            // Hide loading screen when Flutter app is ready
            window.addEventListener('flutter-first-frame', function() {
                document.getElementById('loading').style.display = 'none';
            });
        });
    </script>
</body>
</html>
EOF

print_success "Flutter app view template created!"
echo ""

print_status "Setting proper permissions..."
chmod -R 755 "$WEB_DIR"
print_status "Permissions set successfully."

# Copy .htaccess file for proper MIME types
print_status "Setting up .htaccess for proper MIME types..."
cp pm_api/public/web/.htaccess "$WEB_DIR/" 2>/dev/null || print_warning ".htaccess file not found, MIME types may not be correct"
echo ""

print_success "🎉 Deployment completed successfully!"
echo ""
echo "📋 Summary:"
echo "  ✅ Flutter web app built successfully"
echo "  ✅ Web files copied to: $WEB_DIR"
echo "  ✅ Laravel routes updated to serve Flutter app"
echo "  ✅ View template created"
echo ""
echo "🌐 Your Flutter web app is now available at:"
echo "   http://localhost:8000 (if using Laravel's built-in server)"
echo ""
echo "📝 To start the Laravel development server:"
echo "   cd pm_api && php artisan serve"
echo ""
echo "📝 To build and deploy again, simply run:"
echo "   ./build_web.sh" 