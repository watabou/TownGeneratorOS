package com.watabou.utils;

import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.Assets;
import openfl.display.Bitmap;

class BitmapUtils {

	private static var colors	: Map<Int, BitmapData> = new Map();

	public static function create( id:String ):Bitmap {
		return new Bitmap( Assets.getBitmapData( id ), PixelSnapping.ALWAYS, false );
	}

	public static function getColor( c:Int ):BitmapData {
		var bmp = colors.get( c );
		if (bmp == null) {
			bmp = new BitmapData( 1, 1, false, c );
			colors.set( c, bmp );
		}
		return bmp;
	}
}