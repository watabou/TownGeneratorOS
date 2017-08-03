package com.watabou.coogee;

import openfl.Assets;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.utils.AssetType;

class BitmapText extends Bitmap {

	public var _font	: BitmapFont;
	public var _text	: String = "";

	public function new( font:BitmapFont, text:String="" ) {

		super( null, PixelSnapping.ALWAYS, false );

		_font = font;
		_text = text;
		update();
	}

	public function text( value:String ):Void {
		_text = value;
		update();
	}

	public function font( value:BitmapFont ):Void {
		_font = value;
		update();
	}

	private function update():Void {
		if (bitmapData != null) {
			bitmapData.dispose();
		}
		if (_text == null) {
			return;
		}

		var length = _text.length;
		var width = 0;
		var height = 0;
		for (i in 0...length) {
			var rect = _font.table[_text.charAt( i )];
			width += Std.int( rect.width );
			height = Std.int( Math.max( height, rect.height ) );
		}

		if (length > 0) {
			width += _font.letterSpacing * (length-1);
		}

		bitmapData = new BitmapData( width, height, true, 0x00000000 );
		var pos = new Point();
		for (i in 0...length) {
			var rect = _font.table[_text.charAt( i )];
			bitmapData.copyPixels( _font.bitmapData, rect, pos, null, null, true );
			pos.x += rect.width + _font.letterSpacing;
		}
	}

	public function baseLine():Int {
		return _font.baseLine;
	}

	public static function split( font:BitmapFont, text:String, width:Int ):Array<BitmapText> {
		var result:Array<BitmapText> = [];

		var words = text.split( " " );
		while (words.length > 0) {

			var word = words.shift();
			var line = word;
			var bmpLine:BitmapText = new BitmapText( font, line );

			while (words.length > 0) {
				word = words.shift();
				bmpLine = new BitmapText( font, line + " " + word );
				if (bmpLine.width <= width) {
					line += " " + word;
				} else {
					break;
				}
			}

			if (bmpLine.width > width) {
				words.unshift( word );
				bmpLine = new BitmapText( font, line );
			}
			result.push( bmpLine );
		}

		return result;
	}
}

class BitmapFont {

	public static var LATIN_FULL : String =
	" !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~\u007F";

	private static inline var COLOR	: Int = 0x00000000;

	public var bitmapData	: BitmapData;

	public var table	: Map<String, Rectangle>;

	public var letterSpacing	: Int = 0;
	public var baseLine			: Int;
	public var lineHeight		: Int;

	public function new( src:String, chars:String=null ) {

		bitmapData = Assets.getBitmapData( src );
		table = new Map<String, Rectangle>();

		if (chars == null) {
			chars = LATIN_FULL;
		}
		var length = chars.length;

		var width = bitmapData.width;
		var height = bitmapData.height;

		var pos = 0;
		for (i in 0...width) {
			var broken = false;
			for (j in 0...height) {
				if (bitmapData.getPixel32( i, j ) != COLOR) {
					broken = true;
					pos = i;
					break;
				}
			}
			if (broken) {
				break;
			}
		}
		table[" "] = new Rectangle( 0, 0, --pos, height );

		for (i in 0...length) {

			var ch = chars.charAt( i );
			if (ch == " ") {
				continue;
			} else {

				var blankColumn:Bool;
				var separator = pos;

				do {
					if (++separator >= width) {
						break;
					}
					blankColumn = true;
					for (j in 0...height) {
						if (bitmapData.getPixel32( separator, j ) != COLOR) {
							blankColumn = false;
							break;
						}
					}
				} while (!blankColumn);

				table[ch] = new Rectangle( pos, 0, separator - pos, height );
				pos = separator + 1;
			}
		}

		lineHeight = baseLine = height;
	}

	public static function get( id:String, color:Int=0xffffffff ):BitmapFont {
		var font = new BitmapFont( id, LATIN_FULL );
		if (color != 0xffffffff) {
			id += ("_" + color);
			font.bitmapData = if (!Assets.exists( id )) {
				var bmp = font.bitmapData.clone();
				var r = (color >> 16) & 0xff;
				var g = (color >> 8) & 0xff;
				var b = color & 0xff;
				bmp.colorTransform( bmp.rect, new ColorTransform( r/255, g/255, b/255 ) );
				Assets.cache.setBitmapData( id, bmp );
				bmp;
			} else
				Assets.getBitmapData( id );
		}
		return font;
	}
}

