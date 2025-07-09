# Flutter Web Deployment to Laravel API

This guide explains how to build your Flutter web app and deploy it to your Laravel API homepage.

## 📋 Prerequisites

- **Dart SDK** installed and in PATH (required for FVM installation)
- **Flutter SDK** installed and in PATH
- **Laravel API** in the `pm_api` directory
- **PHP and Composer** installed (for Laravel)

### Automatic Installation

The build scripts will automatically:
1. **Install FVM** if not present (using `dart pub global activate fvm`)
2. **Install Flutter 3.29.3** if not present (using `fvm install 3.29.3`)
3. **Set Flutter 3.29.3 as active** for the build process

### Manual Installation (if needed)

**Windows (PowerShell):**
```powershell
winget install leoafarias.fvm
```

**macOS:**
```bash
brew tap leoafarias/fvm
brew install fvm
```

**Linux:**
```bash
dart pub global activate fvm
```

**Manual Installation:**
Visit [FVM Installation Guide](https://fvm.app/docs/getting_started/installation) for detailed instructions.

## 🚀 Quick Start

### For Windows Users:

**Option 1: PowerShell (Recommended)**
```powershell
.\build_web.ps1
```

**Option 2: Batch File**
```cmd
build_web.bat
```

### For Linux/Mac Users:
```bash
chmod +x build_web.sh
./build_web.sh
```

## 📁 What the Scripts Do

The deployment scripts perform the following steps:

1. **Check and Install FVM**: Verifies FVM is installed, installs if missing
2. **Check and Install Flutter 3.29.3**: Verifies Flutter 3.29.3 is installed, installs if missing
3. **Set Flutter Version**: Uses FVM to set Flutter version 3.29.3 as active
4. **Clean Previous Builds**: Removes old build artifacts
5. **Get Dependencies**: Runs `fvm flutter pub get`
6. **Build Web App**: Creates optimized web build with `fvm flutter build web --release`
7. **Copy to Laravel**: Copies web files to `pm_api/public/web/`
8. **Update Routes**: Modifies `pm_api/routes/web.php` to serve the Flutter app
9. **Create View Template**: Generates `pm_api/resources/views/flutter-app.blade.php`
10. **Set Permissions**: Ensures proper file permissions

## 🌐 Accessing Your App

After running the deployment script:

1. **Start Laravel Server**:
   ```bash
   cd pm_api
   php artisan serve
   ```

2. **Access Your App**:
   - Open browser to `http://localhost:8000`
   - Your Flutter web app will be served from the Laravel homepage

## 📂 File Structure After Deployment

```
projectmanager/
├── build/web/                    # Flutter web build output
├── pm_api/
│   ├── public/
│   │   └── web/                  # Deployed Flutter web files
│   ├── resources/
│   │   └── views/
│   │       └── flutter-app.blade.php  # Laravel view template
│   └── routes/
│       └── web.php               # Updated routes
└── build_web.sh                  # Deployment script
```

## 🔧 Manual Steps (if needed)

If you prefer to run the steps manually:

### 1. Build Flutter Web
```bash
fvm use 3.29.3 --force
fvm flutter clean
fvm flutter pub get
fvm flutter build web --release
```

### 2. Copy Files
```bash
mkdir -p pm_api/public/web
cp -r build/web/* pm_api/public/web/
```

### 3. Update Laravel Routes
Edit `pm_api/routes/web.php`:
```php
<?php

use Illuminate\Support\Facades\Route;

// Serve Flutter web app for the root route
Route::get('/', function () {
    return view('flutter-app');
});

// API routes (if any web routes are needed)
Route::prefix('api')->group(function () {
    // Add any web-specific API routes here
});

// Catch-all route to serve Flutter app for SPA routing
Route::get('/{any}', function () {
    return view('flutter-app');
})->where('any', '.*');
```

### 4. Create View Template
Create `pm_api/resources/views/flutter-app.blade.php` with the HTML template provided in the scripts.

## 🔄 Rebuilding

To rebuild and redeploy after making changes:

1. **Run the deployment script again** (it will overwrite previous builds)
2. **Restart Laravel server** if needed:
   ```bash
   cd pm_api
   php artisan serve
   ```

## 🐛 Troubleshooting

### Common Issues:

1. **Dart not found**:
   - Ensure Dart SDK is installed and in PATH
   - Run `dart --version` to verify installation
   - Install Dart: https://dart.dev/get-dart

2. **FVM installation failed**:
   - Ensure Dart is installed first
   - Try manual installation: `dart pub global activate fvm`
   - Check PATH includes `$HOME/.pub-cache/bin` (Linux/Mac) or `%USERPROFILE%\.pub-cache\bin` (Windows)

3. **Flutter installation failed**:
   - Check internet connection for downloading Flutter
   - Try manual installation: `fvm install 3.29.3`
   - Verify disk space is available

2. **Permission denied**:
   - On Windows: Run PowerShell as Administrator
   - On Linux/Mac: Use `sudo` or check file permissions

3. **Laravel server not starting**:
   - Check if PHP is installed: `php --version`
   - Install Laravel dependencies: `cd pm_api && composer install`

4. **Web app not loading**:
   - Check browser console for errors
   - Verify files are copied to `pm_api/public/web/`
   - Check Laravel logs: `cd pm_api && php artisan log:clear`

### Debug Mode

To build in debug mode for development:
```bash
fvm flutter build web --debug
```

## 📝 Configuration

### Custom Build Options

You can modify the build command in the scripts:

- **Release build** (default): `fvm flutter build web --release`
- **Debug build**: `fvm flutter build web --debug`
- **Profile build**: `fvm flutter build web --profile`

### Custom Deployment Path

To deploy to a different directory, modify the `WEB_DIR` variable in the scripts.

## 🔒 Security Notes

- The scripts create backups of `web.php` as `web.php.backup`
- File permissions are set to allow web server access
- Consider using `.htaccess` rules for additional security

## 📚 Additional Resources

- [Flutter Web Documentation](https://docs.flutter.dev/web)
- [Laravel Blade Templates](https://laravel.com/docs/blade)
- [Laravel Routing](https://laravel.com/docs/routing)

## 🤝 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Verify all prerequisites are met
3. Check Laravel and Flutter logs
4. Ensure file permissions are correct

---

**Happy Deploying! 🚀** 