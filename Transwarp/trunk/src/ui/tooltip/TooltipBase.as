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
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	import mx.core.IVisualElementContainer;
	
	import spark.core.SpriteVisualElement;
	
	import ui.Component;
	
	public class TooltipBase extends Component
	{
		public static var defaultContainer:DisplayObjectContainer;
		
		protected var container:DisplayObjectContainer
		protected var tween:TweenLite;
		protected var lastShow:Number = -1;
		protected var ox:Number;
		protected var oy:Number;
		protected var _attachPoint:String;
		protected var _paddingX:Number = 2;
		protected var _paddingY:Number = 0;
		protected var _cornerRadius:Number = 6;
		
		public var anchorObject:DisplayObject;
		public var delayTolerance:Number = 1500;
		public var followMouse:Boolean = false;
		
		public function get paddingX():Number { return _paddingX; }
		public function set paddingX(value:Number):void { _paddingX = value; invalidate();}
		
		public function get paddingY():Number { return _paddingY; }
		public function set paddingY(value:Number):void { _paddingY = value; invalidate();}
		
		public function get cornerRadius():Number { return _cornerRadius; }
		public function set cornerRadis(value:Number):void { _cornerRadius = value; invalidate();}
		
		public function get attachPoint():String { return _attachPoint; }
		public function set attachPoint(value:String):void { _attachPoint = value; update();} // TODO: Validate to known attachpoints?

		public function setOffset(x:Number, y:Number):void {ox=x, oy=y; update(); }
		
		public function TooltipBase(container:DisplayObjectContainer=null, attachPoint:String="topright", offsetX:Number=0, offsetY:Number=0) {
			super();
			
			this.container = container != null ? container : defaultContainer;
			
			if(this.container == null)
				throw new ArgumentError("A default container (TooltipBase.defaultContainer) must be specified if one is not provided to the constructor");
			
			mouseEnabled = false;
			ox = offsetX, oy = offsetY;
			_attachPoint = attachPoint;
			
			filters = [new DropShadowFilter(2,45,0,0.5,3,3)];
			invalidate();
		}		
		
		public function update(forceRedraw:Boolean = false):void {
			if (forceRedraw)
				invalidate();
			handleAttachPoint();
			checkBounds();
		}

		public function show(e:MouseEvent = null):void {
			add();
			alpha = 0;
			update();
			
			if(followMouse)
				addEventListener(Event.ENTER_FRAME, mouseFollow);
			
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
			removeEventListener(Event.ENTER_FRAME, mouseFollow);
			remove();
		}

		public function handleAttachPoint():void {
			var attached:Boolean = remove();
			
			var bounds:Rectangle = getBounds(container);
			var anchor:Rectangle;
			if (anchorObject)
				anchor = anchorObject.getBounds(container);
			else
				anchor = new Rectangle(container.mouseX - 4, container.mouseY, 18, 23);

			switch (_attachPoint) {
				case TooltipAttachPoint.TOPLEFT:
				case TooltipAttachPoint.LEFT:
				case TooltipAttachPoint.BOTTOMLEFT:
					x = anchor.x - bounds.width + _paddingX;
					break;

				case TooltipAttachPoint.TOPRIGHT:
				case TooltipAttachPoint.RIGHT:
				case TooltipAttachPoint.BOTTOMRIGHT:
					x = anchor.x + anchor.width + _paddingX;
					break;

				case TooltipAttachPoint.TOP:
				case TooltipAttachPoint.BOTTOM:
					x = anchor.x + (anchor.width - bounds.width) / 2 + _paddingX;
					break;
			}

			switch (_attachPoint) {
				case TooltipAttachPoint.TOP:
				case TooltipAttachPoint.TOPLEFT:
				case TooltipAttachPoint.TOPRIGHT:
					y = anchor.y - bounds.height + _paddingY;
					break;

				case TooltipAttachPoint.BOTTOM:
				case TooltipAttachPoint.BOTTOMLEFT:
				case TooltipAttachPoint.BOTTOMRIGHT:
					y = anchor.y + anchor.height + _paddingY;
					break;

				case TooltipAttachPoint.LEFT:
				case TooltipAttachPoint.RIGHT:
					y = anchor.y + (anchor.height - bounds.height) / 2 + _paddingY;
					break;
			}

			x += ox, y += oy;

			if (attached)
				add();
		}
		
		protected function add():void {
			if(container is IVisualElementContainer)
				IVisualElementContainer(container).addElement(this)
			else
				container.addChild(this);
		}
		
		
		protected function remove():Boolean {
			try {
				if(container is IVisualElementContainer)
					IVisualElementContainer(container).removeElement(this)
				else
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
	
		protected function mouseFollow(e:Event):void{
			update();
		}
		
		public override function draw():void {
			graphics.clear();
			
			var bounds:Rectangle = getBounds(this);
									
			var m:Matrix = new Matrix();
			m.createGradientBox(1, bounds.height, Math.PI / 2, 0, 0);
			graphics.beginGradientFill(GradientType.LINEAR, [0xffffff, 0xe9e9e9], [.9, .9], [0, 255], m);

			graphics.lineStyle(1, 0x575757, 1, true);
			
			graphics.drawRoundRect(bounds.x -_paddingX, bounds.y -_paddingY, bounds.width + _paddingX * 2, bounds.height + _paddingY * 2, _cornerRadius);
			graphics.endFill();
			
			update();
			
			super.draw();
		}
	}
}