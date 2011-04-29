package com.apexinnovations.transwarp.events {
	public class MaximizeEvent extends TranswarpEvent {
		public static const MAXIMIZE:String = "maximize";
		
		public var maximized:Boolean;
		
		public function MaximizeEvent(maxed:Boolean, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(MAXIMIZE, bubbles, cancelable);
			
			maximized = maxed;
		}
	}
}