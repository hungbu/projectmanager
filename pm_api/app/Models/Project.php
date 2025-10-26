<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Project extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'name',
        'description',
        'status',
        'owner_id',
        'start_date',
        'end_date',
        'color',
        'access_code',
    ];

    public function tasks()
    {
        return $this->hasMany(Task::class);
    }

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'project_user');
    }

    /**
     * Generate a unique access code for the project
     */
    public function generateAccessCode()
    {
        do {
            $accessCode = bin2hex(random_bytes(16)); // 32 character hex string
        } while (self::where('access_code', $accessCode)->exists());

        $this->access_code = $accessCode;
        $this->save();

        return $accessCode;
    }

    /**
     * Check if access code is set
     */
    public function hasAccessCode()
    {
        return !empty($this->access_code);
    }

    /**
     * Remove access code
     */
    public function revokeAccessCode()
    {
        $this->access_code = null;
        $this->save();
    }
}
