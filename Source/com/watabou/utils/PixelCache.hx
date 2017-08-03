package com.watabou.utils;

import openfl.display.BitmapData;

class PixelCache {
	private static var cache : Map<UInt,BitmapData> = new Map();

	public static function get( color:UInt ):BitmapData {
		var pixel = cache[color];
		if (pixel == null) {
			pixel = new BitmapData( 1, 1, false, color );
			cache[color] = pixel;
		}
		return pixel;
	}
}