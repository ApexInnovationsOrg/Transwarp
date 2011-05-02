package com.apexinnovations.transwarp
{
	import com.apexinnovations.transwarp.Folder;
	import com.apexinnovations.transwarp.Page;
	
	import flash.errors.*;
	import flash.utils.*;
	
	// This represents the course being taken
	public class Course {
		private var _id:uint = 0;
		private var _name:String = '';
		private var _level:uint = 0;
		private var _content:Array = [];
		
		public function Course(xml:XML) {
			try {
				_id = xml.@id;
				_name = xml.@name;
				_level = xml.@level;

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
		
		public function get id():uint { return _id; }
		public function get name():String { return _name; }
		public function get level():String { return roman(_level); }
		public function get contents():Array { return _content; }

			
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