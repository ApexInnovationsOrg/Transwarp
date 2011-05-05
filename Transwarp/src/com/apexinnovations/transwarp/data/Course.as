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
		private var _parent:Product = null;			// A link back to the product
		private var _restricted:Boolean = false;	// Is the user restricted from using this course?

		private var _contents:Array = [];			// An ordered collection of the contents of this folder (pages and other folders)
		
		public function Course(xml:XML, parent:Product) {
			try {
				_id = xml.@id;
				_level = xml.@level;
				_name = xml.@name;
				_parent = parent;
				_restricted = xml.@restricted;
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var child:XML in xml.children()) {
				if (child.@visited != undefined) {
					_contents[_contents.length] = new Page(child, this);
				} else {
					_contents[_contents.length] = new Folder(child, this);
				}
			}
		}
		
		public function get contents():Array { return _contents; }		
		public function get id():uint { return _id; }
		public function get level():uint {return _level;}
		public function get levelRoman():String { return roman(_level); }
		public function get name():String { return _name; }
		public function get parent():Product { return _parent; }
		public function get restricted():Boolean { return _restricted; }
		
		// Returns a Vector (array) of Pages in this Course
		public function pages(recurse:Boolean = true):Vector.<Page> {
			var _pages:Vector.<Page> = new Vector.<Page>();
			
			for each (var item:* in _contents) {
				if (item is Page) {
					_pages[_pages.length] = item as Page;
				} else if (recurse) {
					for each (var x:Page in (item as Folder).pages(recurse)) {
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

		// Returns an array of viewable (folder open) pages and folders within this page
		public function viewableContents():Array {
			var _viewable:Array = [];
			
			for each (var item:* in _contents) {
				_viewable[_viewable.length] = item;
				if ((item is Folder) && item.open) {
					for each (var x:* in item.viewableContents()) {
						_viewable.push(x);
					}
				}
			}
			return _viewable;
		}
	}
}