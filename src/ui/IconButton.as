package ui
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DisplacementMapFilter;
	
	import ui.tooltip.TooltipAttachPoint;
	
	public class IconButton extends Sprite
	{
		private var highlight:Bitmap;
		private var bmp:BitmapData;
		private var _art:DisplayObject;
		private var down:Boolean;
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			_art = value;
			updateHighlight();
		}
				
		public function get highlightAlpha():Number { return highlight.alpha;}
		public function set highlightAlpha(value:Number):void { highlight.alpha = value; }
		
		public function IconButton(art:DisplayObject) {
			_art = art;
					
			highlight = new Bitmap();
			highlight.visible = false;
			bmp = new BitmapData(_art.width, _art.height, true, 0x00ffffff);
			highlight.bitmapData = bmp;
			
			addChild(_art);
			addChild(highlight);
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, roll);
			addEventListener(MouseEvent.ROLL_OUT, roll);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);		
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
				
		protected function onAdded(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}		
		
		private function updateHighlight():void {
			if(_art.width != bmp.width || _art.height != bmp.height) {
				bmp = new BitmapData(_art.width, _art.height, true, 0x00ffffff);
				highlight.bitmapData = bmp;
			}
			
			bmp.draw(_art);
			highlight.bitmapData = bmp; 
						
			highlight.blendMode = BlendMode.ADD;
			highlight.alpha = 0.3
		}
		
		private function roll(e:Event):void {
			updateHighlight();
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