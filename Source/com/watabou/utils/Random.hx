package com.watabou.utils;

import openfl.Lib;

class Random {

	private static inline var g = 48271.0;
	private static inline var n = 2147483647;

	private static var seed = 1;

	public static function reset( seed=-1 )
		Random.seed = (seed != -1 ? seed : Std.int( Date.now().getTime() % n ));

	public static inline function getSeed():Int return seed;

	private static inline function next():Int
		return (seed = Std.int( (seed * g) % n ));

	public static inline function float():Float
		return next() / n;

	public static inline function normal():Float
		return (float() + float() + float()) / 3;

	public static inline function int( min:Int, max:Int ):Int
		return Std.int( min + next() / n * (max - min) );

	public static inline function bool( chance=0.5 ):Bool
		return float() < chance;

	public static function fuzzy( f=1.0 ):Float {
		return if (f == 0)
			0.5
		else
			(1 - f) / 2 + f * normal();
	}
}