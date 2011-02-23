package com.apexinnovations.transwarp.application.preloader {
	import com.apexinnovations.transwarp.webservices.ApexWebService;
	import com.apexinnovations.transwarp.application.CustomSystemManager;
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent;
	
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
				requestVars.data = '1d2755448ffeb751d9379ab13da703aa6f9efd847c0457ecbe22a981463b65931f07c1c834b9501ddedfbc2885422b83';
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
			
			_xml = xml;
			_manager.xml = xml;
			
			ApexWebService.userID = xml.user.@id;
			ApexWebService.pageID = xml.user.@startPage;
			ApexWebService.courseID = xml.product.courses.course[0].@id;
			for each (var course:XML in xml.product.courses.children()) {
				for each (var page:XML in course.children()) {
					if (ApexWebService.pageID == page.@id) {
						ApexWebService.courseID = course.@id;
						break;
					}
				}
				if (ApexWebService.courseID != 0) break;
			}			
			
			var assets:AssetLoader = AssetLoader.instance;
			
			for each (var icon:XML in xml.product.images.children()) {
				var hi:Number = icon.hasOwnProperty("@highlightIntensity") ? icon.@highlightIntensity : 0.3;
				assets.addIconAsset(ApexWebService.baseURL + "/Classroom/engine/" + icon.@url, icon.@id, icon.@name, hi);
			}			
			assets.addEventListener(Event.COMPLETE, assetsLoaded);
		}
		
		//TODO: Handle assets failing to load
				
		protected function assetsLoaded(e:Event):void {
			_manager.resumeNextFrame();
		}
	}
}