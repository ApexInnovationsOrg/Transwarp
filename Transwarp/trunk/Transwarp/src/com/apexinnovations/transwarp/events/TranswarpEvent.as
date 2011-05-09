package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.utils.Utils;
	
	import flash.events.Event;
	
	Utils.revision = "$Rev$";
	
	
	public class TranswarpEvent extends Event {
		
		public static const FOLDER_OPEN_CLOSE:String = "folderOpenClose";
		
		public function TranswarpEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(type, bubbles, cancelable);
		}
	}
}