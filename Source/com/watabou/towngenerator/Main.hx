package com.watabou.towngenerator;

import openfl.system.Capabilities;

import com.watabou.coogee.Game;
import com.watabou.coogee.BitmapText.BitmapFont;

import com.watabou.towngenerator.building.Model;
import com.watabou.towngenerator.mapping.CityMap;

class Main extends Game {

	public static var uiFont	: BitmapFont;

	public function new () {
		StateManager.pullParams();
		StateManager.pushParams();

		stage.color = CityMap.palette.paper;

		uiFont = BitmapFont.get( "font", CityMap.palette.paper );
		uiFont.letterSpacing = 1;
		uiFont.baseLine = 8;

		new Model( StateManager.size, StateManager.seed );

		super( TownScene );
	}

	override public function getScale( w:Int, h:Int ):Float {
		return Std.int( Capabilities.screenDPI / 24 );
	}
}