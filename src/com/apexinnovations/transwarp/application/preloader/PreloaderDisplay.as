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
	import flash.events.ProgressEvent;
	import flash.net.*;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;

	public class PreloaderDisplay extends SparkDownloadProgressBar {
		
		protected var _manager:CustomSystemManager;
		
		protected var _xml:XML;
		protected var _assetsDone:Boolean = false;

		protected var _rslDone:Boolean = false;
		protected var _rslsLoaded:int = 0;
		protected var _estimatedRSLSize:Number = 343000;
		protected var _estimatedRSLTotalSize:Number = _estimatedRSLSize * 4;
		protected var _currentRSLIndex:Number = -1;
		protected var _rslBytesTotal:Number = -1;
		protected var _rslBytesLoaded:Number = 0;
		protected var _currentRSLBytesLoaded:Number = 0;
		
		protected var _estimatedAppSize:Number = 700000;
		protected var _appBytesTotal:Number = -1;
		protected var _appBytesLoaded:Number = 0;
		
		public function PreloaderDisplay() {
			super();
		}
		
		// Embed the background image.     
		[Embed(source="/../assets/apex-logo.png")] public var ApexLogo:Class;
					
		override public function set preloader(value:Sprite):void {
			super.preloader = value;
			value.addEventListener(CustomSystemManagerEvent.FRAME_SUSPENDED, onSuspend);
		}
		
		public function get rslBytesLoaded():Number { return _rslBytesLoaded + _currentRSLBytesLoaded; }
		public function get rslBytesTotal():Number { return _rslBytesTotal == -1 ? _estimatedRSLTotalSize : _rslBytesTotal; }	
		
		public function get appBytesTotal():Number { return _appBytesTotal == -1 ? _estimatedAppSize : _appBytesTotal; }
		public function get appBytesLoaded():Number { return _appBytesLoaded; }
		
		public function get combinedBytesTotal():Number { return rslBytesTotal + appBytesTotal; }
		public function get combinedBytesLoaded():Number { return rslBytesLoaded + appBytesLoaded; }
		
		protected function onSuspend(e:CustomSystemManagerEvent):void {
			trace("on suspend");
			(e.target as IEventDispatcher).removeEventListener(CustomSystemManagerEvent.FRAME_SUSPENDED, onSuspend);
			_manager = e.manager;
			if(_xml)
				_manager.xml = _xml;
			advanceFrame();
		}
		
		protected function loadXML():void {
			trace("xml loaded");
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
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
			loader.addEventListener(Event.COMPLETE, loadAssets);
		}
		
		protected function loadAssets(e:Event):void {
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
					assets.addBitmapAsset(icon.@url, icon.@id, icon.@name, hi);
				}			
				assets.addEventListener(Event.COMPLETE, assetsLoaded);
			}
			_xml = xml;
			if(_manager)
				_manager.xml = xml;
		}
		
		override public function initialize():void {
			super.initialize();
			backgroundImage = ApexLogo;
			loadXML();
			visible = true;
		}
		
		override protected function progressHandler(event:ProgressEvent):void {
			_appBytesTotal = event.bytesTotal;
			_appBytesLoaded = event.bytesLoaded;
			updateProgress();
		}
		
		protected function updateProgress():void {
			var progress:Number = combinedBytesLoaded / combinedBytesTotal; 
			setDownloadProgress(combinedBytesLoaded, combinedBytesTotal);
		}
				
		override protected function rslProgressHandler(event:RSLEvent):void {
			if(event.rslIndex > _currentRSLIndex) {
				if(_rslBytesTotal == -1)
					_rslBytesTotal = event.rslTotal * _estimatedRSLSize;
				
				_rslBytesTotal += event.bytesTotal - _estimatedRSLSize; // Recalculate total rsl size with new information
				_currentRSLIndex++;
			}
			_currentRSLBytesLoaded = event.bytesLoaded;
			updateProgress();
			//trace("rslProgress: " + rslBytesLoaded / rslBytesTotal);
		}
		
		override protected function rslCompleteHandler(event:RSLEvent):void {
			_rslBytesLoaded += event.bytesLoaded;
			_currentRSLBytesLoaded = 0;
			if(event.rslIndex == event.rslTotal - 1) {
				trace("rsls done");
				_rslDone = true;
				advanceFrame();
			}				
		}
		
		protected function assetsLoaded(e:Event):void {
			trace("assets loaded");
			_assetsDone = true;
			advanceFrame();
		}
		
		private function advanceFrame():void {
			if(_assetsDone && _rslDone && _manager)
				_manager.resumeNextFrame();
		}
		
		private function deleteXMLNode(node:XML): void {
			delete node.parent().children()[node.childIndex()];
		}
		
	}
}