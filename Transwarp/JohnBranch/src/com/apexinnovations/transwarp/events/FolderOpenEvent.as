package com.apexinnovations.transwarp.events {
	import com.apexinnovations.transwarp.data.Folder;
	
	import flash.events.Event;
	
	public class FolderOpenEvent extends Event {
		public static const FOLDER_OPEN:String = "folderOpen";
		public var folder:Folder;
		
		public function FolderOpenEvent(folder:Folder, bubbles:Boolean=false, cancelable:Boolean=false) {
			super(FOLDER_OPEN, bubbles, cancelable);
			this.folder = folder;
		}
	}
}