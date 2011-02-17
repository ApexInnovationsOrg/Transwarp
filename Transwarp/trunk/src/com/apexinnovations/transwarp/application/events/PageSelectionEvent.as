package com.apexinnovations.transwarp.application.events {
	import flash.events.Event;
	
	public class PageSelectionEvent extends Event {
		
		public static const PAGE_SELECTION_CHANGED:String = "pageSelectionChanged";
		
		public var id:String;
		
		public function PageSelectionEvent(id:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.id = id;			
			super(PAGE_SELECTION_CHANGED, bubbles, cancelable);
		}
	}
}