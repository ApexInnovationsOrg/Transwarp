package com.apexinnovations.transwarp.data {
	import flash.utils.getQualifiedClassName;
	
	import mx.formatters.DateFormatter;

	public class Product extends CoursewareObjectContainer {
		
		protected var _courses:Vector.<Course> = new Vector.<Course>();		// Vector (array) of courses for this product
		protected var _helpPages:Vector.<HelpPage> = new Vector.<HelpPage>();	// Vector (array) of help pages for this product
		protected var _logoBig:String = '';									// URL to a large representation of this product's logo
		protected var _logoSmall:String = '';									// URL to a small representation of this product's logo
		protected var _released:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		protected var _flatList:Vector.<CoursewareObject>;
		
		public function Product(xml:XML, courseware:Courseware) {
			_parentCourseware = courseware;
			_flatList = new Vector.<CoursewareObject>();
			
			super(xml, null, 0, xml.courses.children());
			
			try {
				_logoBig = xml.@logoBig;
				_logoSmall = xml.@logoSmall;
				_released = DateFormatter.parseDateString(xml.@released);
				
				for each (var h:XML in xml.helpPages.helpPage) {
					_helpPages.push(new HelpPage(h, this));
				}
				
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
		}
		
		public function getCourseByID(courseID:uint):Course {
			for each(var c:Course in _courses)
				if(c.id == courseID)
					return c;
			return null;
		}
		
		public function get courses():Vector.<Course> { return _courses; }
		public function get helpPages():Vector.<HelpPage> { return _helpPages; }
		public function get logoBig():String { return _logoBig; }
		public function get logoSmall():String { return _logoSmall; }
		public function get released():Date { return _released; }
		public function get flatList():Vector.<CoursewareObject> { return _flatList; }
		
		override protected function createChild(node:XML):CoursewareObject {
			var kind:String = node.localName();
			
			if(!kind)
				return null;
			
			kind = kind.toLowerCase();
			
			if(kind == "course") {
				var course:Course = new Course(node, this);
				_courses.push(course);
				_flatList = _flatList.concat(course.flatList);
				return course;
			}
			return null;
		}
	}
}