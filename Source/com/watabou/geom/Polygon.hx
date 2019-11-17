package com.watabou.geom;

import openfl.geom.Point;
import openfl.geom.Rectangle;
import com.watabou.utils.MathUtils;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

@:forward
abstract Polygon(Array<Point>) from Array<Point> to Array<Point> {

	private static inline var DELTA = 0.000001;

	public function new( vertices:Array<Point>=null ) {
		this = (vertices != null ? vertices.copy() : []);
	}

	public function set( p:Polygon )
		for (i in 0...p.length)
			this[i].set( p[i] );

	public var square(get,never) : Float;
	public function get_square():Float {
		var v1 = this.last();
		var v2 = this[0];
		var s = v1.x * v2.y - v2.x * v1.y;
		for (i in 1...this.length) {
			v1 = v2;
			v2 = this[i];
			s += (v1.x * v2.y - v2.x * v1.y);
		}
		return s * 0.5;
	}

	public var perimeter(get,never) : Float;
	public function get_perimeter():Float {
		var len = 0.0;
		forEdge( function( v0:Point, v1:Point ) {
			len += Point.distance( v0, v1 );
		} );
		return len;
	}

	// for circle	= 1.00
	// for square	= 0.79
	// for triangle	= 0.60
	public var compactness(get,never) : Float;
	public function get_compactness():Float {
		var p = perimeter;
		return 4 * Math.PI * square / (p * p);
	}

	// Faster approximation of centroid
	public var center(get,never) : Point;
	public function get_center():Point {
		var c = new Point();
		for (v in this)
			c.addEq( v );
		c.scaleEq( 1 / this.length );
		return c;
	}

	public var centroid(get,never) : Point;
	public function get_centroid():Point {
		var x = 0.0;
		var y = 0.0;
		var a = 0.0;
		forEdge( function( v0:Point, v1:Point ):Void {
			var f = GeomUtils.cross( v0.x, v0.y, v1.x, v1.y );
			a += f;
			x += (v0.x + v1.x) * f;
			y += (v0.y + v1.y) * f;
		} );
		var s6 = 1 / (3 * a);
		return new Point( s6 * x, s6 * y );
	}

	public inline function contains( v:Point ):Bool {
		return this.indexOf( v ) != -1;
	}

	public function forEdge( f:Point->Point->Void ):Void {
		var len = this.length;
		for (i in 0...len)
			f( this[i], this[(i + 1) % len] );
	}

	// Similar to forEdge, but doesn't iterate over the v(n)-v(0)
	public function forSegment( f:Point->Point->Void ):Void
		for (i in 0...this.length-1)
			f( this[i], this[i + 1] );

	public function offset( p:Point ):Void {
		var dx = p.x;
		var dy = p.y;
		for (v in this) {
			v.offset( dx, dy );
		}
	}

	public function rotate( a:Float ):Void {
		var cosA = Math.cos( a );
		var sinA = Math.sin( a );
		for (v in this) {
			var vx = v.x * cosA - v.y * sinA;
			var vy = v.y * cosA + v.x * sinA;
			v.setTo( vx, vy );
		}
	}

	public function isConvexVertexi( i:Int ):Bool {
		var len = this.length;
		var v0 = this[(i + len - 1) % len];
		var v1 = this[i];
		var v2 = this[(i + 1) % len];
		return GeomUtils.cross( v1.x - v0.x, v1.y - v0.y, v2.x - v1.x, v2.y - v1.y ) > 0;
	}

	public function isConvexVertex( v1:Point ):Bool {
		var v0 = prev( v1 );
		var v2 = next( v1 );
		return GeomUtils.cross( v1.x - v0.x, v1.y - v0.y, v2.x - v1.x, v2.y - v1.y ) > 0;
	}

	public function isConvex():Bool {
		for (v in this)
			if (!isConvexVertex( v )) return false;
		return true;
	}

	public function smoothVertexi( i:Int, f=1.0 ):Point {
		var v = this[i];
		var len = this.length;
		var prev = this[(i + len - 1) % len];
		var next = this[(i + 1) % len];
		var result = new Point(
			(prev.x + v.x * f + next.x) / (2 + f),
			(prev.y + v.y * f + next.y) / (2 + f)
		);
		return result;
	}

	public function smoothVertex( v:Point, f=1.0 ):Point {
		var prev = prev( v );
		var next = next( v );
		return new Point(
			prev.x + v.x * f + next.x,
			prev.y + v.y * f + next.y
		).scale( 1 / (2 + f) );
	}

	// This function returns minimal distance from any of the vertices
	// to a point, not real distance from the polygon
	public function distance( p:Point ):Float {
		var v0 = this[0];
		var d = Point.distance( v0, p );
		for (i in 1...this.length) {
			var v1 = this[i];
			var d1 = Point.distance( v1, p );
			if (d1 < d) v0 = v1;
		}
		return d;
	}

	public function smoothVertexEq( f=1.0 ):Polygon {
		var len = this.length;
		var v1 = this[len-1];
		var v2 = this[0];
		return [for (i in 0...len) {
			var v0 = v1; v1 = v2; v2 = this[(i + 1) % len];
			new Point(
				(v0.x + v1.x * f + v2.x) / (2 + f),
				(v0.y + v1.y * f + v2.y) / (2 + f)
			);
		}];
	}

	public function filterShort( threshold:Float ):Polygon {
		var i = 1;
		var v0 = this[0];
		var v1 = this[1];
		var result = [v0];
		do {
			do {
				v1 = this[i++];
			} while (Point.distance( v0, v1 ) < threshold && i < this.length);
			result.push( v0 = v1 );
		} while (i < this.length);

		return result;
	}

	// This function insets one edge defined by its first vertex.
	// It's not very relyable, but it usually works (better for convex
	// vertices than for concave ones). It doesn't change the number
	// of vertices.
	public function inset( p1:Point, d:Float ):Void {
		var i1 = this.indexOf( p1 );
		var i0 = (i1 > 0 ? i1 - 1 : this.length - 1); var p0 = this[i0];
		var i2 = (i1 < this.length - 1 ? i1 + 1 : 0); var p2 = this[i2];
		var i3 = (i2 < this.length - 1 ? i2 + 1 : 0); var p3 = this[i3];

		var v0:Point = p1.subtract( p0 );
		var v1:Point = p2.subtract( p1 );
		var v2:Point = p3.subtract( p2 );

		var cos = v0.dot( v1 ) / v0.length / v1.length;
		var z = v0.x * v1.y - v0.y * v1.x;
		var t = d / Math.sqrt( 1 - cos * cos ); // sin( acos( cos ) )
		if (z > 0) {
			t = Math.min( t, v0.length * 0.99 );
		} else {
			t = Math.min( t, v1.length * 0.5 );
		}
		t *= MathUtils.sign( z );
		this[i1] = p1.subtract( v0.norm( t ) );

		cos = v1.dot( v2 ) / v1.length / v2.length;
		z = v1.x * v2.y - v1.y * v2.x;
		t = d / Math.sqrt( 1 - cos * cos );
		if (z > 0) {
			t = Math.min( t, v2.length * 0.99 );
		} else {
			t = Math.min( t, v1.length * 0.5 );
		}
		this[i2] = p2.add( v2.norm( t ) );
	}

	public function insetAll( d:Array<Float> ):Polygon {
		var p = new Polygon( this );
		for (i in 0...p.length)
			if (d[i] != 0) p.inset( p[i], d[i] );
		return p;
	}

	// This function insets all edges by the same distance
	public function insetEq( d:Float ):Void
		for (i in 0...this.length)
			inset( this[i], d );

	// This function insets all edges by distances defined in an array.
	// It's kind of reliable for both convex and concave vertices, but only
	// if all distances are equal. Otherwise weird "steps" are created.
	// It does change the number of vertices.
	public function buffer( d:Array<Float> ):Polygon {
		// Creating a polygon (probably invalid) with offset edges
		var q = new Polygon();
		var i = 0;
		forEdge( function( v0:Point, v1:Point ) {
			var dd = d[i++];
			if (dd == 0) {
				q.push( v0 );
				q.push( v1 );
			} else {
				// here we may want to do something fancier for nicer joints
				var v = v1.subtract( v0 );
				var n = v.rotate90().norm( dd );
				q.push( v0.add( n ) );
				q.push( v1.add( n ) );
			}
		} );

		// Creating a valid polygon by dealing with self-intersection:
		// we need to find intersections of every edge with every other edge
		// and add intersection point (twice - for one edge and for the other)
		var wasCut:Bool;
		var lastEdge = 0;
		do {
			wasCut = false;

			var n = q.length;
			for (i in lastEdge...n-2) {
				lastEdge = i;

				var p11 = q[i];
				var p12 = q[i + 1];
				var x1 = p11.x;
				var y1 = p11.y;
				var dx1 = p12.x - x1;
				var dy1 = p12.y - y1;

				for (j in i+2...(i > 0 ? n : n-1)) {
					var p21 = q[j];
					var p22 = j < n-1 ? q[j + 1] : q[0];
					var x2 = p21.x;
					var y2 = p21.y;
					var dx2 = p22.x - x2;
					var dy2 = p22.y - y2;

					var int = GeomUtils.intersectLines( x1, y1, dx1, dy1, x2, y2, dx2, dy2 );
					if (int != null && int.x > DELTA && int.x < 1-DELTA && int.y > DELTA && int.y < 1-DELTA) {
						var pn = new Point( x1 + dx1 * int.x, y1 + dy1 * int.x );

						q.insert( j + 1, pn );
						q.insert( i + 1, pn );

						wasCut = true;
						break;
					}
				}
				if (wasCut) break;
			}

		} while (wasCut);


		// Checking every part of the polygon to pick the biggest
		var regular = [for (i in 0...q.length) i];

		var bestPart = null;
		var bestPartSq = Math.NEGATIVE_INFINITY;

		while (regular.length > 0) {
			var indices:Array<Int> = [];
			var start = regular[0];
			var i = start;
			do {
				indices.push( i );
				regular.remove( i );

				var next = (i + 1) % q.length;
				var v = q[next];
				var next1 = q.indexOf( v );
				if (next1 == next)
					next1 = q.lastIndexOf( v );
				i = next1 == -1 ? next : next1;
			} while (i != start);

			var p:Polygon = [for (i in indices) q[i]];
			var s = p.square;
			if (s > bestPartSq) {
				bestPart = p;
				bestPartSq = s;
			}
		}

		return bestPart;
	}

	// Another version of "buffer" function for insetting all edges
	// by the same distance (it's the best use of that function anyway)
	public function bufferEq( d:Float ):Polygon
		return buffer( [for (vv in this) d] );

	// This function insets all edges by distances defined in an array.
	// It can't outset a polygon. Works very well for convex polygons,
	// not so much concaqve ones. It produces a convex polygon.
	// It does change the number vertices
	public function shrink( d:Array<Float> ):Polygon {
		var q = new Polygon( this );
		var i = 0;
		forEdge( function( v1:Point, v2:Point ) {
			var dd = d[i++];
			if (dd > 0) {
				var v = v2.subtract( v1 );
				var n = v.rotate90().norm( dd );
				q = q.cut( v1.add( n ), v2.add( n ), 0 )[0];
			}
		} );
		return q;
	}

	public function shrinkEq( d:Float ):Polygon
		return shrink( [for (v in this) d] );

	// A version of "shrink" function for insetting just one edge.
	// It effectively cuts a peel along the edge.
	public function peel( v1:Point, d:Float ):Polygon {
		var i1 = this.indexOf( v1 );
		var i2 = i1 == this.length-1 ? 0 : i1 + 1;
		var v2:Point = this[i2];

		var v = v2.subtract( v1 );
		var n = v.rotate90().norm( d );

		return cut( v1.add( n ), v2.add( n ), 0 )[0];
	}

	// Simplifies the polygons leaving only n vertices
	public function simplyfy( n:Int ) {
		var len = this.length;
		while (len > n) {

			var result = 0;
			var min = Math.POSITIVE_INFINITY;

			var b = this[len - 1];
			var c = this[0];
			for (i in 0...len) {
				var a = b; b = c; c = this[(i + 1) % len];
				var measure = Math.abs( a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y) );
				if (measure < min) {
					result = i;
					min = measure;
				}
			}

			this.splice( result, 1 );
			len--;
		}
	}

	public function findEdge( a:Point, b:Point ):Int {
		var index = this.indexOf( a );
		return (index != -1 && this[(index + 1) % this.length] == b ? index : -1);
	}

	public inline function next( a:Point ):Point {
		return this[(this.indexOf( a ) + 1) % this.length];
	}

	public inline function prev( a:Point ):Point {
		return this[(this.indexOf( a ) + this.length - 1) % this.length];
	}

	public inline function vector( v:Point ):Point
		return next( v ).subtract( v );

	public inline function vectori( i:Int ):Point
		return this[i == this.length-1 ? 0 : i+1].subtract( this[i] );

	public function borders( another:Polygon ):Bool {
		var len1 = this.length;
		var len2 = another.length;
		for (i in 0...len1) {
			var j = another.indexOf( this[i] );
			if (j != -1) {
				var next = this[(i + 1) % len1];
				// If this cause is not true, then should return false,
				// but it doesn't work for some reason
				if (next == another[(j + 1) % len2] ||
					next == another[(j + len2 - 1) % len2]) return true;
			}
		}
		return false;
	}

	public function getBounds():Rectangle {
		var rect = new Rectangle( this[0].x, this[0].y );
		for (v in this) {
			rect.left	= Math.min( rect.left, v.x );
			rect.right	= Math.max( rect.right, v.x );
			rect.top	= Math.min( rect.top, v.y );
			rect.bottom	= Math.max( rect.bottom, v.y );
		}
		return rect;
	}

	public function split( p1:Point, p2:Point ):Array<Polygon>
		return spliti( this.indexOf( p1 ), this.indexOf( p2 ));

	public function spliti( i1:Int, i2:Int ):Array<Polygon> {
		if (i1 > i2) {
			var t = i1; i1 = i2; i2 = t;
		}

		return [
			new Polygon( this.slice( i1, i2 + 1 ) ),
			new Polygon( this.slice( i2 ).concat( this.slice( 0, i1 + 1 ) ) )
		];
	}

	public function cut( p1:Point, p2:Point, gap:Float=0 ):Array<Polygon> {
		var x1 = p1.x;
		var y1 = p1.y;
		var dx1 = p2.x - x1;
		var dy1 = p2.y - y1;

		var len = this.length;
		var edge1 = 0, ratio1 = 0.0;
		var edge2 = 0, ratio2 = 0.0;
		var count = 0;

		for (i in 0...len) {
			var v0 = this[i];
			var v1 = this[(i + 1) % len];

			var x2 = v0.x;
			var y2 = v0.y;
			var dx2 = v1.x - x2;
			var dy2 = v1.y - y2;

			var t = GeomUtils.intersectLines( x1, y1, dx1, dy1, x2, y2, dx2, dy2 );
			if (t != null && t.y >= 0 && t.y <= 1) {
				switch (count) {
					case 0: edge1 = i; ratio1 = t.x;
					case 1: edge2 = i; ratio2 = t.x;
				}
				count++;
			}
		}

		if (count == 2) {
			var point1 = p1.add( p2.subtract( p1 ).scale( ratio1 ) );
			var point2 = p1.add( p2.subtract( p1 ).scale( ratio2 ) );

			var half1 = new Polygon( this.slice( edge1 + 1, edge2 + 1 ) );
			half1.unshift( point1 );
			half1.push( point2 );

			var half2 = new Polygon( this.slice( edge2 + 1 ).concat( this.slice( 0, edge1 + 1 ) ) );
			half2.unshift( point2 );
			half2.push( point1 );

			if (gap > 0) {
				half1 = half1.peel( point2, gap/2 );
				half2 = half2.peel( point1, gap/2 );
			}

			var v = vectori( edge1 );
			return GeomUtils.cross( dx1, dy1, v.x, v.y ) > 0 ? [half1, half2] : [half2, half1];
		} else
			return [new Polygon( this )];
	}

	public function interpolate( p:Point ):Array<Float> {
		var sum = 0.0;
		var dd = [for (v in this) {
			var d = 1 / Point.distance( v, p );
			sum += d;
			d;
		}] ;
		return [for (d in dd) d / sum];
	}

	public static function rect( w=1.0, h=1.0 ):Polygon
		return new Polygon( [
			new Point( -w/2, -h/2 ),
			new Point( w/2, -h/2 ),
			new Point( w/2, h/2 ),
			new Point( -w/2, h/2 )] );

	public static function regular( n=8, r=1.0 ):Polygon
		return new Polygon( [for (i in 0...n) {
			var a = i / n * Math.PI * 2;
			new Point( r * Math.cos( a ), r * Math.sin( a ) );
		} ] );

	public static inline function circle( r=1.0 ):Polygon
		return regular( 16, r );
}