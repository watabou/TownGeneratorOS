package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class PatriciateWard extends CommonWard {

	public inline function new( model:Model, patch:Patch )
		super( model, patch,
			80 + 30 * Random.float() * Random.float(),	// large
			0.5 + Random.float() * 0.3,	0.8,			// moderately regular
			0.2 );

	public static function rateLocation( model:Model, patch:Patch ):Float {
		// Patriciate ward prefers to border a park and not to border slums
		var rate = 0;
		for (p in model.patches) if (p.ward != null && p.shape.borders( patch.shape )) {
			if (Std.is( p.ward, Park ))
				rate--
			else if (Std.is( p.ward, Slum ))
				rate++;
		}
		return rate;
	}

	override public inline function getLabel() return "Patriciate";
}
