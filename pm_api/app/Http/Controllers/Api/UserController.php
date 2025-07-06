<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class UserController extends Controller
{
    /**
     * Display a listing of users (admin only)
     */
    public function index()
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $users = User::select('id', 'name', 'email', 'role', 'is_active', 'created_at', 'updated_at')
            ->orderBy('created_at', 'desc')
            ->get();

        return response()->json($users);
    }

    /**
     * Store a newly created user (admin only)
     */
    public function store(Request $request)
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|string|in:admin,partner,user',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'password' => Hash::make($request->password),
                'role' => $request->role,
                'is_active' => true,
            ]);

            return response()->json([
                'message' => 'User created successfully',
                'user' => $user->only(['id', 'name', 'email', 'role', 'is_active', 'created_at', 'updated_at'])
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error creating user',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified user (admin only)
     */
    public function show($id)
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        return response()->json($user->only(['id', 'name', 'email', 'role', 'is_active', 'created_at', 'updated_at']));
    }

    /**
     * Update the specified user (admin only)
     */
    public function update(Request $request, $id)
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
            'name' => 'sometimes|string|max:255',
            'role' => 'sometimes|string|in:admin,partner,user',
            'is_active' => 'sometimes|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $updateData = [];

            if ($request->has('email')) {
                $updateData['email'] = $request->email;
            }

            if ($request->has('name')) {
                $updateData['name'] = $request->name;
            }

            if ($request->has('role')) {
                $updateData['role'] = $request->role;
            }

            if ($request->has('is_active')) {
                $updateData['is_active'] = $request->is_active;
            }

            $user->update($updateData);

            return response()->json([
                'message' => 'User updated successfully',
                'user' => $user->only(['id', 'name', 'email', 'role', 'is_active', 'created_at', 'updated_at'])
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error updating user',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified user (admin only)
     */
    public function destroy($id)
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        // Prevent admin from deleting themselves
        if ($user->id === auth()->id()) {
            return response()->json([
                'message' => 'Cannot delete your own account'
            ], 400);
        }

        try {
            $user->delete();

            return response()->json([
                'message' => 'User deleted successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error deleting user',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Toggle user active status (admin only)
     */
    public function toggleStatus($id)
    {
        // Check if user has admin permission
        if (!auth()->user()->hasRole('admin')) {
            return response()->json([
                'message' => 'Unauthorized. Admin access required.'
            ], 403);
        }

        $user = User::find($id);

        if (!$user) {
            return response()->json([
                'message' => 'User not found'
            ], 404);
        }

        // Prevent admin from deactivating themselves
        if ($user->id === auth()->id()) {
            return response()->json([
                'message' => 'Cannot deactivate your own account'
            ], 400);
        }

        try {
            $user->update(['is_active' => !$user->is_active]);

            return response()->json([
                'message' => 'User status updated successfully',
                'user' => $user->only(['id', 'name', 'email', 'role', 'is_active', 'created_at', 'updated_at'])
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Error updating user status',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 