<?php

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Routing\Middleware\ThrottleRequests;
use App\Providers\RateLimitServiceProvider;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Apply rate limiting to API routes
        $middleware->group('api', [
            'throttle:api',
        ]);

        // $middleware->group('web', [
        //     \Illuminate\Routing\Middleware\SubstituteBindings::class,
        //     ThrottleRequests::class.':60,1',
        // ]);

        // Apply rate limiting to web routes, but after the SubstituteBindings middleware
        $middleware->group('web', [
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            ThrottleRequests::class.':60,1',
        ]);

        $middleware->group('reviews', [
            \Illuminate\Routing\Middleware\SubstituteBindings::class,
            ThrottleRequests::class.':1,1',
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })
    ->withProviders([
        RateLimitServiceProvider::class,
    ])
    ->create();