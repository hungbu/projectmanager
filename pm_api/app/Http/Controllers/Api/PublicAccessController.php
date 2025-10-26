<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Project;

class PublicAccessController extends Controller
{
    /**
     * Get project by access code (public endpoint - no auth required)
     */
    public function getProjectByAccessCode(Request $request, $accessCode)
    {
        $project = Project::where('access_code', $accessCode)
            ->with(['owner:id,name,email', 'users:id,name,email'])
            ->first();

        if (!$project) {
            return response()->json([
                'message' => 'Invalid access code'
            ], 404);
        }

        // Return limited project data for public view
        return response()->json([
            'id' => $project->id,
            'name' => $project->name,
            'description' => $project->description,
            'status' => $project->status,
            'start_date' => $project->start_date,
            'end_date' => $project->end_date,
            'color' => $project->color,
            'owner' => $project->owner,
            'created_at' => $project->created_at,
            'updated_at' => $project->updated_at,
        ]);
    }

    /**
     * Get tasks for a project by access code (public endpoint - no auth required)
     */
    public function getTasksByAccessCode(Request $request, $accessCode)
    {
        $project = Project::where('access_code', $accessCode)->first();

        if (!$project) {
            return response()->json([
                'message' => 'Invalid access code'
            ], 404);
        }

        // Get all tasks with assignee info
        $tasks = $project->tasks()
            ->with(['assignee:id,name,email'])
            ->orderBy('created_at', 'desc')
            ->get();

        // Group tasks by status for Kanban board
        $kanbanBoard = [
            'todo' => [],
            'in_progress' => [],
            'review' => [],
            'done' => [],
        ];

        foreach ($tasks as $task) {
            $status = $task->status ?? 'todo';
            if (isset($kanbanBoard[$status])) {
                $kanbanBoard[$status][] = [
                    'id' => $task->id,
                    'title' => $task->title,
                    'description' => $task->description,
                    'status' => $task->status,
                    'priority' => $task->priority,
                    'assignee' => $task->assignee,
                    'due_date' => $task->due_date,
                    'created_at' => $task->created_at,
                    'updated_at' => $task->updated_at,
                ];
            }
        }

        return response()->json([
            'project_id' => $project->id,
            'project_name' => $project->name,
            'tasks' => $tasks,
            'kanban_board' => $kanbanBoard,
        ]);
    }

    /**
     * Verify access code (check if valid)
     */
    public function verifyAccessCode(Request $request, $accessCode)
    {
        $project = Project::where('access_code', $accessCode)->first();

        if (!$project) {
            return response()->json([
                'valid' => false,
                'message' => 'Invalid access code'
            ], 404);
        }

        return response()->json([
            'valid' => true,
            'project_id' => $project->id,
            'project_name' => $project->name,
        ]);
    }
}
