package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.data.Product;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.utils.Utils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.SWFLoader;
	import com.greensock.loading.data.MP3LoaderVars;
	import com.greensock.loading.data.SWFLoaderVars;
	import com.greensock.loading.display.ContentDisplay;
	
	import flash.events.UncaughtErrorEvent;

	TranswarpVersion.revision = "$Rev$";
	
	public class ContentLoader {
		
		protected var pages:Vector.<Page>;
		protected var loader:LoaderMax;
		
		protected var swfVars:Object;
		protected var mp3Vars:Object;
		
		public function ContentLoader(product:Product) {
			
			swfVars = {allowMalformedURL : true, autoPlay: false, crop: false, scaleMode: "none"};
			mp3Vars = {allowMalformedURL : true, autoPlay: false};
			
			pages = new Vector.<Page>();
			for each(var c:Course in product.courses) {
				pages = pages.concat(c.pages);
			}
			
			loader = new LoaderMax({auditSize:false, maxConnections: 6});
			loader.addEventListener(LoaderEvent.CHILD_FAIL, childFailed);
			loader.addEventListener(LoaderEvent.IO_ERROR, ioError);
			
			for each(var p:Page in pages){
				addPage(p);
			}
			
			loader.load();
		}
		
		public function getLoader(page:Page):LoaderMax {
			var pageLoader:LoaderMax = loader.getLoader("loader"+page.id);
			var index:int = pages.indexOf(page);
			if(index > 0)
				LoaderMax.prioritize("loader"+pages[index-1].id);
			 
			var i:int = Math.min(index + 4, pages.length-1);
			
			while(i >= index)
				LoaderMax.prioritize("loader" + pages[i--].id);
			
			return pageLoader;		
		}
		
		
		protected function addPage(page:Page):void {
			var pageLoader:LoaderMax = new LoaderMax({name:"loader"+page.id});
			
			var baseURL:String = Courseware.instance.rootFolder + '/';
			var dateHash:String = makeDateHash(page);
			
			var swf:SWFLoader = new SWFLoader(baseURL + page.swf + dateHash, new SWFLoaderVars(swfVars).name("swf"+page.id))
			swf.addEventListener(LoaderEvent.INIT, swfInit);
			
			pageLoader.append(swf);

			if(page.audio != '' && page.audio != null)
				pageLoader.append(new MP3Loader(baseURL + page.audio + dateHash, new MP3LoaderVars(mp3Vars).name("audio"+page.id)));
						
			loader.append(pageLoader);
			
			//TODO: Load Configuration						
		}
		
		protected function makeDateHash(page:Page):String {
			if(page.updates.length > 0)
				return '?' + Utils.jenkinsHash(page.updates[0].time.toUTCString()).toString();
			else 
				return '';
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
			
		}
		
		protected function ioError(event:LoaderEvent):void {
			
		}
	}	
}