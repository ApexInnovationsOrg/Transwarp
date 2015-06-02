package com.apexinnovations.transwarp.events {
	import flash.events.Event;
	
	public class ContentAreaSizeEvent extends Event {
		
		public static const CONTENT_AREA_SIZE_CHANGED:String = "contentAreaSizeChanged";
		
		public var hOverflow:Number;
		public var vOverflow:Number;
		
		public function ContentAreaSizeEvent(hOverflow:Number, vOverflow:Number, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(CONTENT_AREA_SIZE_CHANGED, bubbles, cancelable);
			
			this.hOverflow = hOverflow;
			this.vOverflow = vOverflow;
		}
	}
}