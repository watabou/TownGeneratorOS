package com.watabou.towngenerator.building;

import Type;
import openfl.errors.Error;
import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.geom.Segment;
import com.watabou.geom.Voronoi;
import com.watabou.utils.MathUtils;
import com.watabou.utils.Random;

import com.watabou.towngenerator.wards.*;

using com.watabou.utils.PointExtender;
using com.watabou.utils.ArrayExtender;

typedef Street = Polygon;

class Model {

	public static var instance	: Model;

	// Small Town	6
	// Large Town	10
	// Small City	15
	// Large City	24
	// Metropolis	40
	private var nPatches	: Int;

	private var plazaNeeded		: Bool;
	private var citadelNeeded	: Bool;
	private var wallsNeeded		: Bool;

	public static var WARDS:Array<Class<Ward>> = [
		CraftsmenWard, CraftsmenWard, MerchantWard, CraftsmenWard, CraftsmenWard, Cathedral,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard, CraftsmenWard,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, AdministrationWard, CraftsmenWard,
		Slum, CraftsmenWard, Slum, PatriciateWard, Market,
		Slum, CraftsmenWard, CraftsmenWard, CraftsmenWard, Slum,
		CraftsmenWard, CraftsmenWard, CraftsmenWard, MilitaryWard, Slum,
		CraftsmenWard, Park, PatriciateWard, Market, MerchantWard];

	public var topology	: Topology;

	public var patches	: Array<Patch>;
	public var waterbody: Array<Patch>;
	// For a walled city it's a list of patches within the walls,
	// for a city without walls it's just a list of all city wards
	public var inner	: Array<Patch>;
	public var citadel	: Patch;
	public var plaza	: Patch;
	public var center	: Point;

	public var border	: CurtainWall;
	public var wall		: CurtainWall;

	public var cityRadius	: Float;

	// List of all entrances of a city including castle gates
	public var gates	: Array<Point>;

	// Joined list of streets (inside walls) and roads (outside walls)
	// without diplicating segments
	public var arteries	: Array<Street>;
	public var streets	: Array<Street>;
	public var roads	: Array<Street>;

	public function new( nPatches=-1, seed=-1 ) {

		if (seed > 0) Random.reset( seed );
		this.nPatches = nPatches != -1 ? nPatches : 15;

		plazaNeeded		= Random.bool();
		citadelNeeded	= Random.bool();
		wallsNeeded		= Random.bool();

		do try {
			build();
			instance = this;
		} catch (e:Error) {
			trace( e.message );
			instance = null;
		} while (instance == null);
	}

	private function build():Void {
		streets = [];
		roads = [];

		buildPatches();
		optimizeJunctions();
		buildWalls();
		buildStreets();
		createWards();
		buildGeometry();
	}

	private function buildPatches():Void {
		var sa = Random.float() * 2 * Math.PI;
		var points = [for (i in 0...nPatches * 8) {
			var a = sa + Math.sqrt( i ) * 5;
			var r = (i == 0 ? 0 : 10 + i * (2 + Random.float()));
			new Point( Math.cos( a ) * r, Math.sin( a ) * r );
		}];
		var voronoi = Voronoi.build( points );

		// Relaxing central wards
		for (i in 0...3) {
			var toRelax = [for (j in 0...3) voronoi.points[j]];
			toRelax.push( voronoi.points[nPatches] );
			voronoi = Voronoi.relax( voronoi, toRelax );
		}

		voronoi.points.sort( function( p1:Point, p2:Point )
			return MathUtils.sign( p1.length - p2.length ) );
		var regions = voronoi.partioning();

		patches = [];
		inner = [];

		var count = 0;
		for (r in regions) {
			var patch = Patch.fromRegion( r );
			patches.push( patch );

			if (count == 0) {
				center = patch.shape.min( function( p:Point ) return p.length );
				if (plazaNeeded)
					plaza = patch;
			} else if (count == nPatches && citadelNeeded) {
				citadel = patch;
				citadel.withinCity = true;
			}

			if (count < nPatches) {
				patch.withinCity = true;
				patch.withinWalls = wallsNeeded;
				inner.push( patch );
			}

			count++;
		}
	}

