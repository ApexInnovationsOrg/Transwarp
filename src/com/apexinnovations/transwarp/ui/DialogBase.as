package com.apexinnovations.transwarp.ui {
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;

	public class DialogBase extends Component{
		protected var tween:TweenLite;
		
		protected var _maxWidth:Number;
		protected var _maxHeight:Number;
		
		protected var _minWidth:Number;
		protected var _minHeight:Number;
		
		protected var _draggable:Boolean = false;
		
		protected var _shadow:Boolean;
		
		public var animationDuration:Number = 0.20;
	
		public function DialogBase() {
			super();
			visible = false;
			shadow = true;
		}

		public function open(e:Event = null):void {
			if (visible)
				return;
			else if (tween)
				tween.kill();

			var ox:Number = width * 0.15;
			var oy:Number = height * 0.15;

			x += ox, y += oy;
			scaleX = scaleY = 0.7;

			alpha = 0;
			visible = true;

			tween = TweenLite.to(this, animationDuration, {alpha: 1, x: x - ox, y: y - oy, scaleX: 1, scaleY: 1});
		}

		public function close(e:Event = null):void {
			if (!visible)
				return;
			else if (tween)
				tween.kill();
			
			var ox:Number = width * 0.15;
			var oy:Number = height * 0.15;
					
			tween = TweenLite.to(this, animationDuration, {alpha: 0, x: x + ox, y: y + oy, scaleX: .7, scaleY: .7, onComplete: finishClose});
		}

		protected function finishClose():void {
			scaleX = scaleY = 1;
			x -= width * 0.15;
			y -= height * 0.15;
			visible = false;
		}
		
		public function get shadow():Boolean { return _shadow; }
		public function set shadow(value:Boolean):void {
			if(_shadow = value)
				filters = [new DropShadowFilter(4, 45, 0, 1, 4, 4, 0.3)];
			else
				filters = [];		
		}
	}
}