package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.TranswarpSystemManager;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.Event;

	TranswarpVersion.revision = "$Rev$";	
	
	public class SuspendFrameEvent extends Event {
		public static const FRAME_SUSPENDED:String = "frameSuspended";
		
		public var manager:TranswarpSystemManager;
		
		public function SuspendFrameEvent(manager:TranswarpSystemManager, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(FRAME_SUSPENDED, bubbles, cancelable);
			
			this.manager = manager;
		}
	}
}