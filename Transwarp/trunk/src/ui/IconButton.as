package ui {
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
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DisplacementMapFilter;

	import ui.tooltip.TooltipAttachPoint;

	public class IconButton extends Sprite {
		private var _art:DisplayObject;
		private var down:Boolean;
		private var _highlightAlpha:Number = 0.3

		private var filterList:Array;

		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {	removeChild(_art); addChild(_art=value); }

		public function get highlightAlpha():Number { return _highlightAlpha; }
		public function set highlightAlpha(value:Number):void {	_highlightAlpha = value; initFilter(); }

		public function IconButton(art:DisplayObject) {
			_art = art;
			addChild(_art);
			
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
			var a:Number = _highlightAlpha + 1;
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
			if (down)
				x -= 2, y -= 2;
			down = false;
		}

		private function mouseDown(e:Event):void {
			down = true;
			x += 2, y += 2;
		}

	}
}