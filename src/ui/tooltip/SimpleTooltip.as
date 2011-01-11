package ui.tooltip
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.GradientType;
	import flash.display.Graphics;
	import flash.display.InteractiveObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;

	public class SimpleTooltip extends Sprite
	{
		public var paddingX:Number=2;
		public var paddingY:Number=0;
		public var anchorObject:DisplayObject;
		public var delayTolerance:Number=1500;

		protected var container:DisplayObjectContainer;
		protected var owner:InteractiveObject;
		protected var attach:String;
		protected var tf:TextField;
		protected var ox:Number;
		protected var oy:Number;
		protected var tween:TweenLite;
		protected var lastShow:Number=-1;

		public function get text():String {return tf.text;}
		public function set text(value:String):void {tf.text=value;	update(true);}

		public function get attachPoint():String { return attach; }
		public function set attachPoint(value:String):void { attach = value; } // TODO: Validate to known attachpoints?

		public function setOffset(x:Number, y:Number):void {ox=x, oy=y; update(); }

		public function SimpleTooltip(container:DisplayObjectContainer, text:String = "", attachPoint:String = "topright", offsetX:Number = 0, offsetY:Number = 0) {
			super();

			this.container = container;

			initText(text);
			ox = offsetX, oy = offsetY;
			attach = attachPoint;			
		}

		public function update(redraw:Boolean = false):void {
			if (redraw)
				draw();
			handleAttachPoint();
			checkBounds();
		}

		protected function initText(text:String):void {
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = text;
			tf.selectable = false;
			tf.mouseEnabled = false;
			tf.defaultTextFormat = new TextFormat("Arial", 11);
			addChild(tf);
		}

		public function show(e:MouseEvent = null):void {
			container.addChild(this);
			alpha = 0;
			
			update();			
			
			if (tween)
				tween.kill();
			
			tween = TweenLite.to(this, 0.2, {alpha: 1});
			lastShow = getTimer();
		}

		public function delayedShow(delay:Number, forceDelay:Boolean = false):void {
			if (forceDelay || getTimer() - lastShow > delayTolerance)
				tween = TweenLite.delayedCall(delay, show);
			else
				show();
		}

		public function hide(e:MouseEvent = null):void {
			if (tween)
				tween.kill();
			remove();
		}

		public function handleAttachPoint():void {
			var attached:Boolean = remove();
			
			var anchor:Rectangle;
			if (anchorObject)
				anchor = anchorObject.getBounds(container);
			else
				anchor = new Rectangle(container.mouseX - 4, container.mouseY, 18, 23);

			switch (attach) {
				case TooltipAttachPoint.TOPLEFT:
				case TooltipAttachPoint.LEFT:
				case TooltipAttachPoint.BOTTOMLEFT:
					x = anchor.x - width + paddingX;
					break;

				case TooltipAttachPoint.TOPRIGHT:
				case TooltipAttachPoint.RIGHT:
				case TooltipAttachPoint.BOTTOMRIGHT:
					x = anchor.x + anchor.width + paddingX;
					break;

				case TooltipAttachPoint.TOP:
				case TooltipAttachPoint.BOTTOM:
					x = anchor.x + (anchor.width - width) / 2 + paddingX;
					break;
			}

			switch (attach) {
				case TooltipAttachPoint.TOP:
				case TooltipAttachPoint.TOPLEFT:
				case TooltipAttachPoint.TOPRIGHT:
					y = anchor.y - height - paddingY;
					break;

				case TooltipAttachPoint.BOTTOM:
				case TooltipAttachPoint.BOTTOMLEFT:
				case TooltipAttachPoint.BOTTOMRIGHT:
					y = anchor.y + anchor.height + paddingY;
					break;

				case TooltipAttachPoint.LEFT:
				case TooltipAttachPoint.RIGHT:
					y = anchor.y + (anchor.height - height) / 2 + paddingY;
					break;
			}

			x += ox, y += oy;

			if (attached)
				container.addChild(this);
		}
		
		protected function remove():Boolean {
			try {
				container.removeChild(this);
			} catch (e:ArgumentError) {
				return false;
			}
			return true;
		}

		protected function checkBounds():void {
			if (!stage)
				return;
			
			var r:Rectangle = getBounds(stage);
			if (r.top < 0)
				y -= r.top;
			else if (r.bottom > stage.stageHeight)
				y -= r.bottom - stage.stageHeight;

			if (r.left < 0)
				x -= r.left;
			else if (r.right > stage.stageWidth)
				x -= r.right - stage.stageWidth + 5;
		}

		public function draw():void {
			var m:Matrix = new Matrix();
			m.createGradientBox(1, height, Math.PI / 2, 0, 0);

			graphics.clear();
			graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xe9e9e9], [.9, .9], [0, 255], m);
			graphics.lineStyle(1, 0x575757, 1, true);
			graphics.drawRoundRect(-paddingX, -paddingY, width + paddingX * 2, height + paddingY * 2, 6, 6);
			graphics.endFill();
		}
	}
}