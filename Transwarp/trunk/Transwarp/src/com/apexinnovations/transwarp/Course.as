package com.apexinnovations.transwarp
{
	import com.apexinnovations.transwarp.Folder;
	import com.apexinnovations.transwarp.Page;
	
	import flash.errors.*;
	import flash.utils.*;
		
	// This represents the course being taken
	public class Course {
		private var _id:uint = 0;
		private var _level:uint = 0;
		private var _name:String = '';
		private var _restricted:Boolean = false;

		private var _contents:Array = [];
		
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