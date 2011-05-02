package com.apexinnovations.transwarp
{
	import flash.errors.*;
	
	// This represents the course being taken
	public class Course {
		private var _id:uint = 0;
		private var _name:String = '';
		private var _level:uint = 0;
		
		public function Course(xml:XML) {
			try {
				_id = xml.@id;
				_name = xml.@name;
				_level = xml.@level;
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function get level():uint { return _level; }
	}
}