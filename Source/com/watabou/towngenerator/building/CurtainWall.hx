package com.watabou.towngenerator.building;

import openfl.errors.Error;
import openfl.geom.Point;

import com.watabou.geom.Polygon;
import com.watabou.utils.Random;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.PointExtender;

class CurtainWall {

	public var shape	: Polygon;
	public var segments	: Array<Bool>;
	public var gates	: Array<Point>;
	public var towers	: Array<Point>;

	private var real	: Bool;
	private var patches	: Array<Patch>;

	public function new( real:Bool, model:Model, patches:Array<Patch>, reserved:Array<Point> ) {
		this.real = true;
		this.patches = patches;

		if (patches.length == 1)
			shape = patches[0].shape
		else {
			shape = Model.findCircumference( patches );

			if (real) {
				var smoothFactor = Math.min( 1, 40 / patches.length );
				shape.set( [for (v in shape)
					reserved.contains( v ) ? v : shape.smoothVertex( v, smoothFactor )
				] );
			}
		}

		segments = [for (v in shape) true];

		buildGates( real, model, reserved );
	}

	private function buildGates( real:Bool, model:Model, reserved:Array<Point> ):Void {
		gates = [];

		// Entrances are vertices of the walls with more than 1 adjacent inner ward
		// so that a street could connect it to the city center
		var entrances:Array<Point> = if (patches.length > 1)
			shape.filter( function( v )
				return (!reserved.contains( v ) && patches.count(
					function( p:Patch ) return p.shape.contains( v )
				) > 1) )
		else
			shape.filter( function( v ) return !reserved.contains( v ) );

		if (entrances.length == 0)
			throw new Error( "Bad walled area shape!" );

		do {
			var index = Random.int( 0, entrances.length );
			var gate = entrances[index];
			gates.push( gate );

			if (real) {
				var outerWards = model.patchByVertex( gate ).filter( function( w:Patch ):Bool return !patches.contains( w ) );
				if (outerWards.length == 1) {
					// If there is no road leading from the walled patches,
					// we should make one by splitting an outer ward
					var outer:Patch = outerWards[0];
					if (outer.shape.length > 3) {
						var wall = shape.next( gate ).subtract( shape.prev( gate ) );
						var out = new Point( wall.y, -wall.x );

						var farthest = outer.shape.max( function( v:Point )
							if (shape.contains( v ) || reserved.contains( v ))
								return Math.NEGATIVE_INFINITY;
							else {
								var dir = v.subtract( gate );
								return dir.dot( out ) / dir.length;
							}
						);

						var newPatches = [for (half in outer.shape.split( gate, farthest )) new Patch( half )];
						model.patches.replace( outer, newPatches );
					}
				}
			}

			// Removing neighbouring entrances to ensure
			// that no gates are too close
			if (index == 0) {
				entrances.splice( 0, 2 );
				entrances.pop();
			} else if (index == entrances.length - 1) {
				entrances.splice( index - 1, 2 );
				entrances.shift();
			} else
				entrances.splice( index - 1, 3 );

		} while (entrances.length >= 3);

		if (gates.length == 0)
			throw new Error( "Bad walled area shape!" );

		// Smooth further sections of the wall with gates
		if (real)
			for (gate in gates)
				gate.set( shape.smoothVertex( gate  ) );
	}

	public function buildTowers() {
		towers = [];
		if (real) {
			var len = shape.length;
			for (i in 0...len) {
				var t = shape[i];
				if (!gates.contains( t ) && (segments[(i + len - 1) % len] || segments[i]))
					towers.push( t );
			}
		}
	}

	public function getRadius():Float {
		var radius = 0.0;
		for (v in shape)
			radius = Math.max( radius, v.length );
		return radius;
	}

	public function bordersBy( p:Patch, v0:Point, v1:Point ):Bool {
		var index = patches.contains( p ) ?
			shape.findEdge( v0, v1 ) :
			shape.findEdge( v1, v0 );
		if (index != -1 && segments[index])
			return true;

		return false;
	}

	public function borders( p:Patch ):Bool {
		var withinWalls = patches.contains( p );
		var length = shape.length;

		for (i in 0...length) if (segments[i]) {
			var v0 = shape[i];
			var v1 = shape[(i + 1) % length];
			var index = withinWalls ?
				p.shape.findEdge( v0, v1 ) :
				p.shape.findEdge( v1, v0 );
			if (index != -1)
				return true;
		}

		return false;
	}
}
