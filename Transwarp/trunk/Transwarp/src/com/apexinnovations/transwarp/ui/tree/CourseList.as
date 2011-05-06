package com.apexinnovations.transwarp.ui.tree {
	import com.apexinnovations.transwarp.data.Course;
	import com.apexinnovations.transwarp.data.Folder;
	import com.apexinnovations.transwarp.events.TranswarpEvent;
	
	import mx.collections.ArrayList;
	
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
		
		public function toggleFolder(folder:Folder):void {
			folder.open = !folder.open;
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
			
			dispatchEvent(new TranswarpEvent(TranswarpEvent.FOLDER_OPEN_CLOSE));
		}
		
		public function reset():void {
			source = _course.viewableContents;
		}

	}
}