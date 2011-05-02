package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import com.apexinnovations.transwarp.Product;
	import com.apexinnovations.transwarp.User;
	
	import flash.errors.*;
	
	// This represents the user taking the class and the product being taken
	public class Courseware {
		private static var _instance:Courseware;
		private var _website:String = '';
		private var _rootFolder:String = '';
		private var _debug:Boolean = false;
		private var _user:User = null;
		private var _product:Product = null;

		public static function get instance():Courseware {
			if(!_instance)
				new Courseware(<courseware/>);
			return _instance;
		}		

		public function Courseware(xml:XML) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;
			
			try {
				_website = xml.@website;
				_rootFolder = xml.@rootFolder;
				_debug = xml.@debug;
				_user = new User(xml.user[0]);
				_product = new Product(xml.product[0]);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get website():String { return _website; }
		public function get rootFolder():String { return _rootFolder; }
		public function get debug():Boolean { return _debug; }
		public function get user():User { return _user; }
		public function get product():Product { return _product; }
	}
}