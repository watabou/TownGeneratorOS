package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Slum extends CommonWard {

	public inline function new( model:Model, patch:Patch )
		super( model, patch,
			10 + 30 * Random.float() * Random.float(),	// small to medium
			0.6 + Random.float() * 0.4,	0.8,			// chaotic
			0.03 );

	public static function rateLocation( model:Model, patch:Patch ):Float
		// Slums should be as far from the center as possible
		return -patch.shape.distance( model.plaza != null ? model.plaza.shape.center : model.center );

	override public inline function getLabel() return "Slum";
}
