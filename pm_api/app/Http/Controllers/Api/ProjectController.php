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
        return Project::where('owner_id', $user->id)
            ->with(['owner', 'tasks'])
            ->get();
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
        $project = Project::where('owner_id', $user->id)
            ->with(['owner', 'tasks'])
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

    // Add a member to a project (team management)
    public function addMember(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
        ]);
        
        // You may want to use a pivot table for real team management
        // For now, just return success (implement pivot logic if needed)
        return response()->json(['message' => 'Member added (implement logic as needed)']);
    }

    // Remove a member from a project (team management)
    public function removeMember(Request $request, $id)
    {
        $user = $request->user();
        $project = Project::where('owner_id', $user->id)->findOrFail($id);
        
        $validated = $request->validate([
            'user_id' => 'required|exists:users,id',
        ]);
        
        // You may want to use a pivot table for real team management
        // For now, just return success (implement pivot logic if needed)
        return response()->json(['message' => 'Member removed (implement logic as needed)']);
    }
}
