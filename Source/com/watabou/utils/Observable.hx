package com.watabou.utils;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

class Observable<T> {

	private var _value : T;

	public var value( get, set ) : T;

	public var changed : Signal1<T> = new Signal1();

	public function new( v:T ) {
		_value = v;
	}

	private function get_value():T {
		return _value;
	}

	private function set_value( v:T ):T {
		_value = v;
		changed.dispatch( _value );
		return _value;
	}
}

class ObservableInt extends Observable<Int> {

	private var min : Int;
	private var max : Int;

	public var changed2 : Signal2<Int, Int> = new Signal2();

	public function new( v:Int, min:Int, max:Int ) {
		super( v );
		this.min = min;
		this.max = max;
	}

	override private function set_value( v:Int ):Int {
		var old = _value;
		v = MathUtils.gatei( v, min, max );
		changed2.dispatch( v, v - old );
		return super.set_value( v );
	}
}