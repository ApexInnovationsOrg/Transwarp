package com.apexinnovations.transwarp
{
	import flash.utils.*;
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
		private var _classes:String = '';
		
		public static function get instance():User {
			if(!_instance)
				new User(<user/>);
			return _instance;
		}		
		
		public function User(xml:XML) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;

			try {
				_id = xml.@id;
				_name = xml.@name;
				_locale = xml.@locale;
				_lastAccess = DateFormatter.parseDateString(xml.@lastAccess);
				_timeout = xml.@coursewareTimeout;
				_courseID = xml.@startCourse;
				_pageID = xml.@startPage;
				_classes = xml.@classes;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}

		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function get locale():String { return _locale; }
		public function get lastAccess():Date { return _lastAccess; }
		public function get timeout():int { return _timeout; }
		public function get startCourseID():int { return _courseID; }
		public function get startPageID():int { return _pageID; }
		public function get lms():Boolean { return (_classes.indexOf('LMS') > 0); }
		public function get beta():Boolean { return (_classes.indexOf('Beta') > 0); }
		public function get doctor():Boolean { return (_classes.indexOf('Doctor') > 0); }
		public function get nurse():Boolean { return (_classes.indexOf('Nurse') > 0); }
		public function get emt():Boolean { return (_classes.indexOf('EMT') > 0); }
	}
}