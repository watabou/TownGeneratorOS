package com.watabou.towngenerator.building;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.GeomUtils;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class Cutter {

	public static function bisect( poly:Polygon, vertex:Point, ratio=0.5, angle=0.0, gap=0.0 ):Array<Polygon> {

		var next = poly.next( vertex );

		var p1 = GeomUtils.interpolate( vertex, next, ratio );
		var d = next.subtract( vertex );

		var cosB = Math.cos( angle );
		var sinB = Math.sin( angle );
		var vx = d.x * cosB - d.y * sinB;
		var vy = d.y * cosB + d.x * sinB;
		var p2 = new Point( p1.x - vy, p1.y + vx );

		return poly.cut( p1, p2, gap );
	}

	public static function radial( poly:Polygon, center:Point=null, gap=0.0 ):Array<Polygon> {

		if (center == null)
			center = poly.centroid;

		var sectors:Array<Polygon> = [];
		poly.forEdge( function( v0, v1 ) {
			var sector = new Polygon( [center, v0, v1] );
			if (gap > 0)
				sector = sector.shrink( [gap/2, 0, gap/2] );

			sectors.push( sector );
		} );
		return sectors;
	}

	public static function semiRadial( poly:Polygon, center:Point=null, gap=0.0 ):Array<Polygon> {
		if (center == null) {
			var centroid = poly.centroid;
			center = poly.min( function( v:Point ) return Point.distance( v, centroid ) );
		}

		gap /= 2;

		var sectors:Array<Polygon> = [];
		poly.forEdge( function( v0, v1 )
			if (v0!= center && v1 != center) {
				var sector = new Polygon( [center, v0, v1] );
				if (gap > 0) {
					var d = [poly.findEdge( center, v0 ) == -1 ? gap : 0, 0, poly.findEdge( v1, center ) == -1 ? gap : 0];
					sector = sector.shrink( d );
				}
				sectors.push( sector );
			}
		);
		return sectors;
	}

	public static function ring( poly:Polygon, thickness:Float ):Array<Polygon> {

		var slices:Array<Dynamic> = [];
		poly.forEdge( function( v1:Point, v2:Point ) {
			var v = v2.subtract( v1 );
			var n = v.rotate90().norm( thickness );
			slices.push( {p1:v1.add( n ), p2:v2.add( n ), len: v.length} );
		} );

		// Short sides should be sliced first
		slices.sort( function( s1, s2 ) return (s1.len - s2.len) );

		var peel:Array<Polygon> = [];

		var p = poly;
		for (i in 0...slices.length) {
			var halves = p.cut( slices[i].p1, slices[i].p2 );
			p = halves[0];
			if (halves.length == 2)
				peel.push( halves[1] );
		}

		return peel;
	}
}
