<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Project;
use App\Models\Task;
use Illuminate\Support\Facades\Hash;

class SampleDataSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create sample users
        $user1 = User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'password' => Hash::make('password123'),
        ]);

        $user2 = User::create([
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'password' => Hash::make('password123'),
        ]);

        // Create sample projects for user1
        $project1 = Project::create([
            'name' => 'E-commerce Website',
            'description' => 'Build a modern e-commerce platform with React and Laravel',
            'status' => 'active',
            'owner_id' => $user1->id,
            'start_date' => now(),
            'end_date' => now()->addMonths(3),
            'color' => '#FF6B6B',
        ]);

        $project2 = Project::create([
            'name' => 'Mobile App Development',
            'description' => 'Create a Flutter mobile app for project management',
            'status' => 'active',
            'owner_id' => $user1->id,
            'start_date' => now(),
            'end_date' => now()->addMonths(6),
            'color' => '#4ECDC4',
        ]);

        // Create sample tasks for project1
        Task::create([
            'project_id' => $project1->id,
            'title' => 'Design Database Schema',
            'description' => 'Create ERD and implement database migrations',
            'status' => 'done',
            'priority' => 'high',
            'assignee_id' => $user1->id,
            'due_date' => now()->addDays(7),
            'estimated_hours' => 8,
            'tags' => ['database', 'design'],
        ]);

        Task::create([
            'project_id' => $project1->id,
            'title' => 'Setup Authentication',
            'description' => 'Implement user registration and login system',
            'status' => 'in_progress',
            'priority' => 'high',
            'assignee_id' => $user2->id,
            'due_date' => now()->addDays(14),
            'estimated_hours' => 12,
            'tags' => ['auth', 'security'],
        ]);

        Task::create([
            'project_id' => $project1->id,
            'title' => 'Create Product Catalog',
            'description' => 'Build product listing and detail pages',
            'status' => 'todo',
            'priority' => 'medium',
            'assignee_id' => null,
            'due_date' => now()->addDays(21),
            'estimated_hours' => 16,
            'tags' => ['frontend', 'catalog'],
        ]);

        // Create sample tasks for project2
        Task::create([
            'project_id' => $project2->id,
            'title' => 'Setup Flutter Project',
            'description' => 'Initialize Flutter project with proper structure',
            'status' => 'done',
            'priority' => 'high',
            'assignee_id' => $user1->id,
            'due_date' => now()->addDays(3),
            'estimated_hours' => 4,
            'tags' => ['flutter', 'setup'],
        ]);

        Task::create([
            'project_id' => $project2->id,
            'title' => 'Design UI Components',
            'description' => 'Create reusable UI components and theme',
            'status' => 'in_progress',
            'priority' => 'medium',
            'assignee_id' => $user1->id,
            'due_date' => now()->addDays(10),
            'estimated_hours' => 20,
            'tags' => ['ui', 'design'],
        ]);

        Task::create([
            'project_id' => $project2->id,
            'title' => 'Implement State Management',
            'description' => 'Setup Riverpod for state management',
            'status' => 'review',
            'priority' => 'high',
            'assignee_id' => $user2->id,
            'due_date' => now()->addDays(17),
            'estimated_hours' => 10,
            'tags' => ['state', 'riverpod'],
        ]);

        Task::create([
            'project_id' => $project2->id,
            'title' => 'API Integration',
            'description' => 'Connect Flutter app with Laravel backend',
            'status' => 'todo',
            'priority' => 'high',
            'assignee_id' => null,
            'due_date' => now()->addDays(24),
            'estimated_hours' => 15,
            'tags' => ['api', 'integration'],
        ]);
    }
}
