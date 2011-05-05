package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import flash.utils.*;
	import flash.errors.*;
	import mx.formatters.DateFormatter;
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	// This represents an update to a page
	public class Update {
		private var _parent:Page = null;		// A link back to the page
		private var _time:Date = null;			// The date/time of this update, in XML format: YYYY-MM-DDTHH:MM:SS
		private var _textFlow:TextFlow = null;	// The description of this update, as a TextFlow
		
		public function Update(xml:XML, parent:Page) {
			try {
				_parent = parent;
				_time = DateFormatter.parseDateString(xml.@time);
				_textFlow = TextConverter.importToFlow(xml[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				// No need to throw an error, just log it
				Courseware.log('Bad Initialization XML:  [' + e.message + ']', this);
			}
		}
		
		public function get parent():Page { return _parent; }
		public function get time():Date { return _time; }
		public function get textFlow():TextFlow { return _textFlow; }
	}
}