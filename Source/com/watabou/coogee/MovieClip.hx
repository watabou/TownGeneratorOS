package com.watabou.coogee;

import msignal.Signal.Signal0;
import msignal.Signal.Signal1;
import openfl.display.Tile;
import openfl.geom.Rectangle;
import openfl.Assets;
import openfl.display.Tileset;
import openfl.display.Tilemap;

class MovieClip extends Tilemap {

	public var atlas		: Atlas;
	public var animation	: Animation;
	public var curFrame		: Int;
	public var time			: Float = 0;

	public var looped	: Bool = true;

	private var tile	: Tile = null;

	public var frame	: Signal1<Int> = new Signal1();
	public var complete	: Signal0 = new Signal0();

	public function new( atlas:Atlas ) {
		super( atlas.width, atlas.height, atlas, false );

		setFrame( 0 );
	}

	public function setFrame( index:Int ):Void {
		var id = animation == null ? index : animation.frames[index];
		if (tile == null) {
			tile = new Tile( id, 0, 0 );
			addTile( tile );
		} else {
			tile.id = id;
		}
		curFrame = index;
	}

	public function play( animation:Animation ):Void {
		if (this.animation != animation) {
			this.animation = animation;
			setFrame( 0 );
			time = 0;
		}
	}

	public function update( elapsed:Float ):Void {
		if (animation != null) {

			time += elapsed;
			var timePerFrame = animation.timings[curFrame];

			if (time > timePerFrame) {
				do {
					time -= timePerFrame;
					if (++curFrame >= animation.frames.length) {
						complete.dispatch();
						if (looped) {
							curFrame = 0;
						} else {
							curFrame = animation.frames.length - 1;
							break;
						}
					}
					frame.dispatch( curFrame );
					timePerFrame = animation.timings[curFrame];
				} while (time > timePerFrame);

				setFrame( curFrame );
			}
		}
	}
}

class Animation {
	public var frames	: Array<Int> = [];
	public var timings	: Array<Float> = [];
	public var marks	: Array<String> = [];

	public function new( frames:Array<Int>, timings:Array<Float> ) {
		this.frames = frames;
		this.timings = timings;
		marks = [for (i in 0...frames.length) null];
	}

	public static function create( frames:Array<Int>, timing:Float ):Animation {
		return new Animation( frames, [for (frame in frames) timing]);
	}

	public inline function markFrame( index:Int, name:String ):Void {
		marks[index] = name;
	}

	public inline function getMark( index:Int ):String {
		return marks[index];
	}
}

class Strip extends Tileset {
	public var nFrames	: Int;

	public var width	: Int;
	public var height	: Int;

	public function new( id:String, frameWidth:Int, frameHeight:Int ) {
		var bmp = Assets.getBitmapData( id );
		width = frameWidth == 0 ? bmp.width : frameWidth;
		height = frameHeight == 0 ? bmp.height : frameHeight;

		var cols = Std.int( bmp.width / width );
		var rows = Std.int( bmp.height / height );
		nFrames = cols * rows;

		super( bmp );

		for (i in 0...rows) {
			for (j in 0...cols) {
				addRect( new Rectangle( j * width, i * height, width, height ) );
			}
		}
	}
}
