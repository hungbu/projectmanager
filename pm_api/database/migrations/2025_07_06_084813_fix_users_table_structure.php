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
            // First, add the new columns
            $table->enum('role', ['admin', 'partner', 'user'])->default('user')->after('email');
            $table->boolean('is_active')->default(true)->after('role');
        });
        
        // Then rename the name column to full_name
        Schema::table('users', function (Blueprint $table) {
            $table->renameColumn('name', 'full_name');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            // First rename back
            $table->renameColumn('full_name', 'name');
            
            // Then drop the added columns
            $table->dropColumn(['role', 'is_active']);
        });
    }
};
