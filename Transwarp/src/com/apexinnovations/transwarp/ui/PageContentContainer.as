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
	
	
	[Event(name="open", type="flash.events.Event")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="indeterminentLoad", type="com.apexinnovations.transwarp.events.TranswarpEvent")]
	public class PageContentContainer extends ContentContainer {
		
		protected var contentLoader:ContentLoader;
		protected var _page:Page;
		protected var watchedLoader:PageLoader;
		
		public function PageContentContainer() {
			super();
			addEventListener(FlexEvent.CREATION_COMPLETE, creationComplete);
		}
		
		public function replay():void {
			pageChanged();
		}
		
		public function reload():void {
			if(watchedLoader) {
				watchedLoader.load(true);
				pageChanged();
			}
		}
		
		[Bindable("loadingStatusChanged")] public function get loadingStatus():int {
			return watchedLoader ? watchedLoader.status : -1;
		}
		
		protected function creationComplete(event:FlexEvent):void {
			if(!Courseware.instance || !Courseware.instance.product)
				return; // This only occurrs with a total XML load failure
			
			contentLoader = new ContentLoader(Courseware.instance.product, Transwarp(parentApplication).mainLoader);
			
			//Courseware.instance.addEventListener(PageSelectionEvent.PAGE_SELECTION_CHANGED, pageChanged);
			pageChanged();
		}
		
		protected function pageChanged():void {
			if(!contentLoader)
				return;
			
			content = null;
			
			if(watchedLoader) {
				watchedLoader.removeEventListener(LoaderEvent.PROGRESS, contentProgress);
				watchedLoader.removeEventListener(TranswarpEvent.CONTENT_READY, contentReady);
				//watchedLoader.removeEventListener(LoaderEvent.COMPLETE);
				watchedLoader = null;
			}
			
			if(!_page)
				return;
			
			watchedLoader = contentLoader.getPageLoader(_page);
			watchedLoader.requestContent();
			
			dispatchEvent(new Event("loadingStatusChanged"));
			
			if(watchedLoader.contentReady)
				contentReady();
			else {
				watchedLoader.addEventListener(TranswarpEvent.CONTENT_READY, contentReady);
				switch(watchedLoader.status) {
					
					case LoaderStatus.LOADING:
						dispatchEvent(new Event(Event.OPEN));
						dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, watchedLoader.bytesLoaded, watchedLoader.bytesTotal));
						watchedLoader.addEventListener(LoaderEvent.PROGRESS, contentProgress);
						watchedLoader.addEventListener(LoaderEvent.COMPLETE, contentLoaded);
						break;
							
					case LoaderStatus.COMPLETED:
						dispatchEvent(new Event(Event.OPEN));
						dispatchEvent(new TranswarpEvent(TranswarpEvent.INDETERMINATE_LOAD));
						break;
					
					case LoaderStatus.FAILED:
						//how are we handling this?
						break;
					
				}
			} 
		}
		
		protected function contentProgress(event:LoaderEvent):void {
			var evt:ProgressEvent = new ProgressEvent(ProgressEvent.PROGRESS);
			evt.bytesLoaded = watchedLoader.bytesLoaded;
			evt.bytesTotal = watchedLoader.bytesTotal;
			dispatchEvent(evt);
		}
		
		protected function contentLoaded(event:Event):void {
			if(!watchedLoader.contentReady)
				dispatchEvent(new TranswarpEvent(TranswarpEvent.INDETERMINATE_LOAD));
			
		}
		
		protected function contentReady(event:Event = null):void {
			
			/*var page:Page = Courseware.instance.currentPage as Page;
			
			if(watchedLoader.page !== page)
				return; //shouldn't happen
			*/
			content = watchedLoader.swf;
			
			watchedLoader.playAudio();
			
			dispatchEvent(new Event("loadingStatusChanged"));
			dispatchEvent(new Event(Event.COMPLETE));
		}

		public function get page():Page { return _page; }
		public function set page(value:Page):void {
			if(_page == value)
				return;
			
			_page = value;
			pageChanged();
		}

		
	}
}