package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flash.utils.*;
	import com.apexinnovations.transwarp.Page;
	
	// This represents the course being taken
	public class Folder {
		private var _name:String = '';
		private var _content:Array = [];
		
		public function Folder(xml:XML) {
			try {
				_name = xml.@name;

/*				for (var i:uint = 0; i < xml.length(); i++) {
					var x:* = xml[i];
					if (x.hasOwnProperty('id')) {
						_content[_content.length] = new Page(x);
					} else {
						_content[_content.length] = new Folder(x);
					}
				}*/
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get name():String { return _name; }
		public function get contents():Array { return _content; }
	}
}