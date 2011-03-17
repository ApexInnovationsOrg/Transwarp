package com.apexinnovations.transwarp.application {
	import com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent;
	
	import flash.events.Event;
	
	import flashx.textLayout.container.TextContainerManager;
	
	import mx.core.mx_internal;
	import mx.managers.SystemManager;
	
	use namespace mx_internal;
	
	[Event(name="frameSuspended", type="com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent")]
	public class CustomSystemManager extends SystemManager {
		protected var _resumable:Boolean = false;
		
		protected var _xml:XML;
				
		public function CustomSystemManager()	{
			var c:Class = TextContainerManager;
			super();
		}
		
		override mx_internal function initialize():void {
			super.initialize();
		}
		
		override mx_internal function docFrameHandler(event:Event=null):void {
			if(_resumable)
				kickOff();
		}
		
		override mx_internal function preloader_completeHandler(event:Event):void {
			preloader.removeEventListener(Event.COMPLETE, preloader_completeHandler);
			preloader.dispatchEvent(new CustomSystemManagerEvent(this));
		}
		
		
		public function resumeNextFrame():void {
			if(currentFrame >= 2) {
				_resumable = true;
				kickOff();
			}
		}
		
		public function get xml():XML { return _xml;}
		public function set xml(value:XML):void {
			_xml = value;
		}
		
		protected function assetsLoaded(e:Event):void {
			resumeNextFrame();		
		}
	}
}