package com.apexinnovations.transwarp.preloader {
	import com.apexinnovations.transwarp.TranswarpSystemManager;
	import com.apexinnovations.transwarp.assets.AssetLoader;
	import com.apexinnovations.transwarp.events.SuspendFrameEvent;
	import com.apexinnovations.transwarp.ui.tooltip.TranswarpTooltipManager;
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
		
		protected var _rslDone:Boolean = CONFIG::OFFLINE;
		protected var _rslsLoaded:int = 0;
		protected var _estimatedRSLSize:Number = 343000;
		protected var _estimatedRSLTotalSize:Number = _estimatedRSLSize * 4;
		protected var _currentRSLIndex:Number = -1;
		protected var _rslBytesTotal:Number = -1;
		protected var _rslBytesLoaded:Number = 0;
		protected var _currentRSLBytesLoaded:Number = 0;
		
		protected var _estimatedAppSize:Number = 70000;
		protected var _appBytesTotal:Number = -1;
		protected var _appBytesLoaded:Number = 0;
		protected  var comeFrom:String;
		public function PreloaderDisplay() {
			super();
		}
		
		// Embed the background image.     
		[Embed(source="/../assets/H2_LoadingScreenImage.jpg")] public var ApexLogo:Class;
					
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
			(e.target as IEventDispatcher).removeEventListener(SuspendFrameEvent.FRAME_SUSPENDED, onSuspend);
			_manager = e.manager;
			if(_xml)
				_manager.xml = _xml;
			if(_xml && _xml.localName() == 'error')
				_manager.resumeNextFrame(); //If there is an error loading the xml, advance regardless of other download/init status;
			advanceFrame();
		}
		
		protected function loadXML():void {
			var paramObj:Object = LoaderInfo(root.loaderInfo).parameters;
			var requestVars:URLVariables = new URLVariables();
			
			requestVars.data = String(paramObj['data']);
			requestVars.baseURL = String(paramObj['baseURL']);
			
			// If we're running locally, supply dummy data
			
			if(CONFIG::DEBUG) {
				if (requestVars.baseURL == 'undefined') {
//					requestVars.data = "e312c92591e7067db6857b02130f7d8b3ce8016b9b28cc8de90efbcc81356dfb0619e755974be99c80a9d5f458deaa16720256f25b2f946b6b0a4befb9791c10"; // Canadian Hemi
					//requestVars.data = '69f26ef8147d984e52a9cf6cdb3975925a46c2bc49117cefd23a41995483e2d5ccc0ef7d3e4e3730b973b6f8cf2c444b39c7f36e352041ede5ba3ee09691e43e'; // Hemi Patient
					//requestVars.data = '8998d80e3ea4b7688fb3e724c80a9f8ff9016eca432b0943a4c5f23da88342c9060f4aa4957ecc421a3d09a797c5766a27d642cccbe47f34013ba1e2040a7a2a'; // Hemispheres
			requestVars.data = '1595c3f3bd6be4327ecc5b42cbe44289fa053dab4604f6899d4f72c89aea46b40695a06e0334ac7853de97bc050978947cb1649550e07bdee4889734a1af3676fb6a16f9a8380d6a6f3ddb957882ab35'; // Hemispheres 2.0
					//requestVars.data = '8998d80e3ea4b7688fb3e724c80a9f8f595fdefe848dda2407dbe3c2a1f7a039e41a2f6dc36ac5ee02c3b1494a236afdcfd51e186a766ab5fa9c202deea38f40'; // imPULSE
					//requestVars.data = '69f26ef8147d984e52a9cf6cdb397592daa7a3f56a4c26b5a915c68b9c0c64ade2488a93188d9024989fc1d535d852c2875016a31690bcdf90ff9fe57b4fbe47'; // Responder
//					requestVars.data = 'cb13cd07dbff7a145999e2fe7167fa1aee0b4b0b2d3bf33babd925ad2850c5fa307e20684a47b5e11d813c1fce21fa54db804249f0bd44c2976de896f36251de'; // Transitions
					requestVars.baseURL = 'http://www.apexwebtest.com';
				}
			} 
			
//			trace(requestVars);
			if(CONFIG::OFFLINE) {
				requestVars.baseURL = '/';
				comeFrom = comeFrom + ".xml";
				var req:URLRequest = new URLRequest(comeFrom);				
			} else {
				var req:URLRequest = new URLRequest(requestVars.baseURL + "/Classroom/engine/load.php");
				req.data = requestVars;
				req.method = URLRequestMethod.POST;
			}
			
			
			ApexWebService.baseURL = requestVars.baseURL;
			
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
			var loader:URLLoader = URLLoader(e.target);
			XML.ignoreWhitespace = false;
			var xml:XML = new XML(loader.data);
			var log:LogService = new LogService();
//			trace(xml);
			
			_xml = xml;
			if(_manager)
				_manager.xml = xml;
			
			if (xml.localName() == 'error') {
				// This should only really ever happen if someone tries to pull up courseware after session expired - let's just ignore
				// log.dispatch(xml.text());
			} else {
				
				// Delete file inclusion errors, if any
				for each (var item:XML in xml..FILE_INCLUSION_ERROR) {
					log.dispatch("FILE_INCLUSION_ERROR: " + item.text());
					deleteXMLNode(item);
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
				
				for each(var folder:XML in xml..folder) {
					folder.@bookmarked = bookmarkedPages.indexOf(String(folder.@id)) != -1;
				}
				
				// ...Mark courseware timeout, color
				xml.@timeout = xml.user.@coursewareTimeout;
				xml.@buttonBGColor = xml.product.@buttonBGColor;
				xml.@buttonFGColor = xml.product.@buttonFGColor;
				xml.@color = xml.product.@color;
				xml.@highlightColor = xml.product.@highlightColor;
				xml.@volume = uint(xml.user.@audioVolume);
				
				// ...Mark restricted courses
				var restrictedCourses:Array = (xml.user.restrictedCourses.text() != undefined ? xml.user.restrictedCourses.text().split(' ') : []);
				for each (var course:XML in xml..course) {
					course.@restricted = (restrictedCourses.indexOf(String(course.@id)) != -1);
				}
				
				// Now load up any required assets
				if(CONFIG::OFFLINE) {
					AssetLoader.instance.addBitmapAsset(_xml.product[0].@logoBig, "logoBig");
					AssetLoader.instance.addBitmapAsset(_xml.product[0].@logoSmall, "logoSmall");
				} else {
					AssetLoader.instance.addBitmapAsset(_xml.@website + "/Classroom/engine/" + _xml.product[0].@logoBig, "logoBig");
					AssetLoader.instance.addBitmapAsset(_xml.@website + "/Classroom/engine/" + _xml.product[0].@logoSmall, "logoSmall");	
				}
								
				advanceFrame();
			}
		}
		
		override public function initialize():void {
			super.initialize();
			backgroundImage = ApexLogo;
			comeFrom = root.loaderInfo.url.slice(root.loaderInfo.url.lastIndexOf("/")+1,root.loaderInfo.url.lastIndexOf(".")); //Used to determine the name of file which is running transwarp for offline xmls
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
		}
		
		override protected function rslCompleteHandler(event:RSLEvent):void {
			_rslBytesLoaded += event.bytesLoaded;
			_currentRSLBytesLoaded = 0;
			if(event.rslIndex == event.rslTotal - 1) {
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