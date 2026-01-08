<?php

use App\Http\Controllers\PlayerApiController;
use Illuminate\Support\Facades\Route;


Route::get('/player',[PlayerApiController::class, "list"]);