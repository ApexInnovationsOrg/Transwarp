package com.apexinnovations.transwarp
{
	import flash.errors.*;
	
	public class Product {
		private static var _instance:User;
		private var _id:int = 0;
		private var _name:String = '';
		private var _logoBig:String = '';
		private var _logoSmall:String = '';
		private var _color:uint = 0xFFFFFF;

		public static function get instance():Product {
			if(!_instance)
				new Product();
			return _instance;
		}		
		
		public function Product(xml:XML) {
			if(_instance)
				throw new IllegalOperationError("Product is a singleton");
			
			_instance = this;
			
			try {
				_id = xml.@id;
				_name = xml.@name;
				_locale = xml.@locale;
				_logoBig = xml.@logoBig;
				_logoSmall = xml.@logoSmall;
				var prodColor:String = xml.@color;
				_color = uint("0x" + prodColor.substr(1,6));	// @color like '#FF00FF'
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}
		
		public function get id():int { return _id; }
		public function get name():String { return _name; }
		public function get logoBig():String { return _logoBig; }
		public function get logoSmall():String { return _logoSmall; }
		public function get color():uint { return _color; }
	}
}