package com.watabou.towngenerator.wards;

import openfl.geom.Point;

import com.watabou.utils.Random;
import com.watabou.geom.Polygon;
import com.watabou.geom.GeomUtils;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Market extends Ward {

	override public function createGeometry() {

		// fountain or statue
		var statue = Random.bool( 0.6 );
		// we always offset a statue and sometimes a fountain
		var offset = statue || Random.bool( 0.3 );

		var v0:Point = null;
		var v1:Point = null;
		if (statue || offset) {
			// we need an edge both for rotating a statue and offsetting
			var length = -1.0;
			patch.shape.forEdge( function( p0, p1 ) {
				var len = Point.distance( p0, p1 );
				if (len > length) {
					length = len;
					v0 = p0;
					v1 = p1;
				}
			} );
		}

		var object:Polygon;
		if (statue) {
			object = Polygon.rect( 1 + Random.float(), 1 + Random.float() );
			object.rotate( Math.atan2( v1.y - v0.y, v1.x - v0.x ) );
		} else {
			object = Polygon.circle( 1 + Random.float() );
		}

		if (offset) {
			var gravity = GeomUtils.interpolate( v0, v1 );
			object.offset( GeomUtils.interpolate( patch.shape.centroid, gravity, 0.2 + Random.float() * 0.4 ) );
		} else {
			object.offset( patch.shape.centroid );
		}

		geometry = [object];
	}

	public static function rateLocation( model:Model, patch:Patch ):Float {
		// One market should not touch another
		for (p in model.inner)
			if (Std.is( p.ward, Market ) && p.shape.borders( patch.shape ))
				return Math.POSITIVE_INFINITY;

		// Market shouldn't be much larger than the plaza
		return model.plaza != null ? patch.shape.square / model.plaza.shape.square : patch.shape.distance( model.center );
	}

	override public inline function getLabel() return "Market";
}
