package com.apexinnovations.transwarp.events {
	import flash.events.Event;
	
	public class TranswarpEvent extends Event {
		
		public static const FOLDER_OPEN_CLOSE:String = "folderOpenClose";
		public static const NEXT_PAGE:String = "nextPage";
		public static const PREV_PAGE:String = "prevPage";
		
		
		public function TranswarpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}