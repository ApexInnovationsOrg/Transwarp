package com.apexinnovations.transwarp.ui {
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	import mx.core.UIComponent;
	
	import spark.core.SpriteVisualElement;

	public class Component extends SpriteVisualElement {
		public static const DRAW:String = "draw";
		
		public function Component() {
			super();
			invalidate();
		}

		/**
		 * <code>invalidate</code> Queues a redraw on the next frame.  By queing the draw, multiple updates during a single frame only generate a single draw event.
		 * 
		 * @param e The <code>Event</code> parameter is thrown away.  It's only present to allow easily invalidating in response to an event without using another helper function  
		 */
		public function invalidate(e:Event = null):void {
			addEventListener(Event.ENTER_FRAME, onInvalidate);
		}

		protected function onInvalidate(e:Event):void {
			removeEventListener(Event.ENTER_FRAME, onInvalidate);
			draw();
		}

		public function draw():void {
			dispatchEvent(new Event(Component.DRAW));
		}
	}
}