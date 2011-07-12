package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.data.Page;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class ContentReadyEvent extends Event {
		
		public static const CONTENT_READY:String = "contentReady";
		
		public var content:DisplayObject;
		public var page:Page;
		
		public function ContentReadyEvent(content:DisplayObject, page:Page, bubbles:Boolean=false, cancelable:Boolean=false) {
			this.content = content;
			this.page = page;
			super(CONTENT_READY, bubbles, cancelable);
		}
	}
}