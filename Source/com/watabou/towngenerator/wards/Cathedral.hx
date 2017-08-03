package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;

import com.watabou.towngenerator.building.Cutter;
import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class Cathedral extends Ward {

	override public function createGeometry()
		geometry = Random.bool( 0.4 ) ?
			Cutter.ring( getCityBlock(), 2 + Random.float() * 4 ) :
			Ward.createOrthoBuilding( getCityBlock(), 50, 0.8 );

	public static function rateLocation( model:Model, patch:Patch ):Float
		// Ideally the main temple should overlook the plaza,
		// otherwise it should be as close to the plaza as possible
		return if (model.plaza != null && patch.shape.borders( model.plaza.shape ))
			-1/patch.shape.square
		else
			patch.shape.distance( model.plaza != null ? model.plaza.shape.center : model.center ) * patch.shape.square;

	override public inline function getLabel() return "Temple";
}
