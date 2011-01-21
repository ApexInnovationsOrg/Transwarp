package ui {
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	
	import spark.core.SpriteVisualElement;
	import spark.primitives.Rect;
	
	import ui.tooltip.TooltipAttachPoint;

	public class IconButton extends SpriteVisualElement {
		private var _art:DisplayObject;
		private var down:Boolean;
		private var _highlightIntensity:Number = 0.3

		private var filterList:Array;

		public function set artClass(value:Class):void { art = new value(); }
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			if(_art)
				removeChild(_art);
			addChild(_art=value); 
			var bounds:Rectangle = getBounds(this);
			width = bounds.width;
			height = bounds.height
		}

		public function get highlightIntensity():Number { return _highlightIntensity; }
		public function set highlightIntensity(value:Number):void {	_highlightIntensity = value; initFilter(); }

		public function IconButton(art:DisplayObject = null) {
			if(art) 
				this.art = art;			
			
			buttonMode = true;

			initFilter();

			addEventListener(MouseEvent.ROLL_OVER, roll);
			addEventListener(MouseEvent.ROLL_OUT, roll);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		protected function onAdded(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
		}

		private function initFilter():void {
			var a:Number = _highlightIntensity + 1;
			var matrix:Array = [
				a, 0, 0, 0, 0,
				0, a, 0, 0, 0,
				0, 0, a, 0, 0,
				0, 0, 0, 1, 0];

			filterList = [new ColorMatrixFilter(matrix)];
		}

		private function roll(e:Event):void {
			if (e.type == MouseEvent.ROLL_OVER)
				filters = filterList;
			else
				filters = [];
		}

		private function mouseUp(e:Event):void {
			if (down && _art)
				_art.x -= 2, _art.y -= 2;
			down = false;
		}

		private function mouseDown(e:Event):void {
			down = true;
			if(_art)
				_art.x += 2, _art.y += 2;
		}

	}
}