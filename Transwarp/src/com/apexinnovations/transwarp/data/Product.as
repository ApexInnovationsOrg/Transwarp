package com.apexinnovations.transwarp.data
{
	import flash.errors.*;
	import flash.utils.*;
	import mx.formatters.DateFormatter;
	import com.apexinnovations.transwarp.data.Course;
		
	// This represents the the product being taken
	public class Product {
		private static var _instance:Product;	// Make this class a singleton
		private var _color:uint = 0xFFFFFF;		// The background color to use for this product in the engine's UI
		private var _id:uint = 0;				// Unique ProductID from the database
		private var _logoBig:String = '';		// URL to a large representation of this product's logo
		private var _logoSmall:String = '';		// URL to a small representation of this product's logo
		private var _name:String = '';			// The name of this product
		private var _released:Date;				// XML format: YYYY-MM-DDTHH:MM:SS
		
		private var _courses:Vector.<Course> = new Vector.<Course>();		// Vector (array) of courses for this product
		private var _helpPages:Vector.<HelpPage> = new Vector.<HelpPage>();	// Vector (array) of help pages for this product

		public static function get instance():Product {
			if(!_instance)
				new Product(<product/>);
			return _instance;
		}		
		
		public function Product(xml:XML) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				_color = uint("0x" + String(xml.@color).substr(1,6));	// @color like '#FF00FF'
				_id = xml.@id;
				_logoBig = xml.@logoBig;
				_logoSmall = xml.@logoSmall;
				_name = xml.@name;
				_released = DateFormatter.parseDateString(xml.@released);

				for each (var c:XML in xml.courses.course) {
					_courses[_courses.length] = new Course(c);
				}
				for each (var h:XML in xml.courses.helpPages) {
					_helpPages[_helpPages.length] = new HelpPage(h);
				}
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get color():uint { return _color; }
		public function get id():uint { return _id; }
		public function get logoBig():String { return _logoBig; }
		public function get logoSmall():String { return _logoSmall; }
		public function get name():String { return _name; }
		public function get released():Date { return _released; }

		public function get courses():Vector.<Course> { return _courses; }
		public function get helpPages():Vector.<HelpPage> { return _helpPages; }
	}
}