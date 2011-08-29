package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.apexinnovations.transwarp.utils.Utils;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.LoaderStatus;
	import com.greensock.loading.core.LoaderCore;
	
	import flash.display.Loader;
	import flash.events.Event;

	TranswarpVersion.revision = "$Rev$";
	
	public class PageLoader extends SharedGroupLoader {
		
		protected var _page:Page;
		
		protected var swfLoader:BinarySWFLoader;
		protected var configLoader:LoaderCore;
		protected var audioLoader:SharedMP3Loader;
		
		public function PageLoader(page:Page) {
			super({name: String(page.id)});
			_page = page;
			
			var baseURL:String = Courseware.instance.rootFolder + '/'

			var dateHash:String = makeDateHash(_page);
			
			var swfURL:String = baseURL + _page.swf; 
					
			swfLoader = loaderFactory.getLoader(swfURL, swfURL + dateHash, BinarySWFLoader, {allowMalformedURL: true});
			append(swfLoader);
			
			if(page.audio && page.audio != '') {
				var audioURL:String = baseURL + page.audio;
				audioLoader = loaderFactory.getLoader(audioURL, audioURL + dateHash, SharedMP3Loader, {allowMalformedURL: true, autoPlay: false});
				append(audioLoader);
			}
			
			var configLoaderClass:Class;
			
			if(page.configType == "text")
				configLoaderClass = SharedDataLoader;
			else if(page.configType == "xml")
				configLoaderClass = SharedXMLLoader;
			else if(page.configType == "swf")
				configLoaderClass = BinarySWFLoader;
			
			if(configLoaderClass) {
				var configURL:String = baseURL + page.config;
				configLoader = loaderFactory.getLoader(configURL, configURL + dateHash, configLoaderClass, {allowMalformedURL: true});
				append(configLoader);
			}
			
			addEventListener(LoaderEvent.COMPLETE, childSWFReady);			
		}
		
		public function get page():Page { return _page; }
		
		public function get contentReady():Boolean {
			// Ensure that the main swf and potential config swfs are loaded and converted
			// The cases where the config is not a swf are covered by the status == LoaderStatus.COMPLETED check below
			var configReady:Boolean = configLoader is BinarySWFLoader? BinarySWFLoader(configLoader).contentReady : true;			
			
			return status == LoaderStatus.COMPLETED && swfLoader.contentReady && configReady;
		}		
		
		public function get swf():Loader {
			if(contentReady) {
				applyConfig();
				return swfLoader.content;
			} else
				return null;
		}
		
		public function playAudio():void {
			if(audioLoader && audioLoader.status == LoaderStatus.COMPLETED)
				audioLoader.gotoSoundTime(0, true);
		}
		
		public function requestContent():void {
			if(contentReady)
				return;
			
			if(!swfLoader.contentReady) {
				swfLoader.requestContent();
				swfLoader.addEventListener(TranswarpEvent.CONTENT_READY, childSWFReady);
			}
			
			var config:BinarySWFLoader = configLoader as BinarySWFLoader;
			if(config && !config.contentReady) {
				config.requestContent();
				config.addEventListener(TranswarpEvent.CONTENT_READY, childSWFReady);
			}
		}
		
		protected function childSWFReady(event:Event):void {
			if(contentReady)
				dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
		}
		
		protected function applyConfig():void {	
			var configType:String = _page.configType;
			
			if(configType == "swf")
				Object(swfLoader.content.content).config = configLoader.content.content;
			else if(configType == "text" || configType == "xml")
				Object(swfLoader.content.content).config = configLoader.content;
			else if(configType == "string")
				Object(swfLoader.content.content).config = _page.config;
		}
		
		
		protected function makeDateHash(page:Page):String {
			if(page.updates.length > 0)
				return '?' + Utils.jenkinsHash(page.updates[0].time.toUTCString()).toString();
			else
				return '';
		}
	
	}
}