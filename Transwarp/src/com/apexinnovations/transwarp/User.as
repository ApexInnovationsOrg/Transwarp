package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import flash.errors.*;
	import mx.formatters.DateFormatter;
	
	// This represents the user taking the class
	public class User {
		private static var _instance:User;
		private var _classes:String = '';
		private var _id:uint = 0;
		private var _lastAccess:Date;	// XML format: YYYY-MM-DDTHH:MM:SS
		private var _locale:String = '';
		private var _name:String = '';
		private var _startCourseID:int = 0;
		private var _startPageID:int = 0;
		
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
				_classes = xml.@classes;
				_id = xml.@id;
				_lastAccess = DateFormatter.parseDateString(xml.@lastAccess);
				_locale = xml.@locale;
				_name = xml.@name;
				_startCourseID = xml.@startCourse;
				_startPageID = xml.@startPage;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}

		public function get beta():Boolean { return (_classes.indexOf('Beta') > 0); }
		public function get doctor():Boolean { return (_classes.indexOf('Doctor') > 0); }
		public function get emt():Boolean { return (_classes.indexOf('EMT') > 0); }
		public function get id():uint { return _id; }
		public function get lastAccess():Date { return _lastAccess; }
		public function get lms():Boolean { return (_classes.indexOf('LMS') > 0); }
		public function get locale():String { return _locale; }
		public function get name():String { return _name; }
		public function get nurse():Boolean { return (_classes.indexOf('Nurse') > 0); }
		public function get startCourseID():int { return _startCourseID; }
		public function get startPageID():int { return _startPageID; }
	}
}