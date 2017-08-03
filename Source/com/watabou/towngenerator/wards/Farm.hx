package com.watabou.towngenerator.wards;

import com.watabou.utils.Random;
import com.watabou.geom.Polygon;
import com.watabou.geom.GeomUtils;

using com.watabou.utils.ArrayExtender;

class Farm extends Ward {

	override public function createGeometry() {
		var housing = Polygon.rect( 4, 4 );
		var pos = GeomUtils.interpolate( patch.shape.random(), patch.shape.centroid, 0.3 + Random.float() * 0.4 );
		housing.rotate( Random.float() * Math.PI );
		housing.offset( pos );

		geometry = Ward.createOrthoBuilding( housing, 8, 0.5 );
	}

	override public inline function getLabel() return "Farm";
}
