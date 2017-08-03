package com.watabou.geom;

import openfl.geom.Point;
import com.watabou.utils.MathUtils;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class Voronoi {

	public var triangles 	: Array<Triangle>;

	public var regions(get,never)	: Map<Point, Region>;
	private var _regionsDirty	: Bool;
	private var _regions		: Map<Point, Region>;

	public var points	: Array<Point>;
	public var frame	: Array<Point>;

	public function new( minx:Float, miny:Float, maxx:Float, maxy:Float ) {
		triangles = [];

		var c1 = new Point( minx, miny );
		var c2 = new Point( minx, maxy );
		var c3 = new Point( maxx, miny );
		var c4 = new Point( maxx, maxy );
		frame = [c1, c2, c3, c4];
		points = [c1, c2, c3, c4];
		triangles.push( new Triangle( c1, c2, c3 ) );
		triangles.push( new Triangle( c2, c3, c4 ) );

		// Maybe we shouldn't do it beause these temporary
		// regions will be discarded anyway
		_regions = [for (p in points) p => buildRegion( p )];
		_regionsDirty = false;
	}

	/**
	* Adds a point to the list and updates the list of triangles
	* @param p a point to add
	**/
	public function addPoint( p:Point ) {
		var toSplit:Array<Triangle> = [];
		for (tr in triangles)
			if (Point.distance( p, tr.c ) < tr.r)
				toSplit.push( tr );

		if (toSplit.length > 0) {

			points.push( p );

			var a:Array<Point> = [];
			var b:Array<Point> = [];
			for (t1 in toSplit) {
				var e1 = true;
				var e2 = true;
				var e3 = true;
				for (t2 in toSplit) if (t2 != t1) {
					// If triangles have a common edge, it goes in opposite directions
					if (e1 && t2.hasEdge( t1.p2, t1.p1 )) e1 = false;
					if (e2 && t2.hasEdge( t1.p3, t1.p2 )) e2 = false;
					if (e3 && t2.hasEdge( t1.p1, t1.p3 )) e3 = false;
					if (!(e1 || e2 || e3)) break;
				}
				if (e1) { a.push( t1.p1 ); b.push( t1.p2 ); }
				if (e2) { a.push( t1.p2 ); b.push( t1.p3 ); }
				if (e3) { a.push( t1.p3 ); b.push( t1.p1 ); }
			}

			var index = 0;
			do {
				triangles.push( new Triangle( p, a[index], b[index] ) );
				index = a.indexOf( b[index] );
			} while (index != 0);

			for (tr in toSplit)
				triangles.remove( tr );

			_regionsDirty = true;
		}
	}

	private function buildRegion( p:Point ):Region {
		var r = new Region( p );
		for (tr in triangles)
			if (tr.p1 == p || tr.p2 == p || tr.p3 == p)
				r.vertices.push( tr );

		return r.sortVertices();
	}

	public function get_regions():Map<Point, Region> {
		if (_regionsDirty) {
			_regions = new Map();
			_regionsDirty = false;
			for (p in points)
				_regions[p] = buildRegion( p );
		}
		return _regions;
	}

	/**
	* Checks if neither of a triangle's vertices is a frame point
	**/
	private inline function isReal( tr:Triangle ):Bool
		return !(frame.contains( tr.p1 ) || frame.contains( tr.p2 ) || frame.contains( tr.p3 ));

	/**
	* Returns triangles which do not contain "frame" points as their vertices
	* @return List of triangles
	**/
	public function triangulation():Array<Triangle>
		return triangles.filter( isReal );

	public function partioning():Array<Region> {
		// Iterating over points, not regions, to use points ordering
		var result:Array<Region> = [];
		for (p in points) {
			var r = regions[p];
			var isReal = true;
			for (v in r.vertices)
				if (!this.isReal( v )) {
					isReal = false;
					break;
				}

			if (isReal)
				result.push( r );
		}
		return result;
	}

	public function getNeighbours( r1:Region ):Array<Region>
		return [for (r2 in regions.iterator()) if (r1.borders( r2 )) r2];

	public static function relax( voronoi:Voronoi, toRelax:Array<Point>=null ):Voronoi {
		var regions = voronoi.partioning();

		var points = voronoi.points.copy();
		for (p in voronoi.frame) points.remove( p );

		if (toRelax == null) toRelax = voronoi.points;
		for (r in regions)
			if (toRelax.contains( r.seed )) {
				points.remove( r.seed );
				points.push( r.center() );
			}

		return build( points );
	}

	public static function build( vertices:Array<Point> ):Voronoi {
		var minx = 1e+10;
		var miny = 1e+10;
		var maxx = -1e+9;
		var maxy = -1e+9;
		for (v in vertices) {
			if (v.x < minx) minx = v.x;
			if (v.y < miny) miny = v.y;
			if (v.x > maxx) maxx = v.x;
			if (v.y > maxy) maxy = v.y;
		}
		var dx = (maxx - minx) * 0.5;
		var dy = (maxy - miny) * 0.5;

		var voronoi = new Voronoi( minx - dx/2, miny - dy/2, maxx + dx/2, maxy + dy/2 );
		for (v in vertices)
			voronoi.addPoint( v );

		return voronoi;
	}
}

