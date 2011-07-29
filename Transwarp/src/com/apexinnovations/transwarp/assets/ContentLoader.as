package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.data.Product;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.SWFLoader;
	
	import flash.events.EventDispatcher;
	import flash.events.UncaughtErrorEvent;

	TranswarpVersion.revision = "$Rev$";
	
	public class ContentLoader extends EventDispatcher{
		
		protected var pages:Vector.<Page>;
		protected var loader:LoaderMax;
		
		public function ContentLoader(product:Product) {
			super();
			
			pages = new Vector.<Page>();
			for each(var c:Course in product.courses) {
				pages = pages.concat(c.pages);
			}
			
			loader = new LoaderMax({auditSize:false, maxConnections: 6});
			loader.addEventListener(LoaderEvent.CHILD_FAIL, childFailed);
			loader.addEventListener(LoaderEvent.IO_ERROR, ioError);
			
			for each(var p:Page in pages){
				loader.append(new PageLoader(p));
			}
			
			loader.load();
		}
		
		
		public function getLoader(page:Page):PageLoader {
			var pageLoader:PageLoader = loader.getLoader(String(page.id));
			var index:int = pages.indexOf(page);
			if(index > 0)
				LoaderMax.prioritize(String(pages[index-1].id), false);
			 
			var i:int = Math.min(index + 4, pages.length-1);
			
			while(i >= index)
				LoaderMax.prioritize(String(pages[i--].id), i == index);
			
			return pageLoader;		
		}
		
		protected function swfInit(event:LoaderEvent):void {
			var loader:SWFLoader = event.target as SWFLoader;
			loader.rawContent.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtChildError);			
		}
		
		protected function uncaughtChildError(event:UncaughtErrorEvent):void {
			trace("caught error in slide", event);
			event.preventDefault();
			//Courseware.log(
		}
		
		protected function childFailed(event:LoaderEvent):void {
			event.preventDefault();
			event.stopPropagation();
		}
		
		protected function ioError(event:LoaderEvent):void {
			event.preventDefault();
			event.stopPropagation();
		}
	}	
}