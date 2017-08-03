package com.watabou.towngenerator.wards;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.building.Model;

class CommonWard extends Ward {

	private var minSq		: Float;
	private var gridChaos	: Float;
	private var sizeChaos	: Float;
	private var emptyProb	: Float;

	public function new( model:Model, patch:Patch, minSq:Float, gridChaos:Float, sizeChaos:Float, emptyProb:Float=0.04 ) {
		super( model, patch );

		this.minSq = minSq;
		this.gridChaos = gridChaos;
		this.sizeChaos = sizeChaos;
		this.emptyProb = emptyProb;
	}

	override public function createGeometry() {
		var block = getCityBlock();
		geometry = Ward.createAlleys( block, minSq, gridChaos, sizeChaos, emptyProb );

		if (!model.isEnclosed( patch ))
			filterOutskirts();
	}
}
