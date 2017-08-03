package com.watabou.utils;

class FloatExtender {
	public static function nullValue( f:Float, value:Float=0 ) {
		#if neko
		return f == null ? value : f;
		#else
		return f;
		#end
	}
}
