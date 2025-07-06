<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class HandleCors
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure(\Illuminate\Http\Request): (\Illuminate\Http\Response|\Illuminate\Http\RedirectResponse)  $next
     * @return \Illuminate\Http\Response|\Illuminate\Http\RedirectResponse
     */
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        // Configure allowed origins. Replace * with your specific domains.
        $allowedOrigins = ['*']; // E.g., ['https://example.com', 'https://anotherdomain.com']

        // Check if the request origin is allowed
        $origin = $request->header('Origin');
        if (in_array($origin, $allowedOrigins) || in_array('*', $allowedOrigins)) {
            $response->header('Access-Control-Allow-Origin', $origin);
        } else {
            $response->header('Access-Control-Allow-Origin', 'null');
        }

        // Add other necessary CORS headers
        $response->header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
        $response->header('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Requested-With');
        $response->header('Access-Control-Allow-Credentials', 'true');

        // Allow preflight requests
        if ($request->getMethod() === 'OPTIONS') {
            $response->header('Access-Control-Max-Age', '86400');
            $response->setStatusCode(204); // No Content
        }

        return $response;
    }
}
