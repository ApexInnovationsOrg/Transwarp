package ui {
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;

	public class DialogBase extends Sprite{
		protected var tween:TweenLite;

		public var animationDuration:Number = 0.20;
		//public var draggable:Boolean = false;
		
		public function DialogBase() {
			super();
			visible = false;
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
	}
}