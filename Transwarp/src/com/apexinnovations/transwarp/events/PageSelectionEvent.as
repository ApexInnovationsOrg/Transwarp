package com.apexinnovations.transwarp.events
{
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class PageSelectionEvent extends Event {
		
		public static const PAGE_SELECTION_CHANGED:String = "pageSelectionChanged";
		
		public var page:Page;
		
		public function PageSelectionEvent(page:Page, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.page = page;
			super(PAGE_SELECTION_CHANGED, bubbles, cancelable);
		}
	}
}