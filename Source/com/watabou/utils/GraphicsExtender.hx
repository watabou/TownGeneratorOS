package com.watabou.utils;

import openfl.geom.Point;
import openfl.display.Graphics;

using com.watabou.utils.PointExtender;

class GraphicsExtender {

	public static function drawPolygon( g:Graphics, p:Array<Point> ) {
		var last = p.length - 1;
		g.moveTo( p[last].x, p[last].y );
		for (ver in p) {
			g.lineTo( ver.x, ver.y );
		}
	}

	public static function drawPolyline( g:Graphics, p:Array<Point> ) {
		g.moveTo( p[0].x, p[0].y );
		for (i in 1...p.length) {
			g.lineTo( p[i].x, p[i].y );
		}
	}

	public static inline function moveToPoint( g:Graphics, p:Point )
		g.moveTo( p.x, p.y );

	public static inline function lineToPoint( g:Graphics, p:Point )
		g.lineTo( p.x, p.y );
}