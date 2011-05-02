package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import flash.errors.*;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents an update to a page
	public class Update {
		private var _time:Date = null;
		private var _textFlow:TextFlow = null;
		
		public function Update(xml:XML) {
			try {
				_time = xml.@time;
				_textFlow = TextConverter.importToFlow(xml[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get time():Date { return _time; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}