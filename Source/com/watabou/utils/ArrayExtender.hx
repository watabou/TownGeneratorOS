package com.watabou.utils;

class ArrayExtender {
	public static function shuffle<T>( a:Array<T> ):Array<T> {
		var result = [];
		for (e in a) {
			result.insert( Std.int( Random.float() * (result.length + 1) ), e );
		}
		return result;
	}

	public static function random<T>( a:Array<T> ):T
		return a[Std.int( Random.float() * a.length )];

	public static function weighted<T>( a:Array<T>, weights:Array<Float> ):T {
		var total = 0.0;
		for (w in weights)
			total += w;

		var z = Random.float() * total;
		var acc = 0.0;
		for (i in 0...a.length)
			if (z <= (acc += weights[i]))
				return a[i];

		return a[0];
	}

	public static inline function contains<T>( a:Array<T>, value:T ):Bool
		return (a.indexOf( value ) != -1);

	public static function isEmpty<T>( a:Array<T> ):Bool
		return (a.length == 0);

	public static inline function last<T>( a:Array<T> )
		return a[a.length - 1];

	public static function min<T>( a:Array<T>, f:T->Float ):T {
		var result = a[0];
		var min = f( result );
		for (i in 1...a.length) {
			var element = a[i];
			var measure = f( element );
			if (measure < min) {
				result = element;
				min = measure;
			}
		}
		return result;
	}

	public static function max<T>( a:Array<T>, f:T->Float ):T {
		var result = a[0];
		var max = f( result );
		for (i in 1...a.length) {
			var element = a[i];
			var measure = f( element );
			if (measure > max) {
				result = element;
				max = measure;
			}
		}
		return result;
	}

	public static function every<T>( a:Array<T>, test:T->Bool ):Bool {
		for (e in a)
			if (!test( e ))
				return false;
		return true;
	}

	public static function some<T>( a:Array<T>, test:T->Bool ):Bool {
		for (e in a)
			if (test( e ))
				return true;
		return false;
	}

	public static function count<T>( a:Array<T>, test:T->Bool ):Int {
		var count = 0;
		for (e in a)
			if (test( e ))
				count++;
		return count;
	}

	public static function map<T, S>( a:Array<T>, f:T->S):Array<S>
		return [for (el in a) f( el )];

	public static function replace<T>( a:Array<T>, el:T, newEls:Array<T> ) {
		var index = a.indexOf( el );
		a[index++] = newEls[0];
		for (i in 1...newEls.length)
			a.insert( index++, newEls[i] );
	}

	public static function add<T>( a:Array<T>, el:T )
		if (a.indexOf( el ) == -1)
			a.push( el );

	public static function clean<T>( a:Array<T> ):Array<T>
		return [for (i in 0...a.length) if (a.indexOf( a[i] ) == i) a[i]];

	public static function intersect<T>( a:Array<T>, b:Array<T> ):Array<T>
		return [for (el in a) if (b.indexOf( el ) != -1) el];

	public static function union<T>( a:Array<T>, b:Array<T> ):Array<T>
		return a.concat( [for (el in b) if (a.indexOf( el ) == -1) el] );

	public static function removeAll<T>( a:Array<T>, b:Array<T> )
		[for (el in b) a.remove( el )];

	public static function difference<T>( a:Array<T>, b:Array<T> ):Array<T>
		return [for (el in a) if (b.indexOf( el ) == -1) el];

	public static function flatten<T>( a:Array<Array<T>> ):Array<T>
		if (a.length == 0)
			return []
		else {
			var result = a[0].copy();
			for (i in 1...a.length)
				result = result.concat( a[i] );
			return result;
		}

	public static function uflatten<T>( a:Array<Array<T>> ):Array<T>
		if (a.length == 0)
			return []
		else {
			var result = a[0].copy();
			for (i in 1...a.length)
				result = union( result, a[i] );
			return result;
		}

	public static function equals<T>( a:Array<T>, b:Array<T> )
		if (a.length != b.length)
			return false
		else if (a.length == 0)
			return true
		else {
			for (el in a)
				if (b.indexOf( el ) == -1)
					return false;
			return true;
		}
}
