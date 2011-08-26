package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.Transwarp;
	import com.apexinnovations.transwarp.assets.ContentLoader;
	import com.apexinnovations.transwarp.assets.loaders.PageLoader;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderStatus;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	TranswarpVersion.revision = "$Rev$";
	
	
	public class ContentContainer extends UIComponent {
		
		protected var _content:DisplayObject;		
		protected var _rawContent:DisplayObject;	
		
		public function ContentContainer() {
			super();	
		}
		
		
		[Bindable] public function get content():DisplayObject { return _content; }
		protected function set content(value:DisplayObject):void {
			if(_content) {
				removeChild(_content);
				SoundMixer.stopAll();
			}
			
			_content = value;
			
			if(_content) {
				addChild(_content);
				
				if(_content is Loader)
					rawContent = Loader(_content).content;
				else
					rawContent = content;

				invalidateDisplayList();
			}
		}
		
		[Bindable] public function get rawContent():DisplayObject { return _rawContent; }
		protected function set rawContent(value:DisplayObject):void {
			_rawContent = value;
		}
		
		
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if(_content)
				scaleContent(unscaledWidth, unscaledHeight);
		}
				
		
		protected function scaleContent(width:Number, height:Number):void {
			unscaleContent(); //prevent previous scaling from interfering
			
			var w:Number = _content.width;
			var h:Number = _content.height;
			
			
			if(_content is Loader) {
				var info:LoaderInfo = Loader(_content).contentLoaderInfo;
				w = info.width;
				h = info.height;
				
			} else if(_content.loaderInfo) { //use loader info instead if available
				w = _content.loaderInfo.width;
				h = _content.loaderInfo.height;
			}
			
			//There is a bug that causes a loaded swf to report its size as 0 for a short time
			var newXScale:Number = w == 0 ? 1 : width / w;
			var newYScale:Number = h == 0 ? 1 : height / h;
			
			var scale:Number;		
			
			if(newXScale > newYScale) {
				scale = newYScale;
				_content.x = Math.floor((width - w*scale)/2); // Center horizontally
			} else {
				scale = newXScale;
				_content.y = Math.floor((height - h*scale)/2); // Center vertically
			}
			_content.scaleX = _content.scaleY = scale;					
			
			// Supposedly scrollRect is faster than using an actual mask for plain rectangle masks
			// the code for it is shorter at least. =)
			_content.scrollRect = new Rectangle(0,0,w,h);			
		}
		
		protected function unscaleContent():void {
			_content.x = _content.y = 0;
			_content.scaleX = _content.scaleY = 1;
		}
		
	}
}