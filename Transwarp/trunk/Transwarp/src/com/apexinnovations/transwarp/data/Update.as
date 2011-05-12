package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.events.EventDispatcher;
	import flash.errors.*;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	import mx.formatters.DateFormatter;
	
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents an update to a page
	public class Update extends EventDispatcher {
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