package com.apexinnovations.transwarp.ui {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.display.AVM1Movie;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	
	import mx.core.UIComponent;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class ContentContainer extends UIComponent {
		
		protected var _content:DisplayObject;
		protected var _maintainAspectRatio:Boolean = true;
				
		protected var _contentWidth:Number;
		protected var _contentHeight:Number;
		
		protected var _isAS2Content:Boolean;
		
		protected var item:LoadingItem;
		
		public function ContentContainer() {
			super();
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		protected function addedToStage(event:Event):void {
			Courseware.instance.addEventListener(PageSelectionEvent.PAGE_SELECTION_CHANGED, pageChanged);
			
			//stage.addEventListener(FullScreenEvent.FULL_SCREEN, maximize);
			
			pageChanged(new PageSelectionEvent(Courseware.instance.currentPage));
		}
		
		protected function pageChanged(event:PageSelectionEvent):void {
			item = Courseware.instance.contentLoader.getItem(event.page.id);
			if(item.isLoaded) {
				_isAS2Content = item.content is AVM1Movie;
				content = item.content.parent;
			} else {
				content = null;
				if(item.status != LoadingItem.STATUS_ERROR) {
					dispatchEvent(new Event(Event.OPEN));
					item.addEventListener(Event.COMPLETE, contentLoaded);
					item.addEventListener(ProgressEvent.PROGRESS, contentProgress);
				} else
					dispatchEvent(new ErrorEvent(BulkLoader.ERROR, true, true, item.errorEvent.text));
			}
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
			
			SoundMixer.stopAll();
			_content = value;
			
			if(_content != null) {
				addChild(_content);
				invalidateSize();
				invalidateDisplayList();
			}
			dispatchEvent(new Event("contentChanged"));
		}
		
		override protected function updateDisplayList(width:Number, height:Number):void {
			super.updateDisplayList(width, height);
			if(_content) {	
				scaleContent(width, height);		
			}			
		}
		
		protected function scaleContent(width:Number, height:Number):void {
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
			
			_contentWidth = w;
			_contentHeight = h;
			
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
				_content.scaleX = _content.scaleY = scale;					
			} else {
				_content.scaleX = newXScale;
				_content.scaleY = newYScale;
			}
			dispatchEvent(new Event("contentSizeChanged"));
		}
		
		protected function unscaleContent():void {
			_content.x = _content.y = 0;
			_content.scaleX = _content.scaleY = 1;
		}
		
		protected function contentProgress(event:ProgressEvent):void {
			dispatchEvent(event);
		}
		
		protected function contentLoaded(event:Event):void {
			dispatchEvent(new Event(Event.COMPLETE));
			_isAS2Content = item.content is AVM1Movie;
			content = item.content.parent;						
			
			item.removeEventListener(Event.COMPLETE, contentLoaded);
			item.removeEventListener(ProgressEvent.PROGRESS, contentProgress);
			invalidateDisplayList();
		}

		[Bindable("contentChanged")] public function get isAS2Content():Boolean { return _isAS2Content; }
		
		[Bindable("contentSizeChanged")] public function get contentScaleX():Number { return _content ? _content.scaleX : 1; }
		[Bindable("contentSizeChanged")] public function get contentScaleY():Number { return _content ? _content.scaleY : 1 }
		[Bindable("contentSizeChanged")] public function get contentWidth():Number { return _contentWidth; }
		[Bindable("contentSizeChanged")] public function get contentHeight():Number { return _contentHeight; }
		[Bindable("contentSizeChanged")] public function get contentX():Number { return _content ? _content.x : 0; }
		[Bindable("contentSizeChanged")] public function get contentY():Number { return _content ? _content.y : 0; }
	}
}