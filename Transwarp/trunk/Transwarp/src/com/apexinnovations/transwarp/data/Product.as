package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Course;
	
	import flash.errors.*;
	import flash.utils.*;
	
	import mx.formatters.DateFormatter;
		
	// This represents the the product being taken
	public class Product {
		private static var _instance:Product;	// Make this class a singleton
		
		private var _courses:Vector.<Course> = new Vector.<Course>();		// Vector (array) of courses for this product
		private var _helpPages:Vector.<HelpPage> = new Vector.<HelpPage>();	// Vector (array) of help pages for this product
		private var _id:uint = 0;											// Unique ProductID from the database
		private var _logoBig:String = '';									// URL to a large representation of this product's logo
		private var _logoSmall:String = '';									// URL to a small representation of this product's logo
		private var _name:String = '';										// The name of this product
		private var _parent:Courseware = null;								// A link back to the courseware
		private var _released:Date;											// XML format: YYYY-MM-DDTHH:MM:SS
		
		public static function get instance():Product {
			return _instance;
		}		
		
		public function Product(xml:XML, parent:Courseware) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				_id = xml.@id;
				_logoBig = xml.@logoBig;
				_logoSmall = xml.@logoSmall;
				_name = xml.@name;
				_parent = parent;
				_released = DateFormatter.parseDateString(xml.@released);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var c:XML in xml.courses.course) {
				_courses[_courses.length] = new Course(c, this);
			}
			for each (var h:XML in xml.courses.helpPages) {
				_helpPages[_helpPages.length] = new HelpPage(h, this);
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
		public function get id():uint { return _id; }
		public function get logoBig():String { return _logoBig; }
		public function get logoSmall():String { return _logoSmall; }
		public function get name():String { return _name; }
		public function get parent():Courseware { return _parent; }
		public function get released():Date { return _released; }
	}
}