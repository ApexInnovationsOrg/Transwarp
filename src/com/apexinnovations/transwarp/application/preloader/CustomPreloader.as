package com.apexinnovations.transwarp.application.preloader {
	import com.apexinnovations.transwarp.application.CustomSystemManager;
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent;
	import com.apexinnovations.transwarp.webservices.ApexWebService;
	import com.apexinnovations.transwarp.webservices.LogService;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.*;
	
	import mx.preloaders.SparkDownloadProgressBar;

	public class CustomPreloader extends SparkDownloadProgressBar {
		
		protected var _manager:CustomSystemManager;
		
		protected var _xml:XML;
		
		public function CustomPreloader() {
			super();
		}
		
		override public function set preloader(value:Sprite):void {
			super.preloader = value;
			value.addEventListener(CustomSystemManagerEvent.FRAME_SUSPENDED, onSuspend);
		}
		
		protected function onSuspend(e:CustomSystemManagerEvent):void {
			(e.target as IEventDispatcher).removeEventListener(CustomSystemManagerEvent.FRAME_SUSPENDED, onSuspend);
			_manager = e.manager;
			
			var paramObj:Object = LoaderInfo(this.root.loaderInfo).parameters;
			var requestVars:URLVariables = new URLVariables();

			requestVars.data = String(paramObj['data']);
			requestVars.baseURL = String(paramObj['baseURL']);
			
			// If we're running locally, supply dummy data
			if (requestVars.baseURL == 'undefined') {
				requestVars.data = '1d2755448ffeb751d9379ab13da703aa6f9efd847c0457ecbe22a981463b65931f07c1c834b9501ddedfbc2885422b83';	// userID = courseID = seatID = 0, timestamp = 42
				requestVars.data = '087cde65e1afb3e743ff05bb1cf95be16af0c3f614117ffb531ce0aa6b73d39201860cc41362c5f9ece1a5392d049d10e054300b9b075578c909a752be2ed35b'; //tmp
				requestVars.baseURL = 'http://www.apexsandbox.com';
			}
			ApexWebService.baseURL = requestVars.baseURL;
			
			var req:URLRequest = new URLRequest(ApexWebService.baseURL + "/Classroom/engine/load.php");
			req.data = requestVars;
			req.method = URLRequestMethod.POST;
			
			var loader:URLLoader = new URLLoader(req);
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
		}
		
		protected function xmlLoaded(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			var xml:XML = new XML(loader.data);
			var log:LogService = new LogService();
			
			if (xml.localName() == 'error') {
				// Dispatch a log entry
				log.dispatch(0, 0, 0, xml.text());
			} else {
				// Note the user/course/page
				ApexWebService.userID = xml.user.@id;
				ApexWebService.courseID = xml.user.@startCourse;
				ApexWebService.pageID = xml.user.@startPage;
				
				// Delete file inclusion errors, if any
				for each (var item:XML in xml.product.courses.elements()) {	// courses or pages
					if (item.localName() == 'FILE_INCLUSION_ERROR') {
						log.dispatch(ApexWebService.userID, ApexWebService.courseID, ApexWebService.pageID, "FILE_INCLUSION_ERROR: " + item.text());
						deleteXMLNode(item);
					}
				}
	
				// Mark visited and bookmarked pages
				var visitedPages:Array = xml.user.visitedPages.text().split(' ');
				var bookmarkedPages:Array = xml.user.bookmarkedPages.text().split(' ');
				for each (var page:XML in xml..page) {
					page.@visited = (visitedPages.indexOf(String(page.@id)) != -1);
					page.@bookmarked = (bookmarkedPages.indexOf(String(page.@id)) != -1);
				}
				
				// Now load up any required assets
				var assets:AssetLoader = AssetLoader.instance;
				
				for each (var icon:XML in xml.product.images.children()) {
					var hi:Number = icon.hasOwnProperty("@highlightIntensity") ? icon.@highlightIntensity : 0.3;
					assets.addIconAsset(ApexWebService.baseURL + "/Classroom/engine/" + icon.@url, icon.@id, icon.@name, hi);
				}			
				assets.addEventListener(Event.COMPLETE, assetsLoaded);
			}
			_xml = xml;
			_manager.xml = xml;
		}
		
		//TODO: Handle assets failing to load
				
		protected function assetsLoaded(e:Event):void {
			_manager.resumeNextFrame();
		}
		
		private function deleteXMLNode(node:XML): void {
			delete node.parent().children()[node.childIndex()];
		}
	}
}