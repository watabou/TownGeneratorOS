package com.watabou.coogee;

import openfl.display.Sprite;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;

import com.watabou.utils.Updater;

class Scene extends Sprite {

	public var keyEvent	: Signal2<Int, Bool> = new Signal2();
	public var update	: Signal1<Float> = new Signal1();

	private var rWidth	: Float;
	private var rHeight	: Float;

	public function activate():Void {
		Updater.tick.add( onUpdate );
		stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
	}

	public function deactivate():Void {
		Updater.tick.remove( onUpdate );
		stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
		stage.removeEventListener( KeyboardEvent.KEY_UP, onKeyUp );
	}

	private function onEsc():Void {
		Game.quit();
	}

	private function onKeyDown( e:KeyboardEvent ):Void {
		switch (e.keyCode) {
			case Keyboard.ESCAPE:
				onEsc();
		}
		keyEvent.dispatch( e.keyCode, true );
	}

	private function onKeyUp( e:KeyboardEvent ):Void {
		keyEvent.dispatch( e.keyCode, false );
	}

	public function setSize( w:Float, h:Float ):Void {
		rWidth = w;
		rHeight = h;
		layout();
	}

	private function layout():Void {}

	private function onUpdate( elapsed:Float ):Void {
		update.dispatch( elapsed );
	}
}