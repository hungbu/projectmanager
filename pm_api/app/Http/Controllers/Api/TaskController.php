<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Task;
use App\Models\Project;
use App\Models\User;

class TaskController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->with(['project', 'assignee']);
        
        if ($request->has('project_id')) {
            $query->where('project_id', $request->project_id);
        }
        if ($request->has('status')) {
            $query->where('status', $request->status);
        }
        return $query->get();
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $user = $request->user();
        $validated = $request->validate([
            'project_id' => 'required|exists:projects,id',
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'in:todo,in_progress,review,done',
            'priority' => 'in:low,medium,high',
            'assignee_id' => 'nullable|exists:users,id',
            'due_date' => 'nullable|date',
            'estimated_hours' => 'nullable|integer',
            'tags' => 'nullable|array',
        ]);

        // Ensure the project belongs to the authenticated user
        $project = Project::where('owner_id', $user->id)
            ->findOrFail($validated['project_id']);
        
        $task = Task::create($validated);
        return response()->json($task->load(['project', 'assignee']), 201);
    }

    /**
     * Display the specified resource.
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->with(['project', 'assignee'])->findOrFail($id);
        return response()->json($task);
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->findOrFail($id);
        
        $validated = $request->validate([
            'project_id' => 'sometimes|exists:projects,id',
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'status' => 'in:todo,in_progress,review,done',
            'priority' => 'in:low,medium,high',
            'assignee_id' => 'nullable|exists:users,id',
            'due_date' => 'nullable|date',
            'estimated_hours' => 'nullable|integer',
            'tags' => 'nullable|array',
        ]);
        
        $task->update($validated);
        return response()->json($task->load(['project', 'assignee']));
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->findOrFail($id);
        $task->delete();
        return response()->json(['message' => 'Task deleted']);
    }

    // Update task status (Kanban move)
    public function updateStatus(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->findOrFail($id);
        
        $validated = $request->validate([
            'status' => 'required|in:todo,in_progress,review,done',
        ]);
        $task->status = $validated['status'];
        $task->save();
        return response()->json($task->load(['project', 'assignee']));
    }

    // Assign a user to a task
    public function assign(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->findOrFail($id);
        
        $validated = $request->validate([
            'assignee_id' => 'required|exists:users,id',
        ]);
        $task->assignee_id = $validated['assignee_id'];
        $task->save();
        return response()->json($task->load(['project', 'assignee']));
    }

    // Unassign a user from a task
    public function unassign(Request $request, $id)
    {
        $user = $request->user();
        $task = Task::whereHas('project', function ($q) use ($user) {
            $q->where('owner_id', $user->id);
        })->findOrFail($id);
        
        $task->assignee_id = null;
        $task->save();
        return response()->json($task->load(['project', 'assignee']));
    }
}
