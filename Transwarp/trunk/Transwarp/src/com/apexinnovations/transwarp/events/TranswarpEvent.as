package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.Event;
	
	TranswarpVersion.revision = "$Rev$";
	
	
	public class TranswarpEvent extends Event {
		
		public static const FOLDER_OPEN_CLOSE:String = "folderOpenClose";
		public static const CONTENT_READY:String = "contentReady";
		public static const CONTENT_UNLOAD:String = "contentUnload";
		
		public function TranswarpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}