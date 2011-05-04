package com.apexinnovations.transwarp.ui {
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	
	import mx.core.UIComponent;
	
	public class ContentContainer extends UIComponent {
		
		protected var _content:DisplayObject;
		protected var _maintainAspectRatio:Boolean = true;
		
		
		public function ContentContainer() {
			super();
		}
		
		public function get maintainAspectRatio():Boolean{ return _maintainAspectRatio; }
		public function set maintainAspectRatio(value:Boolean):void	{
			_maintainAspectRatio = value;
			invalidateDisplayList();
		}
		
		public function get content():DisplayObject { return _content; }
		public function set content(value:DisplayObject):void {
			if(_content != null) 
				removeChild(_content);
			
			_content = value;
			if(_content != null) {
				addChild(_content);
				invalidateSize();
				invalidateDisplayList();
			}
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			if(_content) {	
				scaleContent();		
			}			
		}
		
		protected function scaleContent():void {
			unscaleContent(); //prevent previous scaling from interfering
			
			var w:Number = _content.width;
			var h:Number = _content.height;
			
			if(_content is Loader) { //use loader info instead if available
				var info:LoaderInfo = Loader(_content).contentLoaderInfo;
				if(info) {
					w = info.width;
					h = info.height;
				}
			}
			
			//There is a bug that causes a loaded swf to report its size as 0 for a short time
			var newXScale:Number = w == 0 ? 1 : width / w;
			var newYScale:Number = h == 0 ? 1 : height / h;
			
			if(_maintainAspectRatio){
				var scale:Number;
				if(newXScale > newYScale) {
					scale = newYScale;
					_content.x = Math.floor((width - w*scale)/2); // Center horizontally
				} else {
					scale = newXScale;
					_content.y = Math.floor((height - h*scale)/2); // Center vertically
				}
				//trace(scale);
				_content.scaleX = _content.scaleY = scale;					
			} else {
				_content.scaleX = newXScale;
				_content.scaleY = newYScale;
			}
		}
		
		protected function unscaleContent():void {
			_content.x = _content.y = 0;
			_content.scaleX = _content.scaleY = 1;
		}
		
		
	}
}