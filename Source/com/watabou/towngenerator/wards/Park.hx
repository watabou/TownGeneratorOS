package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Cutter;

class Park extends Ward {

	override public function createGeometry() {
		var block = getCityBlock();
		geometry = block.compactness >= 0.7 ?
			Cutter.radial( block, null, Ward.ALLEY ) :
			Cutter.semiRadial( block, null, Ward.ALLEY );
	}

	override public inline function getLabel() return "Park";
}
