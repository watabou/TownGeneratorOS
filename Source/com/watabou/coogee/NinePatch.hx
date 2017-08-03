package com.watabou.coogee;

import openfl.Assets;
import openfl.display.Tile;
import openfl.display.Tileset;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tilemap;

class NinePatch extends Tilemap {

	private var left	: Float;
	private var right	: Float;
	private var top		: Float;
	private var bottom	: Float;
	private var varh	: Float;
	private var varv	: Float;

	public function new( bmp:BitmapData, rect:Rectangle ) {

		tileset = new Tileset( bmp );
		var w = bmp.width;
		var h = bmp.height;
		left = rect.x;
		varh = rect.width;
		right = w - rect.right;
		top = rect.y;
		varv = rect.height;
		bottom = h - rect.bottom;

		tileset.addRect( new Rectangle( 0, 0, rect.x, rect.y ) );
		tileset.addRect( new Rectangle( rect.x, 0, varh, rect.y ) );
		tileset.addRect( new Rectangle( rect.right, 0, right, rect.y ) );

		tileset.addRect( new Rectangle( 0, rect.y, rect.x, varv ) );
		tileset.addRect( rect );
		tileset.addRect( new Rectangle( rect.right, rect.y, right, varv ) );

		tileset.addRect( new Rectangle( 0, rect.bottom, rect.x, bottom ) );
		tileset.addRect( new Rectangle( rect.x, rect.bottom, varh, bottom ) );
		tileset.addRect( new Rectangle( rect.right, rect.bottom, right, bottom ) );

		super( 1, 1, tileset, false );

		setSize( w, h );
	}

	public function setSize( w:Float, h:Float ):Void {
		removeTiles();
		width = w;
		height = h;

		var scx = (w - left - right) / varh ;
		var scy = (h - top - bottom) / varv;
		addTile( new Tile( 0, 0, 0 ) );
		addTile( new Tile( 1, left, 0, scx ) );
		addTile( new Tile( 2, w - right, 0 ) );

		addTile( new Tile( 3, 0, top, 1, scy ) );
		addTile( new Tile( 4, left, top, scx, scy ) );
		addTile( new Tile( 5, w - right, top, 1, scy ) );

		addTile( new Tile( 6, 0, h - bottom ) );
		addTile( new Tile( 7, left, h - bottom, scx ) );
		addTile( new Tile( 8, w - right, h - bottom ) );
	}

	public static function create( id:String,
								   left:Int=-1, top:Int=-1, right:Int=-1, bottom:Int=-1 ):NinePatch {
		if (left == -1) {
			left = 0;
		}
		if (top == -1) {
			top = left;
		}
		if (right == -1) {
			right = left;
		}
		if (bottom == -1) {
			bottom = top;
		}

		var bmp = Assets.getBitmapData( id );
		return new NinePatch( bmp,
			new Rectangle( left, top, bmp.width - left - right, bmp.height - top - bottom ) );
	}
}