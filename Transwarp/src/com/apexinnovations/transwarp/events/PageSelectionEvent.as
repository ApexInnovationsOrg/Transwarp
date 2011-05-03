package com.apexinnovations.transwarp.application.events
{
	import flash.events.Event;
	import com.apexinnovations.transwarp.data.Page;
	
	public class PageSelectionEvent extends Event {
		
		public static const PAGE_SELECTION_CHANGED:String = "pageSelectionChanged";
		
		public var page:Page;
		
		public function PageSelectionEvent(page:Page, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.page = page;
			super(PAGE_SELECTION_CHANGED, bubbles, cancelable);
		}
	}
}