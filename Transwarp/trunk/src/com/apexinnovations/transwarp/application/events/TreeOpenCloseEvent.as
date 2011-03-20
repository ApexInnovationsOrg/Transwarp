package com.apexinnovations.transwarp.application.events {
	import flash.events.Event;
	
	public class TreeOpenCloseEvent extends Event {
		
		public static const OPEN_CLOSE:String = "treeOpenClose";
		
		public function TreeOpenCloseEvent(bubbles:Boolean=false, cancelable:Boolean=false) {
			super(OPEN_CLOSE, bubbles, cancelable);
		}
	}
}