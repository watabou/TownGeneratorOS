package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class MerchantWard extends CommonWard {

	public inline function new( model:Model, patch:Patch )
		super( model, patch,
			50 + 60 * Random.float() * Random.float(),	// medium to large
			0.5 + Random.float() * 0.3,	0.7,			// moderately regular
			0.15	);

	public static function rateLocation( model:Model, patch:Patch )
		// Merchant ward should be as close to the center as possible
		return patch.shape.distance( model.plaza != null ? model.plaza.shape.center : model.center );

	override public inline function getLabel() return "Merchant";
}
