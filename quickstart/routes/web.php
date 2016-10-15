<?php

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| This file is where you may define all of the routes that are handled
| by your application. Just tell Laravel the URIs it should respond
| to using a Closure or controller method. Build something great!
|
*/

Route::get('/', function () {
    return view('task');
});

Route::post('/task', function (Request $request) {
    $validator = Validator::make($request->all(), [
        'name' => 'required|max:10',
    ]);

    if($validator->fails()) {
        return redirect('/')
            ->withInput()
            ->withErrors($validator);
    }

});

Route::delete('/task/{task}', function () {
    //
});