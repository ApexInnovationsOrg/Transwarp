package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.utils.Utils;
	
	import flash.errors.*;
	import flash.utils.*;
	
	import mx.formatters.DateFormatter;
	
	
	Utils.revision = "$Rev$";
	
	// This represents the user taking the class
	public class User {
		private static var _instance:User;		// Make this class a singleton
		
		private var _autoCloseMenu:Boolean = false;			// Automatically close previous folders when opening new one at same level?
		private var _audioVolume:uint = 50;					// Default audio volume (0-100)
		private var _animatePageTransitions:Boolean = true;	// Animate page transitions?
		private var _classes:String = '';					// Space separated list of classes this user falls into (e.g. 'LMS Doctor Beta')
		private var _closedCaptioning:Boolean = false;		// Turn on closed captioning?
		private var _id:uint = 0;							// Unique UserID from database
		private var _lastAccess:Date;						// XML format: YYYY-MM-DDTHH:MM:SS
		private var _locale:String = '';					// User's locale (e.g. 'en-US')
		private var _name:String = '';						// First and last name of user
		private var _parent:Courseware = null;				// A link back to the courseware
		private var _startCourseID:int = 0;					// CourseID to start with
		
		public static function get instance():User {
			return _instance;
		}		
		
		public function User(xml:XML, parent:Courseware) {
			if(_instance)
				throw new IllegalOperationError(getQualifiedClassName(this) + " is a singleton");
			
			_instance = this;

			try {
				_autoCloseMenu = xml.@autoCloseMenu == 'true';
				_audioVolume = uint(xml.@audioVolume);
				_animatePageTransitions = xml.@animatePageTransitions == 'true';
				_classes = xml.@classes;
				_closedCaptioning = xml.@closedCaptioning == 'true';
				_id = xml.@id;
				_lastAccess = DateFormatter.parseDateString(xml.@lastAccess);
				_locale = xml.@locale;
				_name = xml.@name;
				_parent = parent;
				_startCourseID = xml.@startCourse;
				
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}
		}

		[Bindable] public function get autoCloseMenu():Boolean { return _autoCloseMenu; }
		public function set autoCloseMenu(val:Boolean):void { _autoCloseMenu = val; }
		
		[Bindable] public function get audioVolume():uint { return _audioVolume; }
		public function set audioVolume(val:uint):void { _audioVolume = val; }
		
		[Bindable] public function get animatePageTransitions():Boolean { return _animatePageTransitions; }
		public function set animatePageTransitions(val:Boolean):void { _animatePageTransitions = val; }
		
		[Bindable] public function get closedCaptioning():Boolean { return _closedCaptioning; }
		public function set closedCaptioning(val:Boolean):void { _closedCaptioning = val; }
		
		public function get beta():Boolean { return (_classes.indexOf('Beta') != -1); }
		public function get doctor():Boolean { return (_classes.indexOf('Doctor') != -1); }
		public function get emt():Boolean { return (_classes.indexOf('EMT') != -1); }
		public function get lms():Boolean { return (_classes.indexOf('LMS') != -1); }
		public function get nurse():Boolean { return (_classes.indexOf('Nurse') != -1); }
		
		public function get id():uint { return _id; }
		
		public function get lastAccess():Date { return _lastAccess; }
		
		public function get locale():String { return _locale; }
		
		public function get name():String { return _name; }
		
		public function get parent():Courseware { return _parent; }
		
		public function get startCourseID():int { return _startCourseID; }
	}
}