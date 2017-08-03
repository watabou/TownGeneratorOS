package com.watabou.towngenerator.mapping;

import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.events.MouseEvent;

import com.watabou.towngenerator.building.Patch;
import com.watabou.towngenerator.ui.Tooltip;

using com.watabou.utils.GraphicsExtender;

class PatchView extends Shape {

	private static var lastPatch : Patch = null;

	public var patch	: Patch;
	public var hotArea	: Sprite;

	public function new( patch:Patch ) {
		super();
		this.patch = patch;

		hotArea = new Sprite();
		hotArea.graphics.beginFill( 0, 0 );
		hotArea.graphics.drawPolygon( patch.shape );
		// Since 5.1.5 assigning a listener to ROLL_OVER here causes a crash
		hotArea.addEventListener( MouseEvent.MOUSE_OVER, onRollOver );
	}

	private function onRollOver( e:MouseEvent )
		if (patch != lastPatch) {
			lastPatch = patch;
			Tooltip.instance.set( patch.ward.getLabel() );
		}
}

