package com.watabou.geom;

import openfl.geom.Point;

class Segment {
	public var start	: Point;
	public var end		: Point;

	public inline function new( start:Point, end:Point ) {
		this.start 	= start;
		this.end	= end;
	}

	public var dx(get,null)	: Float;
	public inline function get_dx() return (end.x - start.x);

	public var dy(get,null)	: Float;
	public inline function get_dy() return (end.y - start.y);

	public var vector(get,null)	: Point;
	public inline function get_vector() return end.subtract( start );

	public var length(get,null)	: Float;
	public inline function get_length() return Point.distance( start, end );
}