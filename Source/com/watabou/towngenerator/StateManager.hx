package com.watabou.towngenerator;

import com.watabou.utils.Random;

#if html5
import js.Browser;
import js.html.URLSearchParams;
#end

class StateManager {

	private static inline var SIZE = "size";
	private static inline var SEED = "seed";

	public static var size	: Int = 15;
	public static var seed	: Int = -1;

	public static function pullParams() {
		#if html5
		var params = new URLSearchParams( Browser.location.search );
		if (params != null) {
			var size1 = Std.parseInt( params.get( SIZE ) );
			if (size1 != null)size = (size1 >= 6 ? (size1 <= 40 ? size1: 40) : 6);

			var seed1 = Std.parseInt( params.get( SEED ) );
			if (seed1 != null) seed = (seed1 > 0 ? seed1 : -1);
		}
		#end
	}

	public static function pushParams() {
		if (seed == -1) {
			Random.reset();
			seed = Random.getSeed();
		}

		#if html5
		var loc = Browser.location;
		var search1 = loc.search;
		var search2 = '?$SIZE=$size&$SEED=$seed';
		// The next line is not entirely correct, it doesn't take into account hashes
		var url = search1 != "" ? loc.href.split( search1 ).join( search2 ) : loc.href + search2;
		Browser.window.history.replaceState( {size: size, seed: seed}, getStateName(), url );
		#end
	}

	private static function getStateName():String {
		return if (size >= 6 && size < 10)
			"Small Town"
		else if (size >= 10 && size < 15)
			"Large Town"
		else if (size >= 15 && size <24)
			"Small City"
		else if (size >= 24 && size < 40)
			"Large City"
		else if (size >= 40)
			"Metropilis"
		else
			"Unknown state";
	}
}
