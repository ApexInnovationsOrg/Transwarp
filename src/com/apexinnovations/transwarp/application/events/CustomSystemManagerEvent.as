package com.apexinnovations.transwarp.application.events {
	import com.apexinnovations.transwarp.application.CustomSystemManager;
	
	import flash.events.Event;

	public class CustomSystemManagerEvent extends Event {
		
		public static const FRAME_SUSPENDED:String = "frameSuspended";
		
		public var manager:CustomSystemManager 
		
		public function CustomSystemManagerEvent(manager:CustomSystemManager) {
			super(FRAME_SUSPENDED);
			this.manager = manager;
		}
	}
}