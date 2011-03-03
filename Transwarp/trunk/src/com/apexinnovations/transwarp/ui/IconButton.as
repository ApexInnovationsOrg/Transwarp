package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.ui.tooltip.TooltipAttachPoint;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Rectangle;
	
	import spark.core.SpriteVisualElement;
	import spark.primitives.Rect;

	public class IconButton extends SpriteVisualElement {
		protected var _art:DisplayObject;
		
		protected var down:Boolean;
		protected var _highlightIntensity:Number = 0.3;

		protected var filterList:Array;

		public function set artClass(value:Class):void { art = new value(); }
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			if(_art)
				removeChild(_art);
			if (value) addChild(_art=value); 
			invalidateSize();
		}

		public function get highlightIntensity():Number { return _highlightIntensity; }
		public function set highlightIntensity(value:Number):void {	_highlightIntensity = value; initFilter(); }

		public function IconButton(art:DisplayObject = null) {
			if(art) 
				this.art = DisplayObject(art);			
			
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

		protected function initFilter():void {
			var a:Number = _highlightIntensity + 1;
			var matrix:Array = [
				a, 0, 0, 0, 0,
				0, a, 0, 0, 0,
				0, 0, a, 0, 0,
				0, 0, 0, 1, 0];

			filterList = [new ColorMatrixFilter(matrix)];
		}

		protected function roll(e:Event):void {
			if (e.type == MouseEvent.ROLL_OVER)
				filters = filterList;
			else
				filters = [];
		}

		protected function mouseUp(e:Event):void {
			if (down && _art)
				_art.x -= 2, _art.y -= 2;
			down = false;
		}

		protected function mouseDown(e:Event):void {
			down = true;
			if(_art)
				_art.x += 2, _art.y += 2;
		}

	}
}