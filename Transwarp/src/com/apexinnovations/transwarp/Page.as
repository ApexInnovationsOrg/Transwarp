package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flash.utils.*;
	
	// This represents the course being taken
	public class Page {
		private var _id:uint = 0;
		private var _name:String = '';
		
		public function Page(xml:XML) {
			try {
				_id = xml.@id;
				_name = xml.@name;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
	}
}