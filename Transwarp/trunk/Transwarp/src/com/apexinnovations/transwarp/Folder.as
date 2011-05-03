package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flash.utils.*;
	import com.apexinnovations.transwarp.Page;
	
	// This represents the course being taken
	public class Folder {
		private var _name:String = '';
		
		private var _contents:Array = [];
		
		public function Folder(xml:XML) {
			try {
				_name = xml.@name;

				for each (var child:XML in xml.children()) {
					if (child.@visited != undefined) {
						_contents[_contents.length] = new Page(child);
					} else {
						_contents[_contents.length] = new Folder(child);
					}
				}
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get name():String { return _name; }
		
		public function get contents():Array { return _contents; }
	}
}