	private function buildWalls():Void {
		var reserved = citadel != null ? citadel.shape.copy() : [];

		border = new CurtainWall( wallsNeeded, this, inner, reserved );
		if (wallsNeeded) {
			wall = border;
			wall.buildTowers();
		}

		var radius = border.getRadius();
		patches = patches.filter( function( p:Patch ) return p.shape.distance( center ) < radius * 3 );

		gates = border.gates;

		if (citadel != null) {
			var castle = new Castle( this, citadel );
			castle.wall.buildTowers();
			citadel.ward = castle;

			if (citadel.shape.compactness < 0.75)
				throw new Error( "Bad citadel shape!" );

			gates = gates.concat( castle.wall.gates );
		}
	}

	public static function findCircumference( wards:Array<Patch> ):Polygon {
		if (wards.length == 0)
			return new Polygon()
		else if (wards.length == 1)
			return new Polygon( wards[0].shape );

		var A:Array<Point> = [];
		var B:Array<Point> = [];

		for (w1 in wards)
			w1.shape.forEdge( function(a, b ) {
				var outerEdge = true;
				for (w2 in wards)
					if (w2.shape.findEdge( b, a ) != -1) {
						outerEdge = false;
						break;
					}
				if (outerEdge) {
					A.push( a );
					B.push( b );
				}
			} );

		var result = new Polygon();
		var index = 0;
		do {
			result.push( A[index] );
			index = A.indexOf( B[index] );
		} while (index != 0);

		return result;
	}

	public function patchByVertex( v:Point ):Array<Patch> {
		return patches.filter(
			function( patch:Patch ) return patch.shape.contains( v )
		);
	}

	private function buildStreets():Void {

		function smoothStreet( street:Street ):Void {
			var smoothed = street.smoothVertexEq( 3 );
			for (i in 1...street.length-1)
				street[i].set( smoothed[i] );
		}

		topology = new Topology( this );

		for (gate in gates) {
			// Each gate is connected to the nearest corner of the plaza or to the central junction
			var end:Point = plaza != null ?
				plaza.shape.min( function( v ) return Point.distance( v, gate ) ) :
				center;

			var street = topology.buildPath( gate, end, topology.outer );
			if (street != null) {
				streets.push( street );

				if (border.gates.contains( gate )) {
					var dir = gate.norm( 1000 );
					var start = null;
					var dist = Math.POSITIVE_INFINITY;
					for (p in topology.node2pt) {
						var d = Point.distance( p, dir );
						if (d < dist) {
							dist = d;
							start = p;
						}
					}

					var road = topology.buildPath( start, gate, topology.inner );
					if (road != null)
						roads.push( road );
				}
			} else
				throw new Error( "Unable to build a street!" );
		}

		tidyUpRoads();

		for (a in arteries)
			smoothStreet( a );
	}

	private function tidyUpRoads() {
		var segments = new Array<Segment>();
		function cut2segments( street:Street ) {
			var v0:Point = null;
			var v1:Point = street[0];
			for (i in 1...street.length) {
				v0 = v1;
				v1 = street[i];

				// Removing segments which go along the plaza
				if (plaza != null && plaza.shape.contains( v0 ) && plaza.shape.contains( v1 ))
					continue;

				var exists = false;
				for (seg in segments)
					if (seg.start == v0 && seg.end == v1) {
						exists = true;
						break;
					}

				if (!exists)
					segments.push( new Segment( v0, v1 ) );
			}
		}

		for (street in streets)
			cut2segments( street );
		for (road in roads)
			cut2segments( road );

		arteries = [];
		while (segments.length > 0) {
			var seg = segments.pop();

			var attached = false;
			for (a in arteries)
				if (a[0] == seg.end) {
					a.unshift( seg.start );
					attached = true;
					break;
				} else if (a.last() == seg.start) {
					a.push( seg.end );
					attached = true;
					break;
				}

			if (!attached)
				arteries.push( [seg.start, seg.end] );
		}
	}

