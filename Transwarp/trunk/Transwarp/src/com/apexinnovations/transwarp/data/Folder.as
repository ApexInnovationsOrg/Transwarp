package com.apexinnovations.transwarp.data
{
	import flash.errors.*;
	import flash.utils.*;
	import com.apexinnovations.transwarp.data.Page;
	
	// This represents a folder of pages and subfolders (of pages)
	public class Folder {
		private var _name:String = '';		// The name of this folder
		
		private var _contents:Array = [];	// An ordered collection of the contents of this folder (pages and other folders)
		
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