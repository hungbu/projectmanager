<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\PublicAccessController;

// Public routes (no authentication required)
Route::get('/csrf-token', function () {
    return response()->json(['token' => csrf_token()]);
});
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Public access routes (no authentication required)
Route::prefix('public')->group(function () {
    Route::get('/project/{accessCode}', [PublicAccessController::class, 'getProjectByAccessCode']);
    Route::get('/project/{accessCode}/tasks', [PublicAccessController::class, 'getTasksByAccessCode']);
    Route::get('/verify/{accessCode}', [PublicAccessController::class, 'verifyAccessCode']);
});

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
    
    // Access code management routes (owner only)
    Route::post('projects/{project}/access-code/generate', [ProjectController::class, 'generateAccessCode']);
    Route::delete('projects/{project}/access-code', [ProjectController::class, 'revokeAccessCode']);
    Route::get('projects/{project}/access-code', [ProjectController::class, 'getAccessCode']);

    // Task routes
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/{task}/status', [TaskController::class, 'updateStatus']);
    Route::patch('tasks/{task}/assign', [TaskController::class, 'assign']);
    Route::patch('tasks/{task}/unassign', [TaskController::class, 'unassign']);

    // User management routes (admin only)

    Route::apiResource('users', UserController::class);
    Route::patch('users/{user}/toggle-status', [UserController::class, 'toggleStatus']);
}); 