	private function optimizeJunctions():Void {

		var patchesToOptimize:Array<Patch> =
			citadel == null ? inner : inner.concat( [citadel] );

		var wards2clean:Array<Patch> = [];
		for (w in patchesToOptimize) {
			var index = 0;
			while (index < w.shape.length) {

				var v0:Point = w.shape[index];
				var v1:Point = w.shape[(index + 1) % w.shape.length];

				if (v0 != v1 && Point.distance( v0, v1 ) < 8) {
					for (w1 in patchByVertex( v1 )) if (w1 != w) {
						w1.shape[w1.shape.indexOf( v1 )] = v0;
						wards2clean.push( w1 );
					}

					v0.addEq( v1 );
					v0.scaleEq( 0.5 );

					w.shape.remove( v1 );
				}
				index++;
			}
		}

		// Removing duplicate vertices
		for (w in wards2clean)
			for (i in 0...w.shape.length) {
				var v = w.shape[i];
				var dupIdx;
				while ((dupIdx = w.shape.indexOf( v, i + 1 )) != -1)
					w.shape.splice( dupIdx, 1 );
			}
	}

	private function createWards():Void {
		var unassigned = inner.copy();
		if (plaza != null) {
			plaza.ward = new Market( this, plaza );
			unassigned.remove( plaza );
		}

		// Assigning inner city gate wards
		for (gate in border.gates)
			for (patch in patchByVertex( gate ))
				if (patch.withinCity && patch.ward == null && Random.bool( wall == null ? 0.2 : 0.5 )) {
					patch.ward = new GateWard( this, patch );
					unassigned.remove( patch );
				}

		var wards = WARDS.copy();
		// some shuffling
		for (i in 0...Std.int(wards.length / 10)) {
			var index = Random.int( 0, (wards.length - 1) );
			var tmp = wards[index];
			wards[index] = wards[index + 1];
			wards[index+1] = tmp;
		}

		// Assigning inner city wards
		while (unassigned.length > 0) {
			var bestPatch:Patch = null;

			var wardClass = wards.length > 0 ? wards.shift() : Slum;
			var rateFunc = Reflect.field( wardClass, "rateLocation" );

			if (rateFunc == null)
				do
					bestPatch = unassigned.random()
				while (bestPatch.ward != null);
			else
				bestPatch = unassigned.min( function( patch:Patch ) {
					return patch.ward == null ? Reflect.callMethod( wardClass, rateFunc, [this, patch] ) : Math.POSITIVE_INFINITY;
				} );

			bestPatch.ward = Type.createInstance( wardClass, [this, bestPatch] );

			unassigned.remove( bestPatch );
		}

		// Outskirts
		if (wall != null)
			for (gate in wall.gates) if (!Random.bool( 1 / (nPatches - 5) )) {
				for (patch in patchByVertex( gate ))
					if (patch.ward == null) {
						patch.withinCity = true;
						patch.ward = new GateWard( this, patch );
					}
			}

		// Calculating radius and processing countryside
		cityRadius = 0;
		for (patch in patches)
			if (patch.withinCity)
				// Radius of the city is the farthest point of all wards from the center
				for (v in patch.shape)
					cityRadius = Math.max( cityRadius, v.length );
			else if (patch.ward == null)
				patch.ward = Random.bool( 0.2 ) && patch.shape.compactness >= 0.7 ?
					new Farm( this, patch ) :
					new Ward( this, patch );
	}

	private function buildGeometry()
		for (patch in patches)
			patch.ward.createGeometry();


	public function getNeighbour( patch:Patch, v:Point ):Patch {
		var next = patch.shape.next( v );
		for (p in patches)
			if (p.shape.findEdge( next, v ) != -1)
				return p;
		return null;
	}

	public function getNeighbours( patch:Patch ):Array<Patch>
		return patches.filter( function( p:Patch ) return p != patch && p.shape.borders( patch.shape ) );

	// A ward is "enclosed" if it belongs to the city and
	// it's surrounded by city wards and water
	public function isEnclosed( patch:Patch ):Bool {
		return patch.withinCity && (patch.withinWalls || getNeighbours( patch ).every( function( p:Patch ) return p.withinCity ));
	}
}
