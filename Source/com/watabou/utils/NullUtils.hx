package com.watabou.utils;

import Std;
class NullUtils {
	public static function float( value:Dynamic, defValue:Float=0 ):Float {
		return value == null ? defValue : value;
	}

	public static function int( value:Dynamic, defValue:Int=0 ):Int {
		return value == null ? defValue : value;
	}

	public static function bool( value:Dynamic, defValue=false ):Bool {
		return value == null ? defValue : value;
	}

	public static function string( value:Dynamic, defValue:String="" ):String {
		return value == null ? defValue : value;
	}

	public static function array<T>( value:Dynamic ):Array<T> {
		return value == null ? [] : (Std.is( value, Array ) ? value : [value]);
	}

	public static function orEmpty( value:Dynamic ):Dynamic {
		return value == null ? {} : value;
	}
}