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
		protected var _enabled:Boolean = true;

		protected var filterList:Array;
		protected var defaultFilter:ColorMatrixFilter = initDefaultFilter();
		protected var highlightFilter:ColorMatrixFilter = initHighlightFilter();
		protected var disabledFilter:ColorMatrixFilter = initDisabledFilter();

		public function set artClass(value:Class):void { art = new value(); }
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			if(_art)
				removeChild(_art);
			if (value) addChild(_art=value); 
			invalidateSize();
		}

		public function get highlightIntensity():Number { return _highlightIntensity; }
		public function set highlightIntensity(value:Number):void {	_highlightIntensity = value; highlightFilter = initHighlightFilter(); }

		public function IconButton(art:DisplayObject = null) {
			if(art) 
				this.art = DisplayObject(art);			
			
			buttonMode = true;

			highlightFilter = initHighlightFilter();

			addEventListener(MouseEvent.ROLL_OVER, roll);
			addEventListener(MouseEvent.ROLL_OUT, roll);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}

		
		public function set enabled(val:Boolean):void {
			_enabled = val;
			
			filters = [_enabled ? defaultFilter : disabledFilter];
			
			// Toggle ability to handle mouse-down events
			if (_enabled) {
				addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			} else {
				removeEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			}
		}
		
		public function get enabled():Boolean {
			return _enabled;
		}

		protected function onAdded(e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
		}
		
		protected function initDefaultFilter():ColorMatrixFilter {
			var matrix:Array = [
				1, 0, 0, 0, 0,
				0, 1, 0, 0, 0,
				0, 0, 1, 0, 0,
				0, 0, 0, 1, 0];
			
			return new ColorMatrixFilter(matrix);
		}
		
		protected function initDisabledFilter():ColorMatrixFilter {
			var matrix:Array = [
				0.309, 0.609, 0.082, 0, 0,
				0.309, 0.609, 0.082, 0, 0,
				0.309, 0.609, 0.082, 0, 0,
				0.6, 0.6, 0.6, 0, 0];
			
			return new ColorMatrixFilter(matrix);
		}
		
		protected function initHighlightFilter():ColorMatrixFilter {
			var a:Number = _highlightIntensity + 1;
			var matrix:Array = [
				a, 0, 0, 0, 0,
				0, a, 0, 0, 0,
				0, 0, a, 0, 0,
				0, 0, 0, 1, 0];
			
			return new ColorMatrixFilter(matrix);
		}
		
		protected function roll(e:Event):void {
			if (_enabled) {
				if (e.type == MouseEvent.ROLL_OVER)
					filters = [highlightFilter];
				else
					filters = [];
			}
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