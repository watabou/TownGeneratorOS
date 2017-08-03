package com.watabou.towngenerator.ui;

import com.watabou.coogee.Game;
import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Model;

class CitySizeButton extends Button {

	private var size : Int;

	public function new( label:String, minSize:Int, maxSize:Int ) {
		super( label );

		size = minSize + Std.int( Math.random() * (maxSize - minSize) );

		click.add( onClick );
	}

	private function onClick():Void {
		StateManager.size = size;
		StateManager.seed = Random.getSeed();
		StateManager.pushParams();

		new Model( size );
		Game.switchScene( TownScene );
	}
}
