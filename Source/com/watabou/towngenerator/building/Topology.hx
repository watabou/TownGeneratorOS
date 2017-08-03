package com.watabou.towngenerator.building;

import openfl.geom.Point;
import com.watabou.geom.Graph;

using com.watabou.utils.ArrayExtender;

class Topology {

	private var model	: Model;

	private var graph	: Graph;

	public var pt2node	: Map<Point, Node>;
	public var node2pt	: Map<Node, Point>;

	private var blocked	: Array<Point>;

	public var inner	: Array<Node>;
	public var outer	: Array<Node>;

	public function new( model:Model ) {
		this.model = model;

		graph = new Graph();
		pt2node = new Map();
		node2pt = new Map();

		inner = [];
		outer = [];

		// Building a list of all blocked points (shore + walls excluding gates)
		blocked = [];
		if (model.citadel != null)
			blocked = blocked.concat( model.citadel.shape );
		if (model.wall != null)
			blocked = blocked.concat( model.wall.shape );
		blocked = blocked.difference( model.gates );

		var border = model.border.shape;

		for (p in model.patches) {
			var withinCity = p.withinCity;

			var v1 = p.shape.last();
			var n1 = processPoint( v1 );

			for (i in 0...p.shape.length) {
				var v0 = v1; v1 = p.shape[i];
				var n0 = n1; n1 = processPoint( v1 );

				if (n0 != null && !border.contains( v0 ))
					if (withinCity)
						inner.add( n0 )
					else
						outer.add( n0 );
				if (n1 != null && !border.contains( v1 ))
					if (withinCity )
						inner.add( n1 )
					else
						outer.add( n1 );

				if (n0 != null && n1 != null)
					n0.link( n1, Point.distance( v0, v1 ) );
			}
		}
	}

	private function processPoint( v:Point ):Node {
		var n:Node;

		if (pt2node.exists( v ))
			n = pt2node[v]
		else {
			pt2node[v] = n = graph.add();
			node2pt[n] = v;
		}

		return blocked.contains( v ) ? null : n;
	}

	public function buildPath( from:Point, to:Point, exclude:Array<Node>=null ):Array<Point> {
		var path = graph.aStar( pt2node[from], pt2node[to], exclude );
		return path == null ? null : [for (n in path) node2pt[n]];
	}
}
