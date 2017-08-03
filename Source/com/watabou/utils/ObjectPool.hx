package com.watabou.utils;

private typedef Constructible = {
	public function new():Void;
}

@:generic
class ObjectPool<T:Constructible> {

	private var recycled : Array<T>;

	public function new() {
		recycled = [];
	}

	public function get():T {
		var obj = recycled.pop();
		if (obj == null) {
			obj = new T();
		}
		return obj;
	}

	public function recycle( obj:T ):Void {
		recycled.push( obj );
	}

	public function clear():Void {
		recycled = [];
	}
}