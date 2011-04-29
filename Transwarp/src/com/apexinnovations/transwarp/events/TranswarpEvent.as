package com.apexinnovations.transwarp.events {
	import flash.events.Event;
	
	public class TranswarpEvent extends Event {
		
		public static const TOGGLE_MAXIMIZE:String = "toggleMaximize";
		
		public function TranswarpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}