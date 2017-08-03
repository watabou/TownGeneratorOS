package com.watabou.geom;

using com.watabou.utils.ArrayExtender;

class Graph {

	public var nodes : Array<Node> = [];

	public function new() {
	}

	public function add( node:Node=null ):Node {
		if (node == null) {
			node = new Node();
		}
		nodes.push( node );
		return node;
	}

	public function remove( node:Node ):Void {
		node.unlinkAll();
		nodes.remove( node );
	}

	public function aStar( start:Node, goal:Node, exclude:Array<Node>=null ):Array<Node> {
		var closedSet:Array<Node> = exclude != null ? exclude.copy() : [];
		var openSet:Array<Node> = [start];
		var cameFrom:Map<Node, Node> = new Map();

		var gScore:Map<Node, Float> = [start => 0];

		while (openSet.length > 0) {
			var current = openSet.shift();
			if (current == goal)
				return buildPath( cameFrom, current );

			openSet.remove( current );
			closedSet.push( current );

			var curScore = gScore.get( current );
			for (neighbour in current.links.keys()) {
				if (closedSet.contains( neighbour ))
					continue;

				var score = curScore + current.links.get( neighbour );
				if (!openSet.contains( neighbour ))
					openSet.push( neighbour );
				else if (score >= gScore.get( neighbour ))
					continue;

				cameFrom.set( neighbour, current );
				gScore.set( neighbour, score );
			}
		}

		return null;
	}

	private function buildPath( cameFrom:Map<Node, Node>, current:Node ):Array<Node> {
		var path = [current];

		while (cameFrom.exists( current ))
			path.push( current = cameFrom.get( current ) );

		return path;
	}

	public function calculatePrice( path:Array<Node> ):Float {
		if (path.length < 2) {
			return 0;
		}

		var price = 0.0;
		var current = path[0];
		var next = path[1];
		for (i in 0...path.length-1) {
			if (current.links.exists( next )) {
				price += current.links.get( next );
			} else {
				return Math.NaN;
			}
			current = next;
			next = path[i + 1];
		}
		return price;
	}
}

class Node {
	public var links : Map<Node, Float> = new Map();

	public function new() {}

	public function link( node:Node, price:Float=1, symmetrical:Bool=true ) {
		links.set( node, price );
		if (symmetrical) {
			node.links.set( this, price );
		}
	}

	public function unlink( node:Node, symmetrical=true ):Void {
		links.remove( node );
		if (symmetrical) {
			node.links.remove( this );
		}
	}

	public function unlinkAll():Void {
		for (node in links.keys()) {
			unlink( node );
		}
	}
}