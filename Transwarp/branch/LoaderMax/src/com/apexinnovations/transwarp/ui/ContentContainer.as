package com.apexinnovations.transwarp.ui {
	import com.apexinnovations.transwarp.assets.ContentLoader;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.PageSelectionEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.MP3Loader;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.geom.Rectangle;
	import flash.media.SoundMixer;
	
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	public class ContentContainer extends UIComponent {
		
		protected var _content:MovieClip;		
		protected var contentLoader:ContentLoader;
		
		protected var watchedLoader:LoaderMax;
		
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
		
		[Bindable] public function get content():MovieClip { return _content; }
		protected function set content(value:MovieClip):void {
			if(_content) {
				trace("removing old content");
				removeChild(_content);
				SoundMixer.stopAll();
			}
			
			_content = value;
			
			if(_content) {
				addChild(_content);
				invalidateDisplayList();
			}
		}
		
		public function replay():void {
			content = null;
			contentLoaded();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void {
			if(_content) {
				scaleContent(unscaledWidth, unscaledHeight);
			}
		}
		
		protected function pageChanged(event:PageSelectionEvent = null):void {
			if(!contentLoader)
				return;
			
			content = null;
			
			if(watchedLoader) {
				watchedLoader.removeEventListener(LoaderEvent.COMPLETE, contentLoaded);
				watchedLoader.removeEventListener(LoaderEvent.PROGRESS, contentProgress);
			}
			
			watchedLoader = contentLoader.getLoader(Courseware.instance.currentPage);
						
			if(watchedLoader.status == LoaderStatus.COMPLETED)
				contentLoaded();
			else {
				if(watchedLoader.status == LoaderStatus.LOADING) {
					dispatchEvent(new Event(Event.OPEN));
					dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, watchedLoader.bytesLoaded, watchedLoader.bytesTotal));
					watchedLoader.addEventListener(LoaderEvent.PROGRESS, contentProgress);
					watchedLoader.addEventListener(LoaderEvent.COMPLETE, contentLoaded);
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
		
		protected function contentLoaded(event:LoaderEvent = null):void {
						
			var page:Page = Courseware.instance.currentPage;
			
			if(page.audio != '') {
				var mp3:MP3Loader = MP3Loader(LoaderMax.getLoader("audio"+page.id));
				if(mp3.status == LoaderStatus.COMPLETED) 
					mp3.playSound();
			}
			
			content = LoaderMax.getContent("swf"+page.id).rawContent as MovieClip;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		protected function scaleContent(width:Number, height:Number):void {
			unscaleContent(); //prevent previous scaling from interfering
			
			var w:Number = _content.width;
			var h:Number = _content.height;
			
			if(_content.loaderInfo) { //use loader info instead if available
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