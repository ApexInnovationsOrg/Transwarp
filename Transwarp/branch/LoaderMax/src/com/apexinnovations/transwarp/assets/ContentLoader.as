package com.apexinnovations.transwarp.assets {
	import br.com.stimuli.loading.BulkLoader;
	import br.com.stimuli.loading.loadingtypes.LoadingItem;
	
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.data.Product;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.utils.Utils;
	
	import flash.display.AVM1Movie;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.sampler.stopSampling;

	TranswarpVersion.revision = "$Rev$";
	
	public class ContentLoader {
		
		protected var pages:Vector.<Page>;
		protected var loader:BulkLoader;
		
		protected var lockedItem:LoadingItem;
		
		
		public function ContentLoader(product:Product) {
			pages = new Vector.<Page>();
			for each(var c:Course in product.courses)
				pages = pages.concat(c.pages);	
				
			loader = new BulkLoader("ContentLoader", 12, BulkLoader.LOG_SILENT);	
			
			for each(var p:Page in pages)
				addPage(p);
				
			loader.start();
		}
		
		public function getItem(pageID:uint):LoadingItem {
			var item:LoadingItem = loader.get(String(pageID));
			var index:int = idToIndex(pageID);

			if(index == -1) //Should never happen
				return null;
			
			if(!item)
				item = addPage(pages[index]);				
			
			var priority:int = loader.highestPriority + 5;
			
			loader.changeItemPriority(item.id, priority--);
						
			changePriorityInRange(index, index+2, priority)
			changePriorityInRange(index-1, index-1, priority-3);
			
			if(item != lockedItem && lockedItem && lockedItem.isLoaded && lockedItem.content is AVM1Movie) {
				loader.remove(lockedItem);
				loader.start();
			}			
			
			lockedItem = item;
			
			return item;
		}
		
		protected function addPage(page:Page):LoadingItem {
			var item:LoadingItem = loader.add(getURL(page), {id: page.id});
			item.addEventListener(Event.INIT, preloadInit);
			item.addEventListener(Event.COMPLETE, preloadInit);
			item.addEventListener(ProgressEvent.PROGRESS, setupErrorHandling);
			item.addEventListener(BulkLoader.ERROR, onItemError);
			return item;
		}
		
		private function uncaughtErrorHandler(event:Event):void {
			trace("Script Error in slide: " + (event.target as LoaderInfo).url);
			//TODO: Log this and replace the slide with a 'broken slide' or something similar to prevent looping issues
			
			event.preventDefault();
			event.stopPropagation();
		}
		
		
		protected function preloadInit(event:Event):void {
			var item:LoadingItem = event.target as LoadingItem;
			var content:* = item.content;
					
			if(!content)
				return;
			
			if(content is Loader) {
				Loader(content).contentLoaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			}
			
			if(item != lockedItem) {
				if(content is AVM1Movie) {
					loader.remove(item);
					loader.start();
				} else if (content is MovieClip)
					MovieClip(content).stop();
			}
			
			//TODO: Load configuration here?
			
			item.removeEventListener(Event.COMPLETE, preloadInit);
			item.removeEventListener(Event.INIT, preloadInit);
		}
		
		protected function idToIndex(id:uint):int {
			for (var i:int=0; i<pages.length; ++i)
				if(id == pages[i].id)
					return i;
			return -1;
		}
		
		protected function changePriorityInRange(startIndex:int, endIndex:int, startPriority:int):void {
			startIndex = Math.max(0, startIndex);
			endIndex = Math.min(pages.length-1, endIndex);
			for(var i:int = startIndex; i <= endIndex; ++i) {
				loader.changeItemPriority(String(pages[i].id), startPriority--);
			}
		}
		
		protected function getURL(page:Page):String {
			if(!page)
				return '';
			
			return Courseware.instance.rootFolder + '/' + page.swf + makeDateHash(page); 
		}
		
		protected function makeDateHash(page:Page):String {
			if(page.updates.length > 0)
				return '?' + Utils.jenkinsHash(page.updates[0].time.toUTCString()).toString();
			return '';
		}
		
		protected function onItemError(event:ErrorEvent):void {
			event.stopPropagation();
			event.preventDefault();
			Courseware.log("PAGE LOAD ERROR: " + event.type + ": " + event.text);
		}
		
		protected function setupErrorHandling(event:Event):void {
			var item:LoadingItem = event.target as LoadingItem;
			var itemLoader:Loader = loader.getDisplayObjectLoader(item.id);
			
			itemLoader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtErrorHandler);
			
			item.removeEventListener(ProgressEvent.PROGRESS, setupErrorHandling);
		}
		
				
		
	}
}