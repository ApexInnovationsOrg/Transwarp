package ui {
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