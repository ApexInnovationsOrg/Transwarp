package com.apexinnovations.transwarp.preloader {
	import com.apexinnovations.transwarp.TranswarpSystemManager;
	import com.apexinnovations.transwarp.assets.AssetLoader;
	import com.apexinnovations.transwarp.events.SuspendFrameEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.webservices.ApexWebService;
	import com.apexinnovations.transwarp.webservices.LogService;
	
	import flash.display.LoaderInfo;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.*;
	
	import mx.events.RSLEvent;
	import mx.preloaders.SparkDownloadProgressBar;

	TranswarpVersion.revision = "$Rev$";
	
	public class PreloaderDisplay extends SparkDownloadProgressBar {
		
		protected var _manager:TranswarpSystemManager;
		
		protected var _xml:XML;
		
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
			value.addEventListener(SuspendFrameEvent.FRAME_SUSPENDED, onSuspend);
		}
		
		public function get rslBytesLoaded():Number { return _rslBytesLoaded + _currentRSLBytesLoaded; }
		public function get rslBytesTotal():Number { return _rslBytesTotal == -1 ? _estimatedRSLTotalSize : _rslBytesTotal; }	
		
		public function get appBytesTotal():Number { return _appBytesTotal == -1 ? _estimatedAppSize : _appBytesTotal; }
		public function get appBytesLoaded():Number { return _appBytesLoaded; }
		
		public function get combinedBytesTotal():Number { return rslBytesTotal + appBytesTotal; }
		public function get combinedBytesLoaded():Number { return rslBytesLoaded + appBytesLoaded; }
		
		protected function onSuspend(e:SuspendFrameEvent):void {
			trace("on suspend");
			(e.target as IEventDispatcher).removeEventListener(SuspendFrameEvent.FRAME_SUSPENDED, onSuspend);
			_manager = e.manager;
			if(_xml)
				_manager.xml = _xml;
			if(_xml && _xml.localName() == 'error')
				_manager.resumeNextFrame(); //If there is an error loading the xml, advance regardless of other download/init status;
			advanceFrame();
		}
		
		protected function loadXML():void {
			trace("load xml");
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
			loader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoadError);
		}
		
		protected function xmlLoadError(event:IOErrorEvent):void {
			var log:LogService = new LogService();
			log.dispatch("XML load failure: " + event);
			_xml = <error>{event}</error>;
			if(_manager)
				_manager.resumeNextFrame();
		}
		
		protected function loadAssets(e:Event):void {
			trace("xml loaded");
			var loader:URLLoader = URLLoader(e.target);
			var xml:XML = new XML(loader.data);
			var log:LogService = new LogService();
			
			_xml = xml;
			if(_manager)
				_manager.xml = xml;
			
			if (xml.localName() == 'error') {
				// Dispatch a log entry
				log.dispatch(xml.text());
			} else {
				
				// Delete file inclusion errors, if any
				for each (var item:XML in xml.product.courses.elements()) {	// courses or pages
					if (item.localName() == 'FILE_INCLUSION_ERROR') {
						log.dispatch("FILE_INCLUSION_ERROR: " + item.text());
						deleteXMLNode(item);
					}
				}
	
				// A little preprocessing of the XML...
				
				// ...Mark visited, bookmarked, and updated pages
				var visitedPages:Array = (xml.user.visitedPages.text() != undefined ? xml.user.visitedPages.text().split(' ') : []);
				var bookmarkedPages:Array = (xml.user.bookmarkedPages.text() != undefined ? xml.user.bookmarkedPages.text().split(' ') : []);
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
				// ...Mark courseware timeout, color
				xml.@timeout = xml.user.@coursewareTimeout;
				xml.@color = xml.product.@color;
				
				// ...Mark restricted courses
				var restrictedCourses:Array = (xml.user.restrictedCourses.text() != undefined ? xml.user.restrictedCourses.text().split(' ') : []);
				for each (var course:XML in xml..course) {
					course.@restricted = (restrictedCourses.indexOf(String(course.@id)) != -1);
				}
				
				// Now load up any required assets
				AssetLoader.instance.addBitmapAsset(_xml.@website + "/Classroom/engine/" + _xml.product[0].@logoBig, "logoBig");
				AssetLoader.instance.addBitmapAsset(_xml.@website + "/Classroom/engine/" + _xml.product[0].@logoSmall, "logoSmall");
				
				advanceFrame();
			}
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
		
		
		private function advanceFrame():void {
			if(_rslDone && _manager && _xml)
				_manager.resumeNextFrame();
		}
		
		private function deleteXMLNode(node:XML): void {
			delete node.parent().children()[node.childIndex()];
		}	
		
	}
}