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
		public function get level():String { return roman(_level); }

	
		
		protected var romanValues:Array = [1000,900,500,400,100,90,50,40,10,9,5,4,1]
		protected var romanSymbols:Array = ['M','CM','D','CD','C','XC','L','XL','X','IX','V','IV','I']; 			
		
		protected function roman(n:int):String {
			if( n >= 4000 || n < 1)
				return "N/A";
			
			var x:String = "";
			
			var i:int = 0;
			
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