package com.watabou.towngenerator.wards;

import openfl.geom.Point;

import com.watabou.geom.GeomUtils;
import com.watabou.geom.Polygon;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Cutter;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class Ward {

	public static inline var MAIN_STREET	= 2.0;
	public static inline var REGULAR_STREET	= 1.0;
	public static inline var ALLEY			= 0.6;

	public var model : Model;
	public var patch : Patch;

	public var geometry	: Array<Polygon>;

	public function new( model:Model, patch:Patch ) {
		this.model = model;
		this.patch = patch;
	}

	public function createGeometry() {
		geometry = [];
	}

	public function getCityBlock():Polygon {
		var insetDist:Array<Float> = [];

		var innerPatch = model.wall == null || patch.withinWalls;
		patch.shape.forEdge( function( v0, v1 ) {
			if (model.wall != null && model.wall.bordersBy( patch, v0, v1 ))
				// Not too close to the wall
				insetDist.push( MAIN_STREET/2 );
			else {
				var onStreet = innerPatch && (model.plaza != null && model.plaza.shape.findEdge( v1, v0 ) != -1);
				if (!onStreet)
					for (street in model.arteries)
						if (street.contains( v0 ) && street.contains( v1 )) {
							onStreet = true;
							break;
						}
				insetDist.push( (onStreet ? MAIN_STREET : (innerPatch ? REGULAR_STREET : ALLEY)) / 2 );
			}
		} );

		return patch.shape.isConvex() ?
			patch.shape.shrink( insetDist ) :
			patch.shape.buffer( insetDist );
	}

	private function filterOutskirts() {
		var populatedEdges:Array<Dynamic> = [];

		function addEdge( v1:Point, v2:Point, factor=1.0 ) {
			var dx = v2.x - v1.x;
			var dy = v2.y - v1.y;
			var distances = new Map<Point,Float>();
			var d = patch.shape.max( function( v:Point )
				return distances[v] = (v != v1 && v != v2 ? GeomUtils.distance2line( v1.x, v1.y, dx, dy, v.x, v.y ) : 0) * factor);

			populatedEdges.push( {x: v1.x, y: v1.y, dx: dx, dy: dy, d: distances[d]} );
		}

		patch.shape.forEdge( function( v1:Point, v2:Point ) {
			var onRoad = false;
			for (street in model.arteries)
				if (street.contains( v1 ) && street.contains( v2 )) {
					onRoad = true;
					break;
				}

			if (onRoad)
				addEdge( v1, v2, 1 );
			else {
				var n = model.getNeighbour( patch, v1 );
				if (n != null)
					if (n.withinCity)
						addEdge( v1, v2, model.isEnclosed( n ) ? 1 : 0.4 );
			}
		} );

		// For every vertex: if this belongs only
		// to patches within city, then 1, otherwise 0
		var density = [for (v in patch.shape)
			if (model.gates.contains( v )) 1.0 else
				model.patchByVertex( v ).every( function( p:Patch ) return p.withinCity ) ? 2 * Random.float() : 0.0
		];

		geometry = geometry.filter( function( building:Polygon ) {
			var minDist = 1.0;
			for (edge in populatedEdges)
				for (v in building) {
					// Distance from the center of the building to the edge
					var d = GeomUtils.distance2line( edge.x, edge.y, edge.dx, edge.dy, v.x, v.y );
					var dist = d / edge.d;
					if (dist < minDist)
						minDist = dist;
				}

			var c = building.center;
			var i = patch.shape.interpolate( c );
			var p = 0.0;
			for (j in 0...i.length)
				p += density[j] * i[j];
			minDist /= p;

			return Random.fuzzy( 1 ) > minDist;
		} );
	}

	public function getLabel():String return null;

	public static function rateLocation(model:Model, patch:Patch ):Float return 0;

	public static function createAlleys( p:Polygon, minSq:Float, gridChaos:Float, sizeChaos:Float, emptyProb:Float=0.04, split=true ):Array<Polygon> {
		// Looking for the longest edge to cut it
		var v:Point = null;
		var length = -1.0;
		p.forEdge( function( p0, p1 ) {
			var len = Point.distance( p0, p1 );
			if (len > length) {
				length = len;
				v = p0;
			}
		} );

		var spread = 0.8 * gridChaos;
		var ratio = (1 - spread) / 2 + Random.float() * spread;

		// Trying to keep buildings rectangular even in chaotic wards
		var angleSpread = Math.PI / 6 * gridChaos * (p.square < minSq * 4 ? 0.0 : 1);
		var b = (Random.float() - 0.5) * angleSpread;

		var halves = Cutter.bisect( p, v, ratio, b, split ? ALLEY : 0.0 );

		var buildings = [];
		for (half in halves) {
			if (half.square < minSq * Math.pow( 2, 4 * sizeChaos * (Random.float() - 0.5) )) {
				if (!Random.bool( emptyProb ))
					buildings.push( half );
			} else {
				buildings = buildings.concat( createAlleys( half, minSq, gridChaos, sizeChaos, emptyProb, half.square > minSq / (Random.float() * Random.float()) ) );
			}
		}

		return buildings;
	}

	private static function findLongestEdge( poly:Polygon ):Point
		return poly.min( function( v ) return -poly.vector( v ).length );

	public static function createOrthoBuilding( poly:Polygon, minBlockSq:Float, fill:Float ):Array<Polygon> {
		function slice( poly:Polygon, c1:Point, c2:Point ):Array<Polygon> {
			var v0 = findLongestEdge( poly );
			var v1 = poly.next( v0 );
			var v = v1.subtract( v0 );

			var ratio = 0.4 + Random.float() * 0.2;
			var p1 = GeomUtils.interpolate( v0, v1, ratio );

			var c:Point = if (Math.abs( GeomUtils.scalar( v.x, v.y, c1.x, c1.y ) ) < Math.abs( GeomUtils.scalar( v.x, v.y, c2.x, c2.y ) )) c1 else c2;

			var halves = poly.cut( p1, p1.add( c ) );
			var buildings = [];
			for (half in halves) {
				if (half.square < minBlockSq * Math.pow( 2, Random.normal() * 2 - 1 )) {
					if (Random.bool( fill ))
						buildings.push( half );
				} else {
					buildings = buildings.concat( slice( half, c1, c2 ) );
				}
			}
			return buildings;
		}

		if (poly.square < minBlockSq) {
			return [poly];
		} else {
			var c1 = poly.vector( findLongestEdge( poly ) );
			var c2 = c1.rotate90();
			while (true) {
				var blocks = slice( poly, c1, c2 );
				if (blocks.length > 0)
					return blocks;
			}
		}
	}
}
