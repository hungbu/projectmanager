<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProjectController;
use App\Http\Controllers\Api\TaskController;
use App\Http\Controllers\Api\AuthController;

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
    Route::post('projects/{project}/add-member', [ProjectController::class, 'addMember']);
    Route::post('projects/{project}/remove-member', [ProjectController::class, 'removeMember']);
    Route::get('projects/{project}/tasks', [ProjectController::class, 'tasks']);

    // Task routes
    Route::apiResource('tasks', TaskController::class);
    Route::patch('tasks/{task}/status', [TaskController::class, 'updateStatus']);
    Route::patch('tasks/{task}/assign', [TaskController::class, 'assign']);
    Route::patch('tasks/{task}/unassign', [TaskController::class, 'unassign']);
}); 