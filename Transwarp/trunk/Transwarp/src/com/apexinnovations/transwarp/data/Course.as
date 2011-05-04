package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Folder;
	import com.apexinnovations.transwarp.data.Page;
	
	import flash.errors.*;
	import flash.utils.*;
		
	// This represents the course being taken
	public class Course {
		private var _id:uint = 0;					// The CourseID from the database
		private var _level:uint = 0;				// The level of this course
		private var _name:String = '';				// The name of this course
		private var _restricted:Boolean = false;	// Is the user restricted from using this course?

		private var _contents:Array = [];			// An ordered collection of the contents of this folder (pages and other folders)
		
		public function Course(xml:XML) {
			try {
				_id = xml.@id;
				_level = xml.@level;
				_name = xml.@name;
				_restricted = xml.@restricted;

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
		
		public function get id():uint { return _id; }
		public function get level():String { return roman(_level); }
		public function get name():String { return _name; }
		public function get restricted():Boolean { return _restricted; }
		
		public function get contents():Array { return _contents; }
		
		// Returns a Vector (array) of Pages in this Course
		public function pages(recurse:Boolean = true):Vector.<Page> {
			var _pages:Vector.<Page> = new Vector.<Page>();
			
			for each (var item:* in _contents) {
				if (item is Page) {
					_pages[_pages.length] = item as Page;
				} else if (recurse) {
					var _more:Vector.<Page> = (item as Folder).pages(recurse);
					for each (var x:Page in _more) {
						_pages.push(x);
					}
				}
			}
			return _pages;
		}

			
		private function roman(n:int):String {
			if( n >= 4000 || n < 1)
				return "N/A";
			
			var x:String = "";
			
			var i:int = 0;
			
			var romanValues:Array = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
			var romanSymbols:Array = ['M','CM','D','CD','C','XC','L','XL','X','IX','V','IV','I']; 			

			while(n > 0) {
				var symbol:String = romanSymbols[i];
				var value:int = romanValues[i];
				
				while(n >= value) {
					x += symbol;
					n -= value;
				}
				i++;				
			}
			
			return x;
		}
	}
}