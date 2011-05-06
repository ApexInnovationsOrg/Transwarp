package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Folder;
	import com.apexinnovations.transwarp.data.Page;
	
	import flash.errors.*;
	import flash.utils.*;
		
	// This represents the course being taken
	public class Course {
		private var _contents:Array = [];						// An ordered collection of the contents of this course (pages and folders)
		private var _id:uint = 0;								// The CourseID from the database
		private var _level:uint = 0;							// The level of this course
		private var _name:String = '';							// The name of this course
		private var _pages:Vector.<Page> = new Vector.<Page>();	// An ordered collection of pages of this course
		private var _parent:Product = null;						// A link back to the product
		private var _restricted:Boolean = false;				// Is the user restricted from using this course?

		
		public function Course(xml:XML, parent:Product) {
			try {
				_id = xml.@id;
				_level = xml.@level;
				_name = xml.@name;
				_parent = parent;
				_restricted = xml.@restricted == 'true';
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + ': Bad Initialization XML:  [' + e.message + ']');
			}

			for each (var child:XML in xml.children()) {
				if (child.localName() == "page") {
					var p:Page = new Page(child, this, 0);
					_contents.push(p);
					_pages.push(p);
				} else {
					var f:Folder = new Folder(child, this, 0);
					_contents.push(f);
					for each (var q:Page in f.pages) {
						_pages.push(q);
					}
					//_pages.concat(f.pages);	NOT WORKING???
				}
			}
		}
		
		public function get contents():Array { return _contents; }		
		public function get id():uint { return _id; }
		public function get level():uint {return _level;}
		public function get levelRoman():String { return roman(_level); }
		public function get name():String { return _name; }
		public function get pages():Vector.<Page> { return _pages; }
		public function get parent():Product { return _parent; }
		public function get restricted():Boolean { return _restricted; }
		public function get viewableContents():Array {
			var _viewable:Array = [];
			
			for each (var item:* in _contents) {
				_viewable.push(item);
				if ((item is Folder) && item.open) {
					_viewable.concat(item.viewableContents);
				}
			}
			return _viewable;
		}
		

		public function getPageByID(pageID:uint):Page {
			for each(var p:Page in pages)
				if(p.id == pageID)
					return p;
			return null;
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