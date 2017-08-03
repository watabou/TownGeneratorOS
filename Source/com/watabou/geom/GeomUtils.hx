package com.watabou.geom;

import openfl.geom.Point;

class GeomUtils {
	public static function intersectLines( x1:Float, y1:Float, dx1:Float, dy1: Float, x2:Float, y2:Float, dx2:Float, dy2:Float ):Point {
		var d = dx1 * dy2 - dy1 * dx2;
		if (d == 0)
			return null;

		var t2 = (dy1 * (x2 - x1) - dx1 * (y2 - y1)) /d;
		var t1 = dx1 != 0 ?
			(x2 - x1 + dx2 * t2) / dx1 :
			(y2 - y1 + dy2 * t2) / dy1;

		return new Point( t1, t2 );
	}

	public static function interpolate( p1:Point, p2:Point, ratio=0.5 ):Point {
		var d = p2.subtract( p1 );
		return new Point( p1.x + d.x * ratio, p1.y + d.y * ratio );
	}

	public static inline function scalar( x1:Float, y1:Float, x2:Float, y2:Float )
		return x1 * x2 + y1 * y2;

	public static inline function cross( x1:Float, y1:Float, x2:Float, y2:Float )
		return x1 * y2 - y1 * x2;

	public static function distance2line( x1:Float, y1:Float, dx1:Float, dy1:Float, x0:Float, y0:Float ):Float
		return (dx1 * y0 - dy1 * x0 + (y1 + dy1) * x1 - (x1 + dx1) * y1) / Math.sqrt( dx1 * dx1 + dy1 * dy1 );
}