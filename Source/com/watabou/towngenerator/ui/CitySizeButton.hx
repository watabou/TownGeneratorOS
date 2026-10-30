package com.watabou.towngenerator.ui;

import com.watabou.coogee.Game;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Model;

class CitySizeButton extends Button {

	private var size : Int;

	public function new( label:String, minSize:Int, maxSize:Int ) {
		super( label );

		// Use the generator's seeded PRNG so the chosen size is reproducible.
		size = Random.int( minSize, maxSize );

		click.add( onClick );
	}

	private function onClick():Void {
		StateManager.size = size;

		// Start a fresh deterministic generation. The seed written to the URL
		// is also passed to Model, so reloading the URL recreates this city.
		Random.reset();
		StateManager.seed = Random.getSeed();
		StateManager.pushParams();

		new Model( size, StateManager.seed );
		Game.switchScene( TownScene );
	}
}
