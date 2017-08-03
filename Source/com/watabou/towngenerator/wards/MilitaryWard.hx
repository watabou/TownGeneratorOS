package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class MilitaryWard extends Ward {

	override public function createGeometry() {
		var block = getCityBlock();
		geometry = Ward.createAlleys( block,
			Math.sqrt( block.square ) * (1 + Random.float()),
			0.1 + Random.float() * 0.3,	0.3,			// regular
			0.25 );										// squares
	}

	public static function rateLocation( model:Model, patch:Patch ):Float
		// Military ward should border the citadel or the city walls
		return
			if (model.citadel != null && model.citadel.shape.borders( patch.shape ))
				0
			else if (model.wall != null && model.wall.borders( patch ))
				1
			else
				(model.citadel == null && model.wall == null ? 0 : Math.POSITIVE_INFINITY);

	override public inline function getLabel() return "Military";
}
