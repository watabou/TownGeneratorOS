package com.watabou.towngenerator.building;

import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Voronoi.Region;

import com.watabou.towngenerator.wards.Ward;

class Patch {

	public var shape	: Polygon;
	public var ward 	: Ward;

	public var withinWalls	: Bool;
	public var withinCity	: Bool;

	public inline function new( vertices:Array<Point> ) {
		this.shape = new Polygon( vertices );

		withinCity	= false;
		withinWalls	= false;
	}

	public static function fromRegion( r:Region ):Patch
		return new Patch( [for (tr in r.vertices) tr.c] );
}

