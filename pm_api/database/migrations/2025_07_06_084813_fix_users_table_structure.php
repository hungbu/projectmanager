<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Check if role column exists before adding it
            if (!Schema::hasColumn('users', 'role')) {
                $table->enum('role', ['admin', 'partner', 'user'])->default('user')->after('email');
            }
            
            // Check if is_active column exists before adding it
            if (!Schema::hasColumn('users', 'is_active')) {
                $table->boolean('is_active')->default(true)->after('role');
            }
        });
        
        // Check if name column exists before renaming it
        if (Schema::hasColumn('users', 'name') && !Schema::hasColumn('users', 'full_name')) {
            Schema::table('users', function (Blueprint $table) {
                $table->renameColumn('name', 'full_name');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // Only rename back if full_name exists and name doesn't
            if (Schema::hasColumn('users', 'full_name') && !Schema::hasColumn('users', 'name')) {
                $table->renameColumn('full_name', 'name');
            }
            
            // Only drop columns if they exist
            if (Schema::hasColumn('users', 'role')) {
                $table->dropColumn('role');
            }
            
            if (Schema::hasColumn('users', 'is_active')) {
                $table->dropColumn('is_active');
            }
        });
    }
};
