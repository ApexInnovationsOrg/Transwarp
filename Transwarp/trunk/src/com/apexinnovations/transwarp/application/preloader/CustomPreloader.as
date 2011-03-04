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
	import flash.system.Security;
	
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
				requestVars.data = '8998d80e3ea4b7688fb3e724c80a9f8f595fdefe848dda2407dbe3c2a1f7a039e41a2f6dc36ac5ee02c3b1494a236afdcfd51e186a766ab5fa9c202deea38f40'; // userID = 56, courseID = 1, seatID = 1234, timestamp = 42
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
				log.dispatch(xml.text());
				_manager.resumeNextFrame();
			} else {
				// Note the user/course/page
				ApexWebService.userID = xml.user.@id;
				ApexWebService.courseID = xml.user.@startCourse;
				ApexWebService.pageID = xml.user.@startPage;
				
				// Delete file inclusion errors, if any
				for each (var item:XML in xml.product.courses.elements()) {	// courses or pages
					if (item.localName() == 'FILE_INCLUSION_ERROR') {
						log.dispatch("FILE_INCLUSION_ERROR: " + item.text());
						deleteXMLNode(item);
					}
				}
	
				// Mark visited, bookmarked, and updated pages
				var visitedPages:Array = xml.user.visitedPages.text().split(' ');
				var bookmarkedPages:Array = xml.user.bookmarkedPages.text().split(' ');
				for each (var page:XML in xml..page) {
					page.@visited = (visitedPages.indexOf(String(page.@id)) != -1);
					page.@bookmarked = (bookmarkedPages.indexOf(String(page.@id)) != -1);
					
					var updated:Boolean = false;
					if (page.updates.hasComplexContent()) {
						for each (var update:XML in page..update) {
							if (String(update.@time) >= String(xml.user.@lastAccess)) {
								updated = true;
								break;
							}
						}
					}
					page.@updated = updated;
				}
				
				// Now load up any required assets
				var assets:AssetLoader = AssetLoader.instance;
			
				for each (var icon:XML in xml.product.images.children()) {
					var hi:Number = icon.hasOwnProperty("@highlightIntensity") ? icon.@highlightIntensity : 0.3;
					assets.addIconAsset(icon.@url, icon.@id, icon.@name, hi);
				}			
				assets.addEventListener(Event.COMPLETE, assetsLoaded);
			}
			_xml = xml;
			_manager.xml = xml;
		}
		
		protected function assetsLoaded(e:Event):void {
			_manager.resumeNextFrame();
		}
		
		private function deleteXMLNode(node:XML): void {
			delete node.parent().children()[node.childIndex()];
		}
	}
}