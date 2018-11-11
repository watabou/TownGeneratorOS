package com.watabou.utils;

import lime.ui.Window;
import lime.graphics.RenderContext;
import msignal.Signal.Signal1;
import openfl.Lib;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.TimerEvent;
import openfl.utils.Timer;

class Updater {

	private static var _tick	: Signal1<Float> = new Signal1<Float>();

	private static var source : RecurringEventDispatcher = null;

	private static var lastTime	: Int = 0;

	public static var timeScale = 1.0;

	public static function reset():Void {
		_tick.removeAll();
	}

	public static var tick(get, never) : Signal1<Float>;
	public static function get_tick():Signal1<Float> {
		if (source == null) {
			useTimer( 60 );
		}

		return _tick;
	}

	public static function fire():Void {
		var t = Lib.getTimer();
		if (lastTime == 0) {
			_tick.dispatch( 0 );
		} else {
			_tick.dispatch( (t - lastTime) / 1000 * timeScale );
		}
		lastTime = t;
	}

	public static function useTimer( interval:Float ):Void {
		if (source != null) {
			source.stop();
		}
		source = new TimerEventDispatcher( interval );
	}

	public static function useEnterFrame( src:DisplayObject ):Void {
		if (source != null) {
			source.stop();
		}
		source = new FrameEventDispatcher( src );
	}

	public static function useRenderer( renderer:Window ):Void {
		if (source != null) {
			source.stop();
		}
		source = new RendererDispatcher( renderer );
	}

	public static function wait( time:Float, callback:Void->Void ):Float->Void {
		var passed = 0.0;
		function waiting( elapsed:Float ):Void {
			if ((passed += elapsed) >= time) {
				tick.remove( waiting );
				callback();
			}
		}
		tick.add( waiting );
		return waiting;
	}

	public static function cancel( callback:Float->Void ):Void {
		tick.remove( callback );
	}

	public static function stop():Void {
		if (source != null) {
			source.stop();
			source = null;
		}
	}
}

class RecurringEventDispatcher {
	public function stop():Void {}
}

private class TimerEventDispatcher extends RecurringEventDispatcher {

	private var timer : Timer;

	public function new( interval:Float ) {
		timer = new Timer( interval );
		timer.addEventListener( TimerEvent.TIMER, onTimer );
		timer.start();
	}

	private function onTimer( e:TimerEvent ):Void {
		Updater.fire();
		e.updateAfterEvent();
	}

	override public function stop():Void {
		timer.stop();
	}
}

private class FrameEventDispatcher extends RecurringEventDispatcher {

	private var dispObj : DisplayObject;

	public function new( dispObj:DisplayObject ) {
		this.dispObj = dispObj;
		dispObj.addEventListener( Event.ENTER_FRAME, onEnterFrame );
	}

	private function onEnterFrame( e:Event ):Void {
		Updater.fire();
	}

	override public function stop():Void {
		dispObj.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
	}
}

private class RendererDispatcher extends RecurringEventDispatcher {

	private var renderer : Window;

	public function new( renderer : Window ) {
		this.renderer = renderer;
		renderer.onRender.add( onRender );
	}

	private function onRender(context: RenderContext):Void {
		Updater.fire();
	}

	override public function stop():Void {
		renderer.onRender.remove( onRender );
	}
}
