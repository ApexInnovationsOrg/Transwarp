package com.apexinnovations.transwarp.ui.tree {
	import com.apexinnovations.transwarp.data.Course;
	
	import mx.collections.ArrayList;
	
	public class CourseList extends ArrayList {
		
		protected var _course:Course;
		
		public function CourseList(source:Course) {
			super();
			course = source;
		}

		public function get course():Course { return _course; }
		public function set course(value:Course):void {
			_course = value;
			if(!_course) {
				source = null;
				return;
			}
			
			source = _course.viewableContents;	
			
		}
		
		public function refresh():void {
			source = _course.viewableContents;
		}

	}
}