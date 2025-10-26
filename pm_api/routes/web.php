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

// Catch-all route to serve Flutter app for SPA routing (must be last)
// NOTE: All API routes are in api.php and will be prefixed with /api automatically
Route::get('/{any}', function () {
    return view('flutter-app');
})->where('any', '(?!api).*'); // Exclude /api/* from catch-all
