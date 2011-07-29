package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.utils.Utils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.DataLoader;
	import com.greensock.loading.LoaderMax;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.MP3Loader;
	import com.greensock.loading.XMLLoader;
	import com.greensock.loading.core.LoaderItem;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class PageLoader extends LoaderMax {
		protected static var swfMap:Dictionary = new Dictionary();
		
		protected var _page:Page;
				
		protected var audio:MP3Loader;
		protected var config:LoaderItem;

		protected var initializeRequested:Boolean;
		protected var loadingComplete:Boolean;
		
		protected var configLoader:Loader;
		protected var configInitialized:Boolean;
		
		protected var shadowedLoader:PageLoader; // If this loader wants to load a page that is already being handled by another loader, 'shadow' that one instead.
		
		// When shadowing another PageLoader, these variables are not used.  
		// The getters below pull the data from the shadowedLoader instead.
		protected var _swfData:BinaryDataLoader;
		protected var _binarySWFData:ByteArray;
		protected var _contentLoader:Loader;
		protected var _contentInitialized:Boolean;
		
		// Getters and setters used for shadowing another loader;
		protected function set swfData(value:BinaryDataLoader):void { _swfData = value; }
		protected function get swfData():BinaryDataLoader {
			return shadowedLoader ? shadowedLoader._swfData : _swfData;
		}
		
		protected function set contentLoader(value:Loader):void { _contentLoader = value; }
		protected function get contentLoader():Loader {
			return shadowedLoader ? shadowedLoader._contentLoader : _contentLoader;
		}
		
		protected function set contentInitialized(value:Boolean):void { _contentInitialized = value; }
		protected function get contentInitialized():Boolean {
			return shadowedLoader ? shadowedLoader._contentInitialized : _contentInitialized;
		}
		
		protected function set binarySWFData(value:ByteArray):void { _binarySWFData = value; }
		protected function get binarySWFData():ByteArray {
			return shadowedLoader ? shadowedLoader._binarySWFData : _binarySWFData;
		}
		
		public function PageLoader(page:Page) {
			super();

			init();
			
			name = String(page.id);			
			
			_page = page;
			
			var baseURL:String = Courseware.instance.rootFolder + '/';
			var dateHash:String = makeDateHash(page);
						
			var swfURL:String = baseURL + page.swf;
			
			if(swfMap.hasOwnProperty(swfURL)) {
				shadowedLoader = swfMap[swfURL];
				shadowedLoader.addEventListener(TranswarpEvent.CONTENT_READY, shadowedLoaderContentReady);
				shadowedLoader.addEventListener(TranswarpEvent.CONTENT_UNLOAD, shadowedLoaderContentUnload);
			} else {
				swfData = new BinaryDataLoader(swfURL + dateHash, {allowMalformedURL:true});
				swfMap[swfURL] = this;
			}
			swfData.addEventListener(LoaderEvent.COMPLETE, swfLoadComplete);
			append(swfData);
			
			if(page.audio && page.audio != '') {
				audio = new MP3Loader(baseURL + page.audio + dateHash, {allowMalformedURL: true, autoPlay: false});
				append(audio);
			}
			
			var configLoaderClass:Class;
			
			if(page.configType == "text")
				configLoaderClass = DataLoader;
			else if(page.configType == "xml")
				configLoaderClass = XMLLoader;
			else if(page.configType == "swf")
				configLoaderClass = BinaryDataLoader;
			
			if(configLoaderClass) {
				config = new configLoaderClass(baseURL + page.config + dateHash, {allowMalformedURL: true});
				append(config);
			}			
			
			addEventListener(LoaderEvent.COMPLETE, pageLoaded);
		}
		
		/*override public function get status():int {
			_status = LoaderStatus.COMPLETED; //HACK HACK HACK
			return super.status;
		}*/
		
		protected function shadowedLoaderContentUnload(event:Event):void {
			prepend(swfData);
		}
		
		protected function swfLoadComplete(event:LoaderEvent):void {
			if(!shadowedLoader) {
				binarySWFData = swfData.content;
				swfData.unload();
			}
			remove(swfData);
		}
		
		protected function init():void {
			loadingComplete = false;
			initializeRequested = false;
			_binarySWFData = null;
			contentLoader = null;
			contentInitialized = false;
		}
		
		public function unloadContent():void {
			init();
			if(shadowedLoader) {
				shadowedLoader.unloadContent();
			} else
				dispatchEvent(new Event(TranswarpEvent.CONTENT_UNLOAD));
			prepend(swfData);
		}
		
		public function reload():void {
			unloadContent();			
			if(shadowedLoader)
				shadowedLoader.load();
			else
				load();
		}	
		
		public function get contentReady():Boolean { 
			if(page.configType == "swf")
				return configInitialized && contentInitialized;
			else 
				return contentInitialized;
		}
		
		public function get page():Page { return _page; }
		
		public function get swf():DisplayObject { 
			if(contentReady) {
				applyConfig();
				return contentLoader;
			} else
				return null;
		}
		
		public function requestContent():void {
			trace("request content");
			if(contentReady) { 
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
				return;
			} else if(status == LoaderStatus.COMPLETED && (shadowedLoader ||binarySWFData !== null))
				initializeContent();
			else
				initializeRequested = true;
		}
		
		public function playAudio():void {
			if(audio && audio.status == LoaderStatus.COMPLETED)
				audio.gotoSoundTime(0, true);
		}
		
		
		protected function pageLoaded(event:LoaderEvent):void {
			loadingComplete = true;
			if(initializeRequested)
				initializeContent();			
		}		
		
		protected function initializeContent():void {			
			if(contentReady)
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
			else if(shadowedLoader) {
				shadowedLoader.requestContent();
				//_initializeRequested = _initializeRequested || shadowedLoader._initializeRequested;
			} else {
				contentLoader = new Loader();
				contentLoader.loadBytes(binarySWFData);
				binarySWFData = null;
				contentLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, contentInit);
			}
				
			if(_page.configType == "swf" && !configLoader) {
				configLoader = new Loader();
				configLoader.loadBytes(config.content);
				config.unload();
				configLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, configInit);
			}
		}
		
		protected function shadowedLoaderContentReady(event:Event):void {
			if(contentReady)
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
		}
		
		protected function contentInit(event:Event):void {
			contentInitialized = true;
			LoaderInfo(event.target).uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
			if(contentReady)
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
		}
		
		protected function configInit(event:Event):void {
			configInitialized = true;
			LoaderInfo(event.target).uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, uncaughtError);
			if(contentReady)
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
		}
		
		
		protected function applyConfig():void {
			if(!contentInitialized)
				return;
			
			var configType:String = _page.configType;
			
			if(configType == "swf" && configInitialized)
				Object(contentLoader.content).config = configLoader.content;
			else if((configType == "text" || configType == "xml") && config.status == LoaderStatus.COMPLETED)
				Object(contentLoader.content).config = config.content;
			else if(configType == "string")
				Object(contentLoader.content).config = page.config;
			
		}
		
		protected function uncaughtError(event:UncaughtErrorEvent):void {
			event.stopPropagation();
			event.preventDefault();
			trace("caught error in slide or slide config");
			//TODO: Log this?
		}
		
		protected function makeDateHash(page:Page):String {
			if(page.updates.length > 0)
				return '?' + Utils.jenkinsHash(page.updates[0].time.toUTCString()).toString();
			else
				return '';
		}
		
		
	}
}