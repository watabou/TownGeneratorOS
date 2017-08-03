package com.watabou.utils;

import openfl.Lib;

class Stopwatch {

	private static var startTime : Int;

	public static function start()
		startTime = Lib.getTimer();

	public static function lap():Int
		return Lib.getTimer() - startTime;

	public static function next():Int {
		var curTime = Lib.getTimer();
		var result = curTime - startTime;
		startTime = curTime;
		return result;
	}

	public static function measure( fn:Void->Void ):Int {
		start(); fn(); return next();
	}
}