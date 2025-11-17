<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;
use App\Models\User;

class ProjectController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        // Get projects where user is owner or member
        $projects = Project::where(function($query) use ($user) {
            $query->where('owner_id', $user->id)
                  ->orWhereHas('users', function($q) use ($user) {
                      $q->where('user_id', $user->id);
                  });
        })
        ->with(['owner', 'tasks', 'users'])
        ->get();
        
        return response()->json($projects);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'in:active,completed,archived',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'color' => 'nullable|string|max:16',
        ]);

        // Set the authenticated user as the owner
        $validated['owner_id'] = $request->user()->id;
        
        $project = Project::create($validated);
        return response()->json($project->load(['owner', 'tasks']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where(function($query) use ($user) {
            $query->where('owner_id', $user->id)
                  ->orWhereHas('users', function($q) use ($user) {
                      $q->where('user_id', $user->id);
                  });
        })
        ->with(['owner', 'tasks', 'users'])
        ->findOrFail($id);
        return response()->json($project);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'in:active,completed,archived',
            'start_date' => 'nullable|date',
            'end_date' => 'nullable|date|after_or_equal:start_date',
            'color' => 'nullable|string|max:16',
        ]);
        
        $project->update($validated);
        return response()->json($project->load(['owner', 'tasks']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        $project->delete();
        return response()->json(['message' => 'Project deleted']);
    }

    // Get all tasks for a project
    public function tasks(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        return response()->json($project->tasks()->with('assignee')->get());
    }

    // Get project members
    public function members(Request $request, $id)
    {
        $user = $request->user();
        
        // Check if user is owner or member of the project
        $project = Project::where(function($query) use ($user) {
            $query->where('owner_id', $user->id)
                  ->orWhereHas('users', function($q) use ($user) {
                      $q->where('user_id', $user->id);
                  });
        })->findOrFail($id);
        
        // Get all members from project_user table
        $memberIds = $project->users()->get()->pluck('id')->toArray();
        
        // Get owner
        $owner = $project->owner;
        
        // Combine member IDs with owner ID
        $allMemberIds = array_unique(array_merge($memberIds, $owner ? [$owner->id] : []));
        
        // Get all users (members + owner)
        $allMembers = User::whereIn('id', $allMemberIds)
            ->get(['id', 'name', 'email', 'role'])
            ->map(function($user) {
                return [
                    'id' => $user->id,
                    'name' => $user->name,
                    'email' => $user->email,
                    'role' => $user->role,
                ];
            });
        
        return response()->json($allMembers);
    }

    // Add a member to a project
    public function addMember(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
        ]);
        
        // Check if user is already a member
        if ($project->users()->where('user_id', $validated['user_id'])->exists()) {
            return response()->json(['message' => 'User is already a member of this project'], 400);
        }
        
        $project->users()->attach($validated['user_id']);
        
        return response()->json(['message' => 'Member added successfully']);
    }

    // Remove a member from a project
    public function removeMember(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
        ]);
        
        $project->users()->detach($validated['user_id']);
        
        return response()->json(['message' => 'Member removed successfully']);
    }

    // Generate access code for public sharing
    public function generateAccessCode(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $accessCode = $project->generateAccessCode();
        
        return response()->json([
            'message' => 'Access code generated successfully',
            'access_code' => $accessCode,
            'share_url' => config('app.frontend_url') . '/public/project/' . $accessCode,
        ]);
    }

    // Revoke access code
    public function revokeAccessCode(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $project->revokeAccessCode();
        
        return response()->json([
            'message' => 'Access code revoked successfully',
        ]);
    }

    // Get access code info
    public function getAccessCode(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        if (!$project->hasAccessCode()) {
            return response()->json([
                'has_access_code' => false,
                'message' => 'No access code set for this project',
            ]);
        }
        
        return response()->json([
            'has_access_code' => true,
            'access_code' => $project->access_code,
            'share_url' => config('app.frontend_url') . '/public/project/' . $project->access_code,
        ]);
    }
}
