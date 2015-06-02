package com.apexinnovations.transwarp.assets.loaders {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	import com.greensock.events.LoaderEvent;
	import com.greensock.loading.BinaryDataLoader;
	import com.greensock.loading.LoaderStatus;
	
	import flash.display.Loader;
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	[Event(name="contentReady", type="com.apexinnovations.transwarp.events.TranswarpEvent")]
	public class BinarySWFLoader extends BinaryDataLoader implements ISharedLoader {
		
		include "ISharedLoaderImpl.as"
		
		protected var _swf:Loader;
		protected var _contentReady:Boolean = false;
		protected var _contentRequested:Boolean = false;
		
		public function BinarySWFLoader(urlOrRequest:*, vars:Object=null) {
			super(urlOrRequest, vars);
			addEventListener(LoaderEvent.COMPLETE, dataLoaded);
		}
		
		public function get contentReady():Boolean {
			return _contentReady;
		}
		
		override public function get content():* {
			if(_contentReady)
				return _swf;
			else
				return null;
		}
		
		public function requestContent():void {
			_contentRequested = true;
			if(status == LoaderStatus.COMPLETED && !_swf) {
				_swf = new Loader();
				_swf.contentLoaderInfo.addEventListener(Event.COMPLETE, swfLoaded);
				_swf.loadBytes(_content);
				_content = null;
			}
		}
		
		protected function dataLoaded(event:Event):void {
			if(_contentRequested)
				requestContent();
		}
		
		protected function swfLoaded(event:Event):void {
			_contentReady = true;
			dispatchEvent(new Event("contentReady"));
		}
		
		override public function unload():void {
			if(referenceCount == 0 || pendingFlush)
				super.unload();
		}
		
		override protected function _dump(scrubLevel:int=0, newStatus:int=0, suppressEvents:Boolean=false):void {
			if(_swf) {
				//_swf.close();
				_swf.unloadAndStop();
			}
			_swf = null;
			_contentReady = false;
			_contentRequested = false;
			super._dump(scrubLevel, newStatus, suppressEvents);
		}
		
	}
}