package com.apexinnovations.transwarp
{
	import flash.errors.*;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents an update to a page
	public class Update {
		private var _time:Date = null;
		private var _textFlow:TextFlow = null;
		
		public function Update(xml:XML) {
			try {
				_time = xml.@time;
				_textFlow = xml[0];
			} catch ( e:Error ) {
				throw new ArgumentError("Invalid Initialization XML");
			}
		}
		
		public function get time():Date { return _time; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}