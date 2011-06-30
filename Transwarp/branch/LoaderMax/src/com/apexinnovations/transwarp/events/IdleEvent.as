package com.apexinnovations.transwarp.events {
	import flash.events.Event;
	
	public class IdleEvent extends Event {
		public static const IDLE:String = "idle";
		
		public var duration:Number;
		
		public function IdleEvent(duration:Number, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(IDLE, bubbles, cancelable);
			
			this.duration = duration;
		}
	}
}