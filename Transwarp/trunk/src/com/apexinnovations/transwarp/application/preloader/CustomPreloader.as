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
			
			_xml = xml;
			_manager.xml = xml;
			
			if (xml.localName() == 'error') {
				// Dispatch a log entry
				log.dispatch(0, 0, 0, xml.text());
			} else {
				// Note the user/course/page
				ApexWebService.userID = xml.user.@id;
				ApexWebService.pageID = xml.user.@startPage;
				for each (var course:XML in xml.product.courses.children()) {
					for each (var page:XML in course.children()) {
						if (ApexWebService.pageID == page.@id) {
							ApexWebService.courseID = course.@id;
							break;
						}
					}
					if (ApexWebService.courseID != 0) break;
				}
				
				// Delete file inclusion errors, if any
				for each (course in xml.product.courses.children()) {
					if (course.localName() == 'FILE_INCLUSION_ERROR') {
						log.dispatch(ApexWebService.userID, ApexWebService.courseID, ApexWebService.pageID, "FILE_INCLUSION_ERROR: " + course.text());
						deleteXMLNode(course);
					} else {
						for each (page in course.children()) {
							if (page.localName() == 'FILE_INCLUSION_ERROR') {
								log.dispatch(ApexWebService.userID, ApexWebService.courseID, ApexWebService.pageID, "FILE_INCLUSION_ERROR: " + page.text());
								deleteXMLNode(page);
							}
						}
					}
				}
	
				// Now load up any required assets
				var assets:AssetLoader = AssetLoader.instance;
				
				for each (var icon:XML in xml.product.images.children()) {
					var hi:Number = icon.hasOwnProperty("@highlightIntensity") ? icon.@highlightIntensity : 0.3;
					assets.addIconAsset(ApexWebService.baseURL + "/Classroom/engine/" + icon.@url, icon.@id, icon.@name, hi);
				}			
				assets.addEventListener(Event.COMPLETE, assetsLoaded);
			}
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