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
	public class PageContentContainer extends ContentContainer {
		
		protected var contentLoader:ContentLoader;
		
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
			
			Courseware.instance.addEventListener(PageSelectionEvent.PAGE_SELECTION_CHANGED, pageChanged);
			pageChanged();
		}
		
		protected function pageChanged(event:PageSelectionEvent = null):void {
			if(!contentLoader)
				return;
			
			content = null;
			
			if(watchedLoader) {
				watchedLoader.removeEventListener(LoaderEvent.PROGRESS, contentProgress);
				watchedLoader.removeEventListener(TranswarpEvent.CONTENT_READY, contentLoaded);
			}
			
			if(!(Courseware.instance.currentPage as Page))
				return;
			
			watchedLoader = contentLoader.getPageLoader(Courseware.instance.currentPage as Page);
			watchedLoader.requestContent();
			
			dispatchEvent(new Event("loadingStatusChanged"));
			
			if(watchedLoader.contentReady)
				contentLoaded();
			else {
				watchedLoader.addEventListener(TranswarpEvent.CONTENT_READY, contentLoaded);
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
		
		protected function contentLoaded(event:Event = null):void {
			
			var page:Page = Courseware.instance.currentPage as Page;
			
			if(watchedLoader.page !== page)
				return; //shouldn't happen
			
			content = watchedLoader.swf;
			
			watchedLoader.playAudio();
			dispatchEvent(new Event("loadingStatusChanged"));
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
	}
}