package com.apexinnovations.transwarp.application.events {
	import flash.events.Event;
	
	public class PageSelectionEvent extends Event {
		
		public static const PAGE_SELECTION_CHANGED:String = "pageSelectionChanged";
		
		public var id:uint;
		
		public function PageSelectionEvent(id:uint, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.id = id;
			super(PAGE_SELECTION_CHANGED, bubbles, cancelable);
		}
	}
}