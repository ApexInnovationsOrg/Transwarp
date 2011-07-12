package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.TranswarpSlide;
	import com.apexinnovations.transwarp.assets.ContentLoader;
	import com.apexinnovations.transwarp.assets.PageLoader;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.ContentReadyEvent;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.MP3Loader;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	
	import mx.binding.utils.BindingUtils;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class ContentContainer extends UIComponent {
		
		protected var _content:DisplayObject;		
		protected var _rawContent:DisplayObject;
		
		protected var contentLoader:ContentLoader;
		
		protected var watchedLoader:PageLoader;
		
		
		public function ContentContainer() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
		}
		
		protected function creationComplete(event:FlexEvent):void {
			if(!Courseware.instance || !Courseware.instance.product)
				return; // This only occurrs with a total XML load failure
			
			contentLoader = new ContentLoader(Courseware.instance.product);
			Courseware.instance.addEventListener(PageSelectionEvent.PAGE_SELECTION_CHANGED, pageChanged);
			pageChanged();
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
		
		public function replay():void {
			pageChanged();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if(_content)
				scaleContent(unscaledWidth, unscaledHeight);
		}
		
		protected function pageChanged(event:PageSelectionEvent = null):void {
			if(!contentLoader)
				return;
			
			content = null;
			
			if(watchedLoader) {
				watchedLoader.removeEventListener(ContentReadyEvent.CONTENT_READY, contentLoaded);
				watchedLoader.removeEventListener(LoaderEvent.PROGRESS, contentProgress);
				watchedLoader.removeEventListener(ContentReadyEvent.CONTENT_READY, contentLoaded);
			}
			
			watchedLoader = contentLoader.getLoader(Courseware.instance.currentPage);
			watchedLoader.requestContent();
			
			if(watchedLoader.contentReady)
				contentLoaded();
			else {
				watchedLoader.addEventListener(ContentReadyEvent.CONTENT_READY, contentLoaded);
				if(watchedLoader.status == LoaderStatus.LOADING) {
					dispatchEvent(new Event(Event.OPEN));
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, watchedLoader.bytesLoaded, watchedLoader.bytesTotal));
					watchedLoader.addEventListener(LoaderEvent.PROGRESS, contentProgress);
				} else if(watchedLoader.status == LoaderStatus.FAILED) {
					//How are we handling this?
				}
			} 
		}
		
		protected function contentProgress(event:LoaderEvent):void {
			var evt:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			evt.bytesLoaded = watchedLoader.bytesLoaded;
			evt.bytesTotal = watchedLoader.bytesTotal;
			dispatchEvent(evt);
		}
		
		protected function contentLoaded(event:ContentReadyEvent = null):void {
						
			var page:Page = Courseware.instance.currentPage;
			
			if(watchedLoader.page !== page)
				return; //shouldn't happen
			
			content = watchedLoader.swf;
			
			watchedLoader.playAudio();
			
			dispatchEvent(new Event(Event.COMPLETE));
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