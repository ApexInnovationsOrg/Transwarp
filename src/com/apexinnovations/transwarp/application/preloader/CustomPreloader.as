package com.apexinnovations.transwarp.application.preloader {
	import com.apexinnovations.transwarp.application.CustomSystemManager;
	import com.apexinnovations.transwarp.application.events.CustomSystemManagerEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.sampler.Sample;
	
	import mx.preloaders.SparkDownloadProgressBar;

	public class CustomPreloader extends SparkDownloadProgressBar {
		
		protected var _manager:CustomSystemManager;
				
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
		
			_manager.resumeNextFrame(); // Remove me when actually needing to wait for something to load
		}
	}
}