class Triangle {

	public var p1 : Point;
	public var p2 : Point;
	public var p3 : Point;

	public var c : Point;
	public var r : Float;

	public function new( p1:Point, p2:Point, p3:Point ) {
		var s = (p2.x - p1.x) * (p2.y + p1.y) + (p3.x - p2.x) * (p3.y + p2.y) + (p1.x - p3.x) * (p1.y + p3.y);
		this.p1 = p1;
		// CCW
		this.p2 = s > 0 ? p2 : p3;
		this.p3 = s > 0 ? p3 : p2;

		var x1 = (p1.x + p2.x) / 2;
		var y1 = (p1.y + p2.y) / 2;
		var x2 = (p2.x + p3.x) / 2;
		var y2 = (p2.y + p3.y) / 2;

		var dx1 = p1.y - p2.y;
		var dy1 = p2.x - p1.x;
		var dx2 = p2.y - p3.y;
		var dy2 = p3.x - p2.x;

		var tg1 = dy1 / dx1;
		var t2 = ((y1 - y2) - (x1 - x2) * tg1) /
					(dy2 - dx2 * tg1);

		c = new Point( x2 + dx2 * t2, y2 + dy2 * t2 );
		r = Point.distance( c, p1 );
	}

	public function hasEdge( a:Point, b:Point ):Bool
		return
			(p1 == a && p2 == b) ||
			(p2 == a && p3 == b) ||
			(p3 == a && p1 == b);
}

class Region {
	public var seed 	: Point;
	public var vertices	: Array<Triangle>;

	public inline function new ( seed:Point ) {
		this.seed = seed;
		vertices = [];
	}

	public function sortVertices():Region {
		vertices.sort( compareAngles );
		return this;
	}

	public function center():Point {
		var c = new Point();
		for (v in vertices) c.addEq( v.c );
		c.scaleEq( 1 / vertices.length );
		return c;
	}

	public function borders( r:Region ):Bool {
		var len1 = vertices.length;
		var len2 = r.vertices.length;
		for (i in 0...len1) {
			var j = r.vertices.indexOf( vertices[i] );
			if (j != -1)
				return vertices[(i + 1) % len1] == r.vertices[(j + len2 - 1) % len2];
		}
		return false;
	}

	private function compareAngles( v1:Triangle, v2:Triangle ):Int {
	//	return MathUtils.sign( v1.c.subtract( seed ).atan() - v2.c.subtract( seed ).atan() );
		var x1 = v1.c.x - seed.x;
		var y1 = v1.c.y - seed.y;
		var x2 = v2.c.x - seed.x;
		var y2 = v2.c.y - seed.y;

		if (x1 >= 0 && x2 < 0) return 1;
		if (x2 >= 0 && x1 < 0) return -1;
		if (x1 == 0 && x2 == 0)
			return y2 > y1 ? 1 : -1;

		return MathUtils.sign( x2 * y1 - x1 * y2 );
	}
}