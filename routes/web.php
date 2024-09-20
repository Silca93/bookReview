<?php

use Illuminate\Support\Facedes\RateLimiter;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookController;
use App\Http\Controllers\ReviewController;

Route::get('/', function () {
    return redirect()->route('books.index');
});

Route::resource("books", BookController::class)
    ->only(['index', 'show']);


Route::resource("books.reviews", ReviewController::class)
    ->scoped(['review' => 'book'])
    ->only(['create', 'store']);


    

// Route::middleware(['throttle:reviews'])->group(function () {

//         Route::post('/submit-review', 'ReviewController@submit')->name('submit.review');
//     });
    