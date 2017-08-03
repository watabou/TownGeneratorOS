package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

import com.watabou.utils.Random;

class GateWard extends CommonWard {

	public inline function new( model:Model, patch:Patch )
		super( model, patch,
			10 + 50 * Random.float() * Random.float(),
			0.5 + Random.float() * 0.3, 0.7 );

	override public inline function getLabel() return "Gate";
}
