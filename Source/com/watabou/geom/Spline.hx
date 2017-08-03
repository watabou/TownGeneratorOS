package com.watabou.geom;

import flash.display.Graphics;
import openfl.geom.Point;

using com.watabou.utils.GraphicsExtender;
using com.watabou.utils.PointExtender;

class Spline {

	public static var curvature = 0.1;

	public static function startCurve( p0:Point, p1:Point, p2:Point ):Array<Point> {
		var tangent = p2.subtract( p0 );
		var control = p1.subtract( tangent.scale( curvature ) );
		return [control, p1];
	}

	public static function endCurve( p0:Point, p1:Point, p2:Point ):Array<Point> {
		var tangent = p2.subtract( p0 );
		var control = p1.add( tangent.scale( curvature ) );
		return [control, p2];
	}

	public static function midCurve( p0:Point, p1:Point, p2:Point, p3:Point ):Array<Point> {
		var dir = p2.subtract( p1 );
		var tangent1 = p2.subtract( p0 );
		var tangent2 = p3.subtract( p1 );

		var p1a = p1.add( tangent1.scale( curvature ) );
		var p2a = p2.subtract( tangent2.scale( curvature ) );
		var p12 = p1a.add( p2a ).scale( 0.5 );

		return [p1a, p12, p2a, p2];
	}

/*	public static function curvePolygon( g:Graphics, p:Polygon ) {
		g.moveToPoint( p[0] );

		var n = p.length;
		var c:Array<Point>;

		c = startCurve( p[0], p[1], p[2] );
		g.curveTo
		for (i in 1...n-2) {

		}
	}*/
}