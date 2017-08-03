package com.watabou.towngenerator.mapping;

import openfl.display.Shape;
import openfl.display.CapsStyle;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Point;

import com.watabou.geom.Polygon;

import com.watabou.towngenerator.wards.*;
import com.watabou.towngenerator.building.CurtainWall;
import com.watabou.towngenerator.building.Model;

using com.watabou.utils.ArrayExtender;
using com.watabou.utils.GraphicsExtender;
using com.watabou.utils.PointExtender;

class CityMap extends Sprite {

	public static var palette = Palette.DEFAULT;

	private var patches	: Array<PatchView>;

	private var brush	: Brush;

	public function new( model:Model ) {
		super();

		brush = new Brush( palette );

		var model = Model.instance;

		for (road in model.roads) {
			var roadView = new Shape();
			drawRoad( roadView.graphics, road );
			addChild( roadView );
		}

		patches = [];
		for (patch in model.patches) {
			var patchView = new PatchView( patch );
			var patchDrawn = true;

			var g = patchView.graphics;
			switch (Type.getClass( patch.ward )) {
				case Castle:
					drawBuilding( g, patch.ward.geometry, palette.light, palette.dark, Brush.NORMAL_STROKE * 2 );
				case Cathedral:
					drawBuilding( g, patch.ward.geometry, palette.light, palette.dark, Brush.NORMAL_STROKE );
				case Market, CraftsmenWard, MerchantWard, GateWard, Slum, AdministrationWard, MilitaryWard, PatriciateWard, Farm:
					brush.setColor( g, palette.light, palette.dark );
					for (building in patch.ward.geometry)
						g.drawPolygon( building );
				case Park:
					brush.setColor( g, palette.medium );
					for (grove in patch.ward.geometry)
						g.drawPolygon( grove );
				default:
					patchDrawn = false;
			}

			patches.push( patchView );
			if (patchDrawn)
				addChild( patchView );
		}

		for (patch in patches)
			addChild( patch.hotArea );

		var walls = new Shape();
		addChild( walls );

		if (model.wall != null)
			drawWall( walls.graphics, model.wall, false );

		if (model.citadel != null)
			drawWall( walls.graphics, cast( model.citadel.ward, Castle).wall, true );
	}

	private function drawRoad( g:Graphics, road:Street ):Void {
		g.lineStyle( Ward.MAIN_STREET + Brush.NORMAL_STROKE, palette.medium, false, null, CapsStyle.NONE );
		g.drawPolyline( road );

		g.lineStyle( Ward.MAIN_STREET - Brush.NORMAL_STROKE, palette.paper );
		g.drawPolyline( road );
	}

	private function drawWall( g:Graphics, wall:CurtainWall, large:Bool ):Void {
		g.lineStyle( Brush.THICK_STROKE, palette.dark );
		g.drawPolygon( wall.shape );

		for (gate in wall.gates)
			drawGate( g, wall.shape, gate );

		for (t in wall.towers)
			drawTower( g, t, Brush.THICK_STROKE * (large ? 1.5 : 1) );
	}

	private function drawTower( g:Graphics, p:Point, r:Float ) {
		brush.noStroke( g );
		g.beginFill( palette.dark );
		g.drawCircle( p.x, p.y, r );
		g.endFill();
	}

	private function drawGate( g:Graphics, wall:Polygon, gate:Point ) {
		g.lineStyle( Brush.THICK_STROKE * 2, palette.dark, false, null, CapsStyle.NONE );

		var dir = wall.next( gate ).subtract( wall.prev( gate ) );
		dir.normalize( Brush.THICK_STROKE * 1.5 );
		g.moveToPoint( gate.subtract( dir ) );
		g.lineToPoint( gate.add( dir ) );
	}

	private function drawBuilding( g:Graphics, blocks:Array<Polygon>, fill:Int, line:Int, thickness:Float ):Void {
		brush.setStroke( g, line, thickness * 2 );
		for (block in blocks) {
			g.drawPolygon( block );
		}

		brush.noStroke( g );
		brush.setFill( g, fill );
		for (block in blocks) {
			g.drawPolygon( block );
		}
	}
}