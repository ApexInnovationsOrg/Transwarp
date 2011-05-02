package com.apexinnovations.transwarp
{
	import com.apexinnovations.transwarp.Course;
	
	import flash.errors.*;
	
	// This represents the the product being taken
	public class Product {
		private static var _instance:Product;
		private var _id:uint = 0;
		private var _name:String = '';
		private var _logoBig:String = '';
		private var _logoSmall:String = '';
		private var _color:uint = 0xFFFFFF;
		private var _courseList:Vector.<Course> = null;

		public static function get instance():Product {
			if(!_instance)
				new Product(<product/>);
			return _instance;
		}		
		
		public function Product(xml:XML) {
			if(_instance)
				throw new IllegalOperationError("Product is a singleton");
			
			_instance = this;
			
			try {
				_id = xml.@id;
				_name = xml.@name;
				_logoBig = xml.@logoBig;
				_logoSmall = xml.@logoSmall;
				var prodColor:String = xml.@color;
				_color = uint("0x" + prodColor.substr(1,6));	// @color like '#FF00FF'
				var c:XML;
				for each (c in xml.courses.course) {
					var x:Course = new Course(c);
					if (x != null) _courseList.push(x);
				}
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML" + e.toString());
			}
		}
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function get logoBig():String { return _logoBig; }
		public function get logoSmall():String { return _logoSmall; }
		public function get color():uint { return _color; }
	}
}