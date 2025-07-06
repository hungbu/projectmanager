# API Testing Guide

## Issue
The user creation is failing with a network error. Let's test the API endpoints to identify the problem.

## Step 1: Test Laravel API Server
First, make sure your Laravel API server is running:
```bash
cd pm_api
php artisan serve
```

## Step 2: Test Authentication
Test the login endpoint:
```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@gmail.com",
    "password": "password"
  }'
```

## Step 3: Test User Creation (with token)
Get a token from the login response and test user creation:
```bash
curl -X POST http://localhost:8000/api/users \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -d '{
    "email": "test@example.com",
    "full_name": "Test User",
    "password": "password123",
    "role": "user"
  }'
```

## Step 4: Check Database Schema
If the API is failing, check if the database migration has been run:
```bash
cd pm_api
php artisan migrate:status
```

If migrations are pending, run them:
```bash
php artisan migrate
```

## Step 5: Check Database Structure
Check the actual database structure:
```bash
php artisan tinker
```

Then run:
```php
Schema::getColumnListing('users');
```

## Expected Results

### If migration is not run:
- The API will fail because `full_name` column doesn't exist
- You'll get a database error

### If migration is run:
- The API should return a 201 status with user data
- Response should look like:
```json
{
  "message": "User created successfully",
  "user": {
    "id": 4,
    "full_name": "Test User",
    "email": "test@example.com",
    "role": "user",
    "is_active": true,
    "created_at": "2025-07-05T...",
    "updated_at": "2025-07-05T..."
  }
}
```

## Common Issues

1. **Database Migration Not Run**: The `full_name` column doesn't exist
2. **Server Not Running**: Laravel API server is not started
3. **Authentication Issues**: Invalid or missing token
4. **Validation Errors**: Invalid email format, password too short, etc.

## Debug Steps

1. Check if Laravel server is running on port 8000
2. Check if database migration has been run
3. Check if the database has the correct schema
4. Test with curl to isolate if it's a Flutter or API issue 