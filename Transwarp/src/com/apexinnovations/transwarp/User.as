package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import mx.formatters.DateFormatter;
	
	// This represents the user taking the class
	public class User {
		private static var _instance:User;
		private var _id:uint = 0;
		private var _name:String = '';
		private var _locale:String = '';
		private var _lastAccess:Date;	// XML format: YYYY-MM-DDTHH:MM:SS
		private var _timeout:int = 0;	// seconds
		private var _courseID:int = 0;
		private var _pageID:int = 0;
		
		public static function get instance():User {
			if(!_instance)
				new User(<user/>);
			return _instance;
		}		
		
		public function User(xml:XML) {
			if(_instance)
				throw new IllegalOperationError("User is a singleton");
			
			_instance = this;

			try {
				_id = xml.@id;
				_name = xml.@name;
				_locale = xml.@locale;
				_lastAccess = DateFormatter.parseDateString(xml.@lastAccess);
				_timeout = xml.@coursewareTimeout;
				_courseID = xml.@startCourse;
				_pageID = xml.@startPage;
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}

		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function get locale():String { return _locale; }
		public function get lastAccess():Date { return _lastAccess; }
		public function get timeout():int { return _timeout; }
		public function get startCourseID():int { return _courseID; }
		public function get startPageID():int { return _pageID; }
	}
}