package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.data.HelpPage;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.display.Loader;
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="contentReady", type="com.apexinnovations.transwarp.events.TranswarpEvent")]
	public class HelpLoader extends SharedGroupLoader {
		
		protected var _help:HelpPage;
		
		protected var swfLoader:BinarySWFLoader;
		protected var audioLoader:SharedMP3Loader;
		
		protected var contentRequested:Boolean = false;
		
		public function HelpLoader(help:HelpPage) {
			_help = help;
			
			swfLoader = loaderFactory.getLoader(help.url, "repository/" + help.url, BinarySWFLoader);
			swfLoader.addEventListener(TranswarpEvent.CONTENT_READY, childContentReady);
			
			append(swfLoader);
			
			//TODO: load audio
		}
		
		public function get help():HelpPage { return _help; }
		public function get contentReady():Boolean { return swfLoader.contentReady; }
		
		public function get swf():Loader {
			if(contentReady)
				return swfLoader.content;
			else
				return null;
		}
		
		public function requestContent():void {
			if(contentReady)
				return;
			swfLoader.requestContent();
			contentRequested = true;
		}
		
		public function playAudio():void {
			//TODO
		}
		
		protected function childContentReady(event:Event):void {
			dispatchEvent(new Event(TranswarpEvent.CONTENT_READY));
		}
		
	}
}