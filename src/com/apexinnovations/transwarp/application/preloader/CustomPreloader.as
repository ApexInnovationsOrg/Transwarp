package com.apexinnovations.transwarp.application.preloader {
	import com.apexinnovations.transwarp.application.CustomSystemManager;
	import com.apexinnovations.transwarp.application.assets.AssetLoader;
	import com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
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
			var loader:URLLoader = new URLLoader(new URLRequest("test.xml"));
			loader.addEventListener(Event.COMPLETE, xmlLoaded);
		}
		
		protected function xmlLoaded(e:Event):void {
			var loader:URLLoader = URLLoader(e.target);
			var xml:XML = new XML(loader.data);
			_xml = xml;
			_manager.xml = xml;
			
			var assets:AssetLoader = AssetLoader.instance;
			
			for each (var icon:XML in xml.product.icons.children()) {
				var hi:Number = icon.hasOwnProperty("@highlightIntensity") ? icon.@highlightIntensity : 0.3;
				assets.addIconAsset(icon.@url, icon.@id, icon.@name, hi);
			}			
			assets.addEventListener(Event.COMPLETE, assetsLoaded);
		}
		
		//TODO: Handle assets failing to load
				
		protected function assetsLoaded(e:Event):void {
			_manager.resumeNextFrame();
		}
	}
}