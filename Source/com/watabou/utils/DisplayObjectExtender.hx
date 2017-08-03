package com.watabou.utils;

import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.DisplayObject;

class DisplayObjectExtender {
	public static function centerX( child:DisplayObject )
		child.x = -child.width / 2;

	public static function centerY( child:DisplayObject )
		child.y = -child.height / 2;

	public static function center( child:DisplayObject ) {
		child.x = -child.width / 2;
		child.y = -child.height / 2;
	}

	public static function right( child:DisplayObject )
		child.x = -child.width;

	public static function bottom( child:DisplayObject )
		child.y = -child.height;

	public static function onActivate( obj:DisplayObject, handler:Bool->Void ) {
		function eventHandler( e:Event ):Void {
			handler( e.type == Event.ADDED_TO_STAGE );
		}
		obj.addEventListener( Event.ADDED_TO_STAGE, eventHandler );
		obj.addEventListener( Event.REMOVED_FROM_STAGE, eventHandler );
	}
}
