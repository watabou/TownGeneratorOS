package com.watabou.towngenerator.ui;

import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.MouseEvent;
import openfl.geom.Point;

import com.watabou.coogee.BitmapText;

import com.watabou.towngenerator.mapping.CityMap;

using com.watabou.utils.DisplayObjectExtender;

class Tooltip extends Bitmap {

	public static var instance : Tooltip;

	private static var cache : Map<String, BitmapData> = new Map();

	public function new() {
		instance = this;

		super();

		this.onActivate( activation );

		set( null );
	}

	private function activation( active:Bool )
		if (active) {
			stage.addEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseMove );
		} else {
			stage.removeEventListener( MouseEvent.MOUSE_MOVE, onMouseMove );
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseMove );
		}

	private function onMouseMove( e:MouseEvent ) {
		x = parent.mouseX + 4;
		y = parent.mouseY;
		e.updateAfterEvent();
	}

	public function set( txt:String ) {
		visible = (txt != null);
		if (visible) {
			var bmp:BitmapData = cache[txt];
			if (bmp == null) {
				var txtBmp = new BitmapText( Main.uiFont, txt ).bitmapData;
				bmp = new BitmapData( txtBmp.width + 4, txtBmp.height + 2, false, CityMap.palette.dark );
				bmp.copyPixels( txtBmp, txtBmp.rect, new Point( 2, 1 ), null, null, true );
				cache[txt] = bmp;
			}
			bitmapData = bmp;
		}
	}
}
