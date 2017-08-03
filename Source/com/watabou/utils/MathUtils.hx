package com.watabou.utils;

class MathUtils {
	public static function gate( value:Float, min:Float, max:Float ):Float {
		return value < min ? min : (value < max ? value : max);
	}

	public static function gatei( value:Int, min:Int, max:Int ):Int {
		return value < min ? min : (value < max ? value : max);
	}

	public static function sign( value:Float ):Int {
		return value == 0 ? 0 : (value < 0 ? -1 : 1);
	}
}
