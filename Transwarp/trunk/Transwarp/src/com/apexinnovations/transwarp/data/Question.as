package com.apexinnovations.transwarp.data
{
	import com.apexinnovations.transwarp.data.Courseware;
	import com.apexinnovations.transwarp.utils.TranswarpVersion;
	
	import flash.errors.*;
	import flash.events.EventDispatcher;
	import flash.utils.*;
	
	import flashx.textLayout.conversion.TextConverter;
	import flashx.textLayout.elements.TextFlow;
	
	
	TranswarpVersion.revision = "$Rev$";
	
	// This represents a question and answer related to a page
	public class Question extends EventDispatcher {
		private var _aTextFlow:TextFlow = null;	// The answer text, as a TextFlow
		private var _parent:Page = null;		// A link back to the page
		private var _qTextFlow:TextFlow = null;	// The question text, as a TextFlow
		
		public function Question(xml:XML, parent:Page) {
			try {
				_aTextFlow = TextConverter.importToFlow(xml.answer.children()[0], TextConverter.TEXT_LAYOUT_FORMAT);
				_parent = parent;
				_qTextFlow = TextConverter.importToFlow(xml.query.children()[0], TextConverter.TEXT_LAYOUT_FORMAT);
			} catch ( e:Error ) {
				// No need to throw an error, just log it
				Courseware.log('Bad Initialization XML:  [' + e.message + ']', this);
			}
		}
		
		public function get aTextFlow():TextFlow { return _aTextFlow; }
		public function get parent():Page { return _parent; }
		public function get qTextFlow():TextFlow { return _qTextFlow; }
	}
}