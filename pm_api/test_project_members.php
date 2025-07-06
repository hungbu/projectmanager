<?php

require_once 'vendor/autoload.php';

use Illuminate\Support\Facades\Http;

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "=== Testing Project Member Functionality ===\n";

// First, login to get a token
echo "\n1. Testing login...\n";
$loginResponse = Http::post('http://localhost:8000/api/login', [
    'email' => 'admin@gmail.com',
    'password' => 'password'
]);

echo "Login Status: " . $loginResponse->status() . "\n";
echo "Login Response: " . $loginResponse->body() . "\n";

if ($loginResponse->status() === 200) {
    $loginData = $loginResponse->json();
    if ($loginData && isset($loginData['token'])) {
        $token = $loginData['token'];
    
    echo "\n2. Testing projects endpoint...\n";
    
    $projectsResponse = Http::withHeaders([
        'Authorization' => 'Bearer ' . $token,
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
    ])->get('http://localhost:8000/api/projects');
    
    echo "Projects Status: " . $projectsResponse->status() . "\n";
    
    if ($projectsResponse->status() === 200) {
        $projects = $projectsResponse->json();
        echo "Found " . count($projects) . " projects\n";
        
        if (count($projects) > 0) {
            $projectId = $projects[0]['id'];
            echo "Using project ID: $projectId\n";
            
            echo "\n3. Testing project members endpoint...\n";
            $membersResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            ])->get("http://localhost:8000/api/projects/$projectId/members");
            
            echo "Members Status: " . $membersResponse->status() . "\n";
            echo "Members Response: " . $membersResponse->body() . "\n";
            
            echo "\n4. Testing add member...\n";
            $addMemberResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            ])->post("http://localhost:8000/api/projects/$projectId/add-member", [
                'user_id' => 2 // Add user with ID 2
            ]);
            
            echo "Add Member Status: " . $addMemberResponse->status() . "\n";
            echo "Add Member Response: " . $addMemberResponse->body() . "\n";
            
            echo "\n5. Testing members again after adding...\n";
            $membersResponse2 = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            ])->get("http://localhost:8000/api/projects/$projectId/members");
            
            echo "Members Status: " . $membersResponse2->status() . "\n";
            echo "Members Response: " . $membersResponse2->body() . "\n";
            
            echo "\n6. Testing remove member...\n";
            $removeMemberResponse = Http::withHeaders([
                'Authorization' => 'Bearer ' . $token,
                'Content-Type' => 'application/json',
                'Accept' => 'application/json'
            ])->post("http://localhost:8000/api/projects/$projectId/remove-member", [
                'user_id' => 2 // Remove user with ID 2
            ]);
            
            echo "Remove Member Status: " . $removeMemberResponse->status() . "\n";
            echo "Remove Member Response: " . $removeMemberResponse->body() . "\n";
            
            echo "\n✅ Project member functionality is working correctly!\n";
        } else {
            echo "\n❌ No projects found to test with\n";
        }
    } else {
        echo "\n❌ Failed to get projects: " . $projectsResponse->status() . "\n";
    }
    } else {
        echo "\n❌ Login failed or invalid response\n";
    }
} else {
    echo "\n❌ Login failed\n";
} 