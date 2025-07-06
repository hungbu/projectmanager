# Database Migration Guide

## Issue
The API is returning literal strings like `"full_name": full_name` instead of actual values because the database migration hasn't been run yet.

## Solution
Run the Laravel migration to update the database schema:

### Step 1: Navigate to the Laravel API directory
```bash
cd pm_api
```

### Step 2: Run the migration
```bash
php artisan migrate
```

### Step 3: Verify the migration
```bash
php artisan migrate:status
```

### Step 4: Check the database structure
You can also check the database structure directly:
```bash
php artisan tinker
```
Then run:
```php
Schema::getColumnListing('users');
```

## Expected Result
After running the migration, the API should return proper values like:
```json
{
  "id": 3,
  "full_name": "Admin User",
  "email": "admin@gmail.com",
  "role": "admin",
  "is_active": true,
  "created_at": "2025-07-05T06:35:25.000000Z",
  "updated_at": "2025-07-05T06:35:25.000000Z"
}
```

Instead of:
```json
{
  "id": 3,
  "full_name": "full_name",
  "email": "admin@gmail.com",
  "role": "admin",
  "is_active": "is_active",
  "created_at": "2025-07-05T06:35:25.000000Z",
  "updated_at": "2025-07-05T06:35:25.000000Z"
}
```

## Alternative: Manual Database Update
If you can't run the migration, you can manually update the database:

1. Connect to your database
2. Run these SQL commands:
```sql
-- Rename the 'name' column to 'full_name'
ALTER TABLE users RENAME COLUMN name TO full_name;

-- Add the 'is_active' column if it doesn't exist
ALTER TABLE users ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

-- Add the 'role' column if it doesn't exist
ALTER TABLE users ADD COLUMN role ENUM('admin', 'partner', 'user') DEFAULT 'user';
```

## Testing
After running the migration, test the API endpoint:
```bash
curl -H "Authorization: Bearer YOUR_TOKEN" http://localhost:8000/api/users
```

The response should now contain proper values instead of literal strings. 