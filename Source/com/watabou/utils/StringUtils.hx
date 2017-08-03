package com.watabou.utils;

class StringUtils {

	public static function capitalize( s:String )
		return s.substr( 0, 1 ).toUpperCase() + s.substr( 1 );

	public static function enumerate( a:Array<Dynamic> ) return
		switch (a.length) {
			case 0: "";
			case 1: Std.string( a[0] );
			default:
				a.slice( 0, a.length - 1 ).join( ", " ) + " and " + a[a.length - 1];
		}

	public static function plural( s:String )
		return
			if (s.substr( s.length - 3) == "man")
				s.substr( 0, s.length - 3 ) + "men"
			else if (s.charAt( s.length - 1 ) == "s")
				s + "es"
			else
				s + "s";

	public static function genitive( s:String )
		return s.charAt( s.length - 1 ) == s ? s + "'" : s + "'s";
}