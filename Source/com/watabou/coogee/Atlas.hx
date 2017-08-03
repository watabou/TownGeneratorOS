package com.watabou.coogee;

import openfl.Assets;
import openfl.geom.Rectangle;
import openfl.display.BitmapData;
import openfl.display.Tileset;

class Atlas extends Tileset {

	private var region	: Rectangle = null;

	private var named	: Map<String, Int> = new Map();

	// Grid parameters
	private var cols	: Int;
	private var rows	: Int;
	public var width	: Int;
	public var height	: Int;

	public function new( bmp:BitmapData, region:Rectangle=null ) {
		super( bmp );
		this.region = region;
	}

	override public function addRect( rect:Rectangle ):Int {
		return super.addRect( region == null ? rect :
			new Rectangle( rect.x + region.x, rect.y + region.y, rect.width, rect.height ) );
	}

	public inline function addNamed( name:String, rect:Rectangle ):Void {
		named.set( name, addRect( rect ) );
	}

	public inline function getNamed( name:String ):Int {
		return named.get( name );
	}

	public function addGrid( width:Int=0, height:Int=0 ):Atlas {
		var regWidth = region == null ? bitmapData.width : Std.int( region.width );
		var regHeight = region == null ? bitmapData.height : Std.int( region.height );

		this.width = (width == 0 ? regWidth : width);
		this.height = (height == 0 ? regHeight : height);

		cols = Std.int( regWidth / this.width );
		rows = Std.int( regHeight / this.height );

		for (i in 0...rows) {
			for (j in 0...cols) {
				addRect( new Rectangle( j * this.width, i * this.height, this.width, this.height ) );
			}
		}

		return this;
	}

	public function getGrid( col:Int, row:Int ):Int {
		return col + row * cols;
	}

	public static function sub( src:Atlas, rect:Rectangle ):Atlas {
		return new Atlas( src.bitmapData, rect );
	}

	public static function grid( id:String, width=0, height=0 ):Atlas {
		return new Atlas( Assets.getBitmapData( id ) ).addGrid( width, height );
	}

	public static function create( id:String ):Atlas {
		return new Atlas( Assets.getBitmapData( id ) );
	}
}