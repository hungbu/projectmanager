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
    // Public routes (no authentication required)
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);

    // Protected routes (authentication required)
    Route::middleware('auth:sanctum')->group(function () {
        // Auth routes
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/user', [AuthController::class, 'user']);

        // Project routes
        Route::apiResource('projects', ProjectController::class);
        Route::get('projects/{project}/members', [ProjectController::class, 'members']);
        Route::post('projects/{project}/add-member', [ProjectController::class, 'addMember']);
        Route::post('projects/{project}/remove-member', [ProjectController::class, 'removeMember']);
        Route::get('projects/{project}/tasks', [ProjectController::class, 'tasks']);

        // Task routes
        Route::apiResource('tasks', TaskController::class);
        Route::patch('tasks/{task}/status', [TaskController::class, 'updateStatus']);
        Route::patch('tasks/{task}/assign', [TaskController::class, 'assign']);
        Route::patch('tasks/{task}/unassign', [TaskController::class, 'unassign']);

        // User management routes (admin only)

        Route::apiResource('users', UserController::class);
        Route::patch('users/{user}/toggle-status', [UserController::class, 'toggleStatus']);
    });
});

// Catch-all route to serve Flutter app for SPA routing (must be last)
Route::get('/{any}', function () {
    return view('flutter-app');
})->where('any', '.*');
