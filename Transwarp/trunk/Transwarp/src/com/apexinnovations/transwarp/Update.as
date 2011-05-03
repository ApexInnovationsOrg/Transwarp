package com.apexinnovations.transwarp
{
	import flash.utils.*;
	import flash.errors.*;
	import mx.formatters.DateFormatter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents an update to a page
	public class Update {
		private var _time:Date = null;			// The date/time of this update, in XML format: YYYY-MM-DDTHH:MM:SS
		private var _textFlow:TextFlow = null;	// The description of this update, as a TextFlow
		
		public function Update(xml:XML) {
			try {
				_time = DateFormatter.parseDateString(xml.@time);
				_textFlow = TextConverter.importToFlow(xml[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				throw new ArgumentError(getQualifiedClassName(this) + " - Invalid Initialization XML - " + e.toString());
			}
		}
		
		public function get time():Date { return _time; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}