package com.watabou.towngenerator.mapping;

class AdvancedPalette {

	public var ground 		: Int;
	public var grass 		: Int;
	public var water 		: Int;
	public var water_light 	: Int;
	public var water_dark 	: Int;
	public var road_small 	: Int;
	public var road_medium 	: Int;
	public var road_large 	: Int;
	public var plot 		: Int;
	public var building 	: Int;

	public inline function new( ground, grass, water, water_light, water_dark, road_small, road_medium, road_large, 
	 							plot, building) {
		this.ground	= ground;
		this.grass	= grass;
		this.water	= water;
		this.water_light	= water_light;
		this.water_dark	= water_dark;
		this.road_small	= road_small;
		this.road_medium	= road_medium;
		this.road_large	= road_large;
		this.plot	= plot;
		this.building	= building;
	}

	public static var DEFAULT	= new AdvancedPalette( 0xf7eaca, 0x31d871, 0x3199d6, 0x96d0f2, 0x0b5077, 0x747677, 0xa4a7a8, 0x627a82,
											   0xb7a98d, 0x4f453b  );

}