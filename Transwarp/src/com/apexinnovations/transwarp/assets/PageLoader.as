package com.apexinnovations.transwarp.assets {
	import com.apexinnovations.transwarp.TranswarpSlide;
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.ContentReadyEvent;
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
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class PageLoader extends LoaderMax {
		protected var _page:Page;
		
		protected var _swf:DisplayObject;
		
		protected var swfData:BinaryDataLoader;
		protected var audio:MP3Loader;
		protected var config:LoaderItem;
		
		protected var _contentReady:Boolean = false;
		protected var _initializeRequested:Boolean = false;
		
		protected var contentLoader:Loader;
		protected var contentInitialized:Boolean = false;
		
		protected var configLoader:Loader;
		protected var configInitialized:Boolean = false;
		
		public function PageLoader(page:Page) {
			super();
			
			name = String(page.id);			
			
			_page = page;
			
			var baseURL:String = Courseware.instance.rootFolder + '/';
			var dateHash:String = makeDateHash(page);
						
			swfData = new BinaryDataLoader(baseURL + page.swf + dateHash, {allowMalformedURL:true});
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
				
		public function get contentReady():Boolean { return _contentReady; }
		public function get page():Page { return _page; }
		public function get swf():DisplayObject { return _swf; }
		
		public function requestContent():void {
			if(status == LoaderStatus.COMPLETED && swfData.status == LoaderStatus.COMPLETED)
				initializeContent();
			else
				_initializeRequested = true;
		}
		
		public function playAudio():void {
			if(audio && audio.status == LoaderStatus.COMPLETED)
				audio.gotoSoundTime(0, true);
		}
		
		
		protected function pageLoaded(event:LoaderEvent):void {
			if(_initializeRequested)
				initializeContent();			
		}		
		
		protected function initializeContent():void {
			if(contentLoader)
				return;
			contentLoader = new Loader();
			contentLoader.loadBytes(swfData.content);
			contentLoader.contentLoaderInfo.addEventListener(Event.INIT, contentInit);
			
			if(_page.configType == "swf") {
				configLoader = new Loader();
				configLoader.loadBytes(config.content);
				configLoader.contentLoaderInfo.addEventListener(Event.INIT, configInit);
			}
		}
		
		protected function contentInit(event:Event):void {
			contentInitialized = true;
			_swf = event.target.loader;
			checkReady();
		}
		
		protected function configInit(event:Event):void {
			configInitialized = true;
			checkReady();
		}
		
		protected function checkReady():void {
			if(contentInitialized && (!_page.configType != "swf" || configInitialized)) {
				
				var configType:String = _page.configType;
				
				if(configType == "swf" && configInitialized)
					Object(contentLoader.content).config = configLoader.content;
				else if((configType == "text" || configType == "xml") && config.status == LoaderStatus.COMPLETED)
					Object(contentLoader.content).config = config.content;
				else if(configType == "string")
					Object(contentLoader.content).config = page.config;
				
				_contentReady = true;
				dispatchEvent(new ContentReadyEvent(_swf, _page));
			}				
		}
		
		protected function makeDateHash(page:Page):String {
			if(page.updates.length > 0)
				return '?' + Utils.jenkinsHash(page.updates[0].time.toUTCString()).toString();
			else
				return '';
		}
		
		
	}
}