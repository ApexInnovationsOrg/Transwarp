package ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	
	import flash.display.Shape;
	import ui.tooltip.SimpleTooltip;
	import ui.tooltip.TooltipAttachPoint;
	
	public class IconButton extends Sprite
	{
		private var highlight:Bitmap;
		private var _art:DisplayObject;
		private var down:Boolean;
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			_art = value;
			updateHighlight();
		}
				
		public function get highlightAlpha():Number { return highlight.alpha;}
		public function set highlightAlpha(value:Number):void { highlight.alpha = value; }
		
		public function IconButton(container:DisplayObjectContainer, art:DisplayObject) {
			container.addChild(this);
			
			_art = art;
					
			highlight = new Bitmap();
			highlight.visible = false;
			updateHighlight();
			
			addChild(_art);
			addChild(highlight);
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, roll);
			addEventListener(MouseEvent.ROLL_OUT, roll);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);		
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}
				
		
		private function updateHighlight():void {
			var bmp:BitmapData = new BitmapData(_art.width, _art.height, true, 0x00ffffff);
			bmp.draw(_art);
			highlight.bitmapData = bmp; 
						
			highlight.blendMode = BlendMode.ADD;
			highlight.alpha = 0.3
		}
		
		private function roll(e:Event):void {
			highlight.visible = e.type == MouseEvent.ROLL_OVER;				
		}
		
		private function mouseUp(e:Event):void {
			if(down)
				x -= 2, y -= 2;
			down = false;
		}
		
		private function mouseDown(e:Event):void {
			down = true;
			x += 2;
			y += 2;
		}		
		
	}
}