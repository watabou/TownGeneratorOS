package com.watabou.towngenerator.mapping;

import openfl.display.JointStyle;
import openfl.display.Graphics;

class Brush {

	public static inline var NORMAL_STROKE	= 0.300;
	public static inline var THICK_STROKE	= 1.800;
	public static inline var THIN_STROKE	= 0.150;

	public var strokeColor	= 0x000000;
	public var fillColor	= 0xcccccc;
	public var stroke		= NORMAL_STROKE;

	private var palette		: Palette;

	private static var lastDark		: Int = -1;
	private static var lastPaper	: Int = -1;

	public function new( palette:Palette ) {
		this.palette = palette;
	}

	public function setFill( g:Graphics, color:Int ) {
		fillColor = color;
		g.beginFill( color );
	}

	public function setStroke( g:Graphics, color:Int, stroke=NORMAL_STROKE, miter=true ) {
		if (stroke == 0)
			noStroke( g );
		else {
			strokeColor = color;
			g.lineStyle( stroke, color == -1 ? fillColor : color, 1, false, null, null, miter ? JointStyle.MITER : null );
		}
	}

	public inline function noStroke( g:Graphics ) {
		g.lineStyle( 0, 0, 0 );
	}

	public function setColor( g:Graphics, fill:Int, line=-1, stroke=NORMAL_STROKE, miter=true ) {
		setFill( g, fill );
		setStroke( g, line, stroke, miter );
	}
}
