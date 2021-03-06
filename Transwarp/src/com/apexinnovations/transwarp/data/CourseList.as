package com.apexinnovations.transwarp.data {
	import com.apexinnovations.transwarp.events.FolderOpenEvent;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import mx.collections.ArrayList;
	import mx.events.PropertyChangeEvent;
	
	TranswarpVersion.revision = "$Rev$";
	
	public class CourseList extends ArrayList {
		
		protected var _course:Course;
		
		public function CourseList(source:Course = null) {
			super();
			course = source;
		}

		public function get course():Course { return _course; }
		public function set course(value:Course):void {
			_course = value;
			if(_course)
				reset();
			else
				source = null;
		}
		
		public function reset():void {
			source = _course.viewableContents;
		}
				
		override protected function itemUpdateHandler(event:PropertyChangeEvent):void {
			super.itemUpdateHandler(event);
			
			var folder:Folder = event.source as Folder;
			if(folder && event.property == "open") {
				var index:int = getItemIndex(folder);
				var contents:Array = folder.viewableContents;
				var open:Boolean = folder.open;
							
				for each(var child:* in contents) {
					if(open) {
						addItemAt(child, ++index);
					} else {
						removeItemAt(index+1);
					}
				}
				
				//FolderOpenEvent used only for the "auto close folders" option.
				if(event.newValue == true)
					dispatchEvent(new FolderOpenEvent(folder));
				
				dispatchEvent(new TranswarpEvent(TranswarpEvent.FOLDER_OPEN_CLOSE));
			}
		}

	}
}