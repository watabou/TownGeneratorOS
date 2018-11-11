package com.watabou.coogee;

import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;
import openfl.system.System;
import com.watabou.utils.Updater;

class Game extends Sprite {

	private static var instance	: Game;

	public static var scene	: Scene;

	public function new( initScene:Class<Scene> ) {
		instance = this;

		super();

		prepareStage();
		Updater.useRenderer( stage.window );

		switchScene( initScene );
	}

	private function prepareStage():Void {
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.addEventListener( Event.RESIZE, function( e:Event ):Void {
			layout();
		} );

		// On exit we want to save the game, because
		// calling onDeactivate before onExit is not guarantied
		stage.application.onExit.add( onExit );

		#if desktop
		stage.application.window.onFocusIn.add( onResume );
		stage.application.window.onFocusOut.add( onPause );
		#else
		// It's not clear what events exactly get fired when the game
		// loses focus (gets paused/goes to background/...) on Android and iOS
		#if ios
		stage.application.window.onRestore.add( onResume );
		#else
		stage.application.window.onActivate.add( onResume );
		#end
		stage.application.window.onDeactivate.add( onPause );
		#end
	}

	private function onExit( code:Int ):Void {
		Updater.stop();
	}

	private function onResume():Void {
		#if ios
		if (curScene != null) {
			curScene.visible = true;
		}
		#end
	}

	private function onPause():Void {
		#if ios
		curScene.visible = false;
		#end
	}

	private function layout():Void {
		if (scene != null) {
			var w = stage.stageWidth;
			var h = stage.stageHeight;
			var scale = getScale( w, h );
			scene.scaleX = scene.scaleY = scale;
			scene.setSize( w / scale, h / scale );
		}
	}

	private function getScale( w:Int, h:Int ):Float {
		return 1;
	}

	public static function switchScene( scClass:Class<Scene> ):Void {
		instance.switchSceneImp( scClass );
	}

	private function switchSceneImp( scClass:Class<Scene> ):Void {
		if (scene != null) {
			scene.deactivate();
			removeChild( scene );
			scene = null;
		}

		if (scClass != null) {
			scene = Type.createInstance( scClass, [] );
			addChild( scene );
			#if mac
			stage.window.resize( stage.window.width, stage.window.height );
			#end
			layout();

			scene.activate();
		}

		stage.focus = stage;
	}

	public static function quit():Void {
		System.exit( 0 );
	}
}