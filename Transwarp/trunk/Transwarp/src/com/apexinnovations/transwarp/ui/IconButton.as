package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BitmapFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	
	import spark.core.SpriteVisualElement;
	import spark.filters.DropShadowFilter;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class IconButton extends SpriteVisualElement {
		protected var _art:DisplayObject;
		
		protected var down:Boolean;
		protected var _highlightIntensity:Number = 0.3;
		protected var _enabled:Boolean = true;

		protected var highlightFilter:BitmapFilter = initHighlightFilter();
		protected var disabledFilter:BitmapFilter = initDisabledFilter();
				
		protected var dropShadowFilter:DropShadowFilter = initDropShadowFilter();
		
		public function IconButton(art:DisplayObject = null) {
			if(art) 
				this.art = DisplayObject(art);			
			
			buttonMode = true;
			
			addEventListener(MouseEvent.ROLL_OVER, roll);
			addEventListener(MouseEvent.ROLL_OUT, roll);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			
			addEventListener(Event.ADDED_TO_STAGE, onAdded);
			
			filters = getNormalFilters();
			mouseChildren = false;
		}		
		
/*==========================================================================
		
							Getters/Setters
		
==========================================================================*/
		
		public function set artClass(value:Class):void { art = new value(); }
		
		public function get art():DisplayObject { return _art; }
		public function set art(value:DisplayObject):void {
			if(_art)
				removeChild(_art);
			
			if (value) addChild(value);
			
			positionArt();
			
			_art = value;
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			positionArt();
			initializeHitArea();
			
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			positionArt();
			initializeHitArea();
		}

		
		public function set enabled(value:Boolean):void {
			_enabled = value;
			
			filters = _enabled ? getNormalFilters() :  getDisabledFilters();
			
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
			
/*==========================================================================
		
							Filters / Utility
		
==========================================================================*/
			
		protected static function initDisabledFilter():BitmapFilter {
			var matrix:Array = [
				0.309, 0.609, 0.082, 0,   0,
				0.309, 0.609, 0.082, 0,   0,
				0.309, 0.609, 0.082, 0,   0,
				0,     0,     0,     0.4, 0];
			
			return new ColorMatrixFilter(matrix)
		}
		
		protected static function initHighlightFilter():BitmapFilter  {
			return new GlowFilter(0xffffff, .5, 5, 5);		
		}
		
		protected static function initDropShadowFilter():DropShadowFilter {
			return new DropShadowFilter(2.3, 71.6, 0, .5, 2.3, 2.3);;
		}	
	///////////////////////////////////////////////////////////
		
		protected function getNormalFilters():Array {
			return [dropShadowFilter];
		}
		
		protected function getHighlightFilters():Array {
			return [highlightFilter, dropShadowFilter];
		}
		
		protected function getDisabledFilters():Array {
			return [disabledFilter]
		}
				
	///////////////////////////////////////////////////////////
		
		protected function positionArt():void {
			if(!_art)
				return;
			
			_art.x = (width > 0 ? width/2 - _art.width/2 : 0) + (down ? 2 : 0);
			_art.y = height > 0 ? height/2 - _art.height/2 : 0 + (down? 2 : 0);
		}
		
		protected function initializeHitArea():void {
			graphics.clear();
			
			graphics.beginFill(0x00ff00, 0);
			
			graphics.drawRect(x, y, width, height);
			graphics.endFill();
		}
		
		
/*==========================================================================

							Mouse Events

==========================================================================*/

				
		protected function roll(e:Event):void {
			if (_enabled) {
				if (e.type == MouseEvent.ROLL_OVER)
					filters = getHighlightFilters();
				else
					filters = getNormalFilters